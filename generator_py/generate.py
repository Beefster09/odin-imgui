import argparse
from collections import defaultdict
import io
import re
import sys
import textwrap
from pathlib import Path
from typing import List

from pycparser import parse_file, c_ast

THIS_DIR = Path(__file__).parent.absolute()
CIMGUI_DIR = THIS_DIR.parent / 'cimgui'
ODIN_DIR = THIS_DIR.parent


def main():
    header_ast = parse_file(
        CIMGUI_DIR / 'cimgui.h',
        use_cpp=True,
        cpp_args=[
            '-DCIMGUI_DEFINE_ENUMS_AND_STRUCTS',
            '-DCIMGUI_NO_EXPORT',
            '-D_WIN32',  # hack to force no declspec
            '-isystem', str(THIS_DIR / 'fake_libc'),
        ],
    )

    header_ast = [
        node for node in header_ast
        if is_cimgui(node)
    ]

    generate_types(header_ast)
    generate_foreign(header_ast)
    generate_wrapper(header_ast)


def generate_types(ast):
    with open(ODIN_DIR / 'types_gen.odin', 'w') as fp:
        write_header(fp)
        visitor = TypeGenVisitor(fp)
        for node in ast:
            visitor.visit(node)


def generate_foreign(ast):
    with open(ODIN_DIR / 'foreign_gen.odin', 'w') as fp:
        write_header(fp)
        fp.write(textwrap.dedent("""
            import "core:c/libc"

            when ODIN_OS == .Windows {
            \twhen ODIN_DEBUG {
            \t\tforeign import cimgui "external/cimgui_debug.lib"
            \t} else {
            \t\tforeign import cimgui "external/cimgui.lib"
            \t}
            } else {
            \tforeign import cimgui "external/libcimgui.a"
            }

            @(default_calling_convention="c")
            foreign cimgui {
        """))

        for node in ast:
            if is_exported_proc(node):
                all_params = param_list(node.type.args)

                odin_params = []

                for i, param in enumerate(all_params):
                    prev_param = all_params[i - 1] if i > 0 else None

                    if isinstance(param, c_ast.EllipsisParam):
                        odin_params.append('#c_vararg _args_: ..any')

                    elif is_string_span_pair(prev_param, param):
                        odin_params[-1:] = [
                            f"{odin_id(prev_param.name)}: [^]u8",
                            f"{odin_id(param.name)}: [^]u8",
                        ]

                    else:
                        odin_params.append(f"{odin_id(param.name)}: {type_as_odin(param.type)}")

                ret_type = type_as_odin(node.type.type)
                if ret_type == 'void':
                    ret = ''
                else:
                    ret = f" -> {ret_type}"

                fp.write(f"\t{node.name} :: proc({', '.join(odin_params)}){ret} ---\n")

        fp.write("}\n")


def generate_wrapper(ast):
    with open(ODIN_DIR / 'wrapper_gen.odin', 'w') as fp:
        write_header(fp)
        fp.write(textwrap.dedent('''
            import "core:fmt"
            import "core:strings"
        '''))

        overloads = defaultdict(list)

        for node in ast:
            if is_exported_proc(node):
                orig_ret_type = type_as_odin(node.type.type)
                all_params = list(node.type.args) if not is_empty_param_list(node.type.args) else []

                if all_params and is_va_list(all_params[-1]):
                    continue  # skip

                proc_name = odin_procname(node.name)
                func_to_call = node.name
                overloads[proc_overload_group(node.name)].append(proc_name)

                odin_params = []
                call_args = []
                multiple_returns = []

                setup_lines = []

                fmt_index = None

                for i, param in enumerate(all_params):
                    prev_param = all_params[i - 1] if i > 0 else None
                    try:
                        next_param = all_params[i + 1]
                    except IndexError:
                        next_param = None

                    if is_out_param(param):
                        multiple_returns.append(f"{odin_id(param.name)}: {type_as_odin(deref(param.type))}")
                        call_args.append('&' + odin_id(param.name))

                    elif isinstance(param, c_ast.EllipsisParam):
                        assert fmt_index is not None, f"did not see format arg in {node.name}"
                        odin_params.append(f"args: ..any")
                        setup_lines += [
                            "_sb := strings.builder_make(context.temp_allocator)",
                            f"fmt.sbprintf(&_sb, {call_args[fmt_index]}, ..args)",
                            "append(&_sb.buf, 0)",
                            "_formatted_str := strings.unsafe_string_to_cstring(strings.to_string(_sb))"
                        ]
                        call_args[fmt_index] = '"%s"'
                        call_args.append('_formatted_str')

                    elif is_cstring(param.type):

                        if is_string_span_pair(prev_param, param):
                            assert param.name.endswith('_end')
                            pname = odin_id(param.name[:-4])
                            odin_params[-1] = f"{pname}: string"
                            call_args[-1:] = [f'{pname}_begin', f'{pname}_end']
                            setup_lines[-1:] = [
                                f"{pname}_begin := raw_data({pname})",
                                f"{pname}_end := cast([^]u8)(uintptr({pname}_begin) + uintptr(len({pname})))",
                            ]

                        elif node.name in ['igPushID_Str', 'igGetID_Str']:  # HACK b/c of overload
                            pname = odin_id(param.name)
                            odin_params.append(f"{pname}: cstring")
                            call_args.append(pname)

                        elif param.name in ('fmt', 'format') and fmt_index is None and isinstance(all_params[-1], c_ast.EllipsisParam):
                            pname = odin_id(param.name)
                            odin_params.append(f"{pname}: string")
                            fmt_index = len(call_args)  # will be hijacked later by varargs
                            call_args.append(pname)

                        else:
                            pname = odin_id(param.name)
                            odin_params.append(f"{pname}: string")
                            setup_lines.append(f"_temp_{pname} := semisafe_string_to_cstring({pname})")
                            call_args.append('_temp_' + odin_id(param.name))


                    elif is_slice_pair(prev_param, param) and not is_out_param(prev_param):
                        pname = odin_id(re.sub(r"_(?:len(?:gth)?|size|count)$", '', param.name))
                        len_type = type_as_odin(param.type)
                        odin_params[-1] = f"{pname}: []{type_as_odin(deref(prev_param.type))}"
                        call_args[-1:] = [f"raw_data({pname})", f"{f'cast({len_type})' * (len_type != 'int')}len({pname})"]

                    else:
                        odin_params.append(f"{odin_id(param.name)}: {type_as_odin(param.type)}")
                        call_args.append(odin_id(param.name))


                if defaults := DEFAULT_ARGS.get(proc_name):
                    for i, value in enumerate(defaults, -len(defaults)):
                        odin_params[i] += f" = {value}"
                else:
                    for i in range(len(odin_params) - 1, -1, -1):
                        name, ptype = map(str.strip, odin_params[i].split(':'))
                        if ptype == 'Table_Flags':
                            odin_params[i] = f"{name} := Table_Flags(0)"
                        elif re.fullmatch(r"\[\d\][uif](8|16|32|64)|[\w_]*(Cond|Flags)", ptype):
                            odin_params[i] = f"{name} := {ptype}{{}}"
                        else:
                            break

                if orig_ret_type == 'void':
                    if multiple_returns:
                        ret = f" -> ({', '.join(multiple_returns)})"
                    else:
                        ret = ''
                else:
                    if multiple_returns:
                        ret = f" -> ({', '.join(multiple_returns)}, _ret: {orig_ret_type})"
                    else:
                        ret = f" -> {orig_ret_type}"

                fp.write(f"{proc_name} :: {'#force_inline' * (not setup_lines)} proc ({', '.join(odin_params)}){ret} {{\n")

                for line in setup_lines:
                    fp.write(f"\t{line}\n")

                if multiple_returns:
                    fp.write(f"\t{'_ret = ' * (orig_ret_type != 'void')}{func_to_call}({', '.join(call_args)})\n")
                    fp.write("\treturn\n")

                else:
                    fp.write(f"\t{'return ' * (orig_ret_type != 'void')}{func_to_call}({', '.join(call_args)})\n")

                fp.write("}\n")

        for group, impls in overloads.items():
            if len(impls) > 1:
                fp.write(f"\n{group} :: proc {{\n")
                for impl in impls:
                    fp.write(f"\t{impl},\n")
                fp.write("}\n")


DEFAULT_ARGS = {  # default values for the last N parameters of specific procs
    'create_context': ['nil'],
    'style_colors_light': ['nil'],
    'style_colors_dark': ['nil'],
    'style_colors_classic': ['nil'],
    'same_line': ['0', '1']
    # TODO
}


def write_header(fp):
    fp.write(textwrap.dedent(f"""
        // GENERATED FILE; DO NOT EDIT
        // this file was generated by generator_v2/{Path(__file__).name}

        package imgui

    """))


class TypeGenVisitor(c_ast.NodeVisitor):
    def __init__(self, fp):
        self.fp = fp

    def visit_Struct(self, struct: c_ast.Struct):
        if struct.decls is None:
            return

        if struct.name.startswith(('ImVec', 'ImSpan_', 'BitArray_')):
            return

        self.fp.write(f"\n{odin_typename(struct.name)} :: struct {{\n")
        for i, decl in enumerate(struct.decls):
            using = '' if decl.name is not None else 'using '
            field_name = odin_id(decl.name or f'_field_{i}')
            self.fp.write(f"\t{using}{field_name}: {type_as_odin(decl.type)},\n")
        self.fp.write("}\n")

    def visit_Enum(self, enum: c_ast.Enum, name=None):
        type_name = name or enum.name

        if type_name is None:
            return

        elif type_name.rstrip('_').endswith('Private'):
            return

        elif type_name == 'ImGuiTableFlags_':
            self.fp.write("\nTable_Flags :: distinct i32  // SPECIAL CASE GEN\n")

            # HACK for laziness
            self.fp.write("/* *** UGLY DEFINITIONS ON THIS LINE FOR GENERATOR IMPLEMENTATION CONVENIENCE; DO NOT USE THE CONSTANTS ON THIS LINE! *** */")
            for flag in enum.values:
                self.fp.write(f"{flag.name}::Table_Flags({value_as_odin(flag.value)});")

            self.fp.write("\n// Use the following constants instead:\n")
            for flag in enum.values:
                _, vname = flag.name.rstrip('_').split('_', 1)
                self.fp.write(f"\tTF_{odin_id(vname).upper()} :: {flag.name}\n")

            self.fp.write('// - END OF Table_Flags constants -\n')

        elif type_name.endswith(('Flags_', 'Cond_')):
            composite_flags = []
            members = {}

            self.fp.write(f"\n{type_name} :: enum {{\n")

            for flag in enum.values:
                flag_name = odin_enumname(flag.name)

                # TODO: handle ImGuiTableFlags

                if isinstance(flag.value, c_ast.BinaryOp) and flag.value.op == '<<':
                    assert isinstance(flag.value.left, c_ast.Constant)
                    assert isinstance(flag.value.right, c_ast.Constant)
                    if flag.value.left.value == '1':
                        self.fp.write(f"\t{flag_name} = {flag.value.right.value},\n")
                        members[flag.name] = flag_name
                    else:
                        self.fp.write(f"\t// {flag_name} = {value_as_odin(flag.value)}, // Cannot represent cleanly :-/ \n")

                elif (
                    isinstance(flag.value, c_ast.BinaryOp) and flag.value.op == '|'
                    or isinstance(flag.value, c_ast.Constant) and flag.value == '0'
                ):
                    composite_flags.append(flag)

            self.fp.write('}\n')

            for flag in composite_flags:
                bit_set_name = odin_typename(type_name.rstrip('_'))
                ename, vname = flag.name.rstrip('_').split('_', 1)

                bit_set_values = []
                masks = []

                class CV(c_ast.NodeVisitor):  # quick and dirty hack that makes assumptions
                    def visit_ID(self, ident: c_ast.ID):
                        if ident.name in members:
                            bit_set_values.append('.' + odin_enumname(ident.name))
                        else:
                            ename, vname = ident.name.rstrip('_').split('_', 1)
                            masks.append(f" | {odin_typename(ename)}_{odin_id(vname).upper()}")

                CV().visit(flag)

                self.fp.write(f"{odin_typename(ename)}_{odin_id(vname).upper()} :: {bit_set_name}{{ {', '.join(bit_set_values)} }}{''.join(masks)}\n")

        else:
            special_enum_values = []
            enum_typename = odin_typename(type_name.rstrip('_'))

            self.fp.write(f"\n{enum_typename} :: enum i32 {{\n")

            last_value = None
            for enum_value in enum.values:
                enum_name = odin_enumname(enum_value.name)
                enum_name_end = enum_value.name.split('_')[-1]

                if enum_name_end in ('BEGIN', 'END', 'COUNT', 'SIZE', 'OFFSET') or not enum_value.name.startswith(type_name):
                    special_enum_values.append(enum_value)

                elif enum_value.value is None:
                    self.fp.write(f"\t{enum_name},\n")
                    if last_value is not None:
                        last_value += 1

                else:
                    self.fp.write(f"\t{enum_name} = {value_as_odin(enum_value.value)},\n")
                    if isinstance(enum_value.value, c_ast.Constant):
                        last_value = int(enum_value.value.value)
                    else:
                        last_value = None

            self.fp.write("}\n")

            if special_enum_values:
                self.fp.write("/* UGLY DEFINITIONS ON THIS LINE FOR IMPLEMENTATION CONVENIENCE */")

            for enum_value in special_enum_values:
                enum_name = odin_enumname(enum_value.name)

                if enum_name == 'COUNT':
                    if last_value is None:
                        self.fp.write(f"{enum_value.name}::len({enum_typename});")
                    else:
                        self.fp.write(f"{enum_value.name}::{last_value + 1};")
                else:
                    assert enum_value.value is not None, f"Unhandled {type(enum_value)} at {enum_value.coord}"
                    self.fp.write(f"{enum_value.name}::{value_as_odin(enum_value.value)};")

            self.fp.write("\n")

            for enum_value in special_enum_values:
                self.fp.write(f"{enum_typename}_{odin_enumname(enum_value.name)} :: {enum_value.name}\n")

            self.fp.write("\n")

    def visit_Typedef(self, typedef: c_ast.Typedef):
        if (
            isinstance(typedef.type, c_ast.TypeDecl)
            and isinstance(typedef.type.type, c_ast.IdentifierType)
            and typedef.name not in TYPE_MAP
        ):
            if typedef.name == 'ImGuiTableFlags':
                return  # special case b/c weird flags
            elif typedef.name.endswith(('Flags', 'Cond')):
                self.fp.write(f"{odin_typename(typedef.name)} :: bit_set[{typedef.name}_; u32]\n")
            elif typedef.type.type.names == ['int'] and typedef.name not in ('ImGuiKeyChord', 'ImPoolIdx'):
                return  # probably an enum, but not flags
            else:
                self.fp.write(f"{odin_typename(typedef.name)} :: distinct {type_as_odin(typedef.type)}\n")
        elif (
            isinstance(typedef.type, c_ast.TypeDecl)
            and isinstance(typedef.type.type, c_ast.Enum)
        ):
            self.visit_Enum(typedef.type.type, typedef.name)
        else:
            return self.generic_visit(typedef)


def value_as_odin(value_node) -> str:
    assert value_node is not None

    if isinstance(value_node, c_ast.ID):
        return value_node.name

    elif isinstance(value_node, c_ast.Constant):
        return value_node.value

    elif isinstance(value_node, c_ast.BinaryOp):
        return f"({value_as_odin(value_node.left)} {value_node.op} {value_as_odin(value_node.right)})"

    elif isinstance(value_node, c_ast.UnaryOp):
        return f"({value_node.op}{value_as_odin(value_node.expr)})"

    raise Exception(f"Unhandled {type(value_node)} at {value_node.coord}")


def type_as_odin(type_node) -> str:
    if isinstance(type_node, c_ast.PtrDecl):
        if is_cstring(type_node):
            return 'cstring'

        inner = type_as_odin(type_node.type)
        if inner == 'void':
            return 'rawptr'
        elif inner.startswith('#type proc'):  # HACK: would break on pointer to function pointer
            return inner
        else:
            return f"^{inner}"

    elif isinstance(type_node, c_ast.ArrayDecl):
        inner = type_as_odin(type_node.type)
        if type_node.dim is not None:
            return f"[{value_as_odin(type_node.dim)}]{inner}"
        else:
            return f"[^]{inner}"

    elif isinstance(type_node, c_ast.TypeDecl):
        t = type_node.type
        if isinstance(t, c_ast.IdentifierType):
            return odin_typename(' '.join(t.names))
        elif isinstance(t, c_ast.Struct):
            return odin_typename(t.name)
        else:
            raise Exception(f"Unhandled type decl type: {type(t)}")

    elif isinstance(type_node, c_ast.FuncDecl):
        ret_type = type_as_odin(type_node.type)
        ret = f" -> {ret_type}" if ret_type != 'void' else ''

        params = ', '.join(
            f"#c_vararg args: ..any"
            if isinstance(param, c_ast.EllipsisParam)
            else f"{odin_id(param.name)}: {type_as_odin(param.type)}"

            for param in param_list(type_node.args)
        )
        return f'#type proc "c" ({params}){ret}'

    elif isinstance(type_node, c_ast.Union):
        fields = '\n'.join(
            f"\t\t{field.name}: {type_as_odin(field.type)},"
            for field in type_node.decls
        )
        return f"struct #raw_union {{\n{fields}\n\t}}"

    raise Exception(f"Unhandled {type(type_node)} at {type_node.coord}")


TYPE_MAP = {
    'ImS8': 'i8',
    'ImU8': 'u8',
    'ImS16': 'i16',
    'ImU16': 'u16',
    'ImS32': 'i32',
    'ImU32': 'u32',
    'ImS64': 'i64',
    'ImU64': 'u64',
    'bool': 'bool',
    'unsigned int': 'u32',
    'int': 'i32',
    'unsigned short': 'u16',
    'char': 'i8',
    'signed char': 'i8',
    'unsigned char': 'u8',
    'short': 'i16',
    'float': 'f32',
    'double': 'f64',
    'ImWchar': 'u16',
    'ImWchar16': 'u16',
    'ImWchar32': 'rune',
    'ImBitArrayPtr': 'rawptr',
    'ImVec1': '[1]f32',
    'ImVec2': '[2]f32',
    'ImVec3': '[3]f32',
    'ImVec4': '[4]f32',
    'ImVec2ih': '[2]i16',
    'size_t': 'int',
    'va_list': '^libc.va_list',
}

for k, v in list(TYPE_MAP.items()):
    if ' ' in k:
        TYPE_MAP[k.replace(' ', '_')] = v


def odin_typename(name: str) -> str:
    if name in TYPE_MAP:
        return TYPE_MAP[name]

    if name.startswith('ImVector_'):
        _, elem = name.split('_', 1)

        if elem.endswith('Ptr'):
            return f"Vector(^{odin_typename(elem[:-3])})"
        elif elem.endswith('PPtr'):
            return f"Vector(^^{odin_typename(elem[:-4])})"

        return f"Vector({odin_typename(elem)})"

    elif name.startswith('ImSpan_'):
        _, elem = name.split('_', 1)
        return f"Span({odin_typename(elem)})"

    return '_'.join(camel_split(trim_type_prefix(name)))


RESERVED_IDS = ['where', 'map', 'in', 'context', 'fmt']

def odin_id(name: str) -> str:
    base_id = '_'.join(map(str.lower, camel_split(name)))

    if base_id in RESERVED_IDS:
        return base_id + '_'

    return base_id


def odin_enumname(name: str) -> str:
    if '_' not in name:
        return '_no_name_'

    _, valname = name.split('_', 1)

    if not valname:
        return ''

    if valname[0].isnumeric():
        valname = '_' + valname
    return '_'.join(camel_split(valname))


def odin_procname(name: str) -> str:
    if name.startswith(('ImGui', 'Im')):  # is a method in the C++ ... probably
        classname, method = name.split('_', 1)

        if method.startswith(classname):  # is a constructor
            method = method.replace(classname, 'new', 1)

        all_chunks = camel_split(trim_type_prefix(classname)) + camel_split(trim_type_prefix(method))

        return '_'.join(map(str.lower, all_chunks)).replace('__', '_')

    elif name.startswith('ig'):
        name = name[2:]

    base_id = '_'.join(map(str.lower, camel_split(name))).replace('__', '_')

    if base_id in RESERVED_IDS:
        return base_id + '_'

    return base_id


def proc_overload_group(name: str) -> str:
    if name.startswith('ig') and name.count('_') >= 1:
        group, _ = name.split('_', 1)
        return odin_procname(group)

    elif name.startswith(('ImGui', 'Im')) and name.count('_') >= 2 and not name.endswith(('_begin', '_end')):
        typename, method, _ = name.split('_', 2)
        return odin_procname(f"{typename}_{method}")

    else:
        return odin_procname(name)


ACRONYMS = (
    'IO', 'ID', 'BEGIN', 'COUNT', 'SIZE', 'OSX', 'STB', 'RGB', 'RGBA', 'RGBA32', 'HSV',
    'NS', 'EW', 'NESW', 'NWSE', 'HSV', 'TL', 'TR', 'BL', 'BR', 'TTY', 'UV', 'TTF',
)


def camel_split(s: str) -> List[str]:
    def _is_part_of_acronym(start: int, idx: int):
        for acro in ACRONYMS:
            if s.startswith(acro, start) and idx - start < len(acro):
                return True
        return False

    result = []
    start = 0
    for i, c in enumerate(s):
        if c.isupper():
            if _is_part_of_acronym(start, i):
                continue
            result.append(s[start:i])
            start = i
    result.append(s[start:])
    if result[0] == '':
        result = result[1:]
    return result


def trim_type_prefix(s: str) -> str:
    if s.startswith('ImGui'):
        return s[5:]

    elif s.startswith('Im'):
        return s[2:]

    return s


def is_cimgui(ast_node) -> bool:
    if coord := getattr(ast_node, 'coord', None):
        return coord.file.endswith('cimgui.h')
    return False


def param_list(ast_node: c_ast.ParamList):
    return list(ast_node) if not is_empty_param_list(ast_node) else []


def is_empty_param_list(params: c_ast.ParamList) -> bool:
    assert isinstance(params, c_ast.ParamList)
    if len(params.params) > 1:
        return False

    if len(params.params) == 0:
        return True

    for only_param in params.params:
        return (
            only_param.name is None
            and isinstance(only_param.type, c_ast.TypeDecl)
            and isinstance(only_param.type.type, c_ast.IdentifierType)
            and only_param.type.type.names == ['void']
        )

    return False


def is_va_list(ast_node) -> bool:
    return (
        isinstance(ast_node, c_ast.Decl)
        and isinstance(ast_node.type, c_ast.TypeDecl)
        and isinstance(ast_node.type.type, c_ast.IdentifierType)
        and ast_node.type.type.names == ['va_list']
    )


def is_cstring(ast_node) -> bool:
    if not isinstance(ast_node, c_ast.PtrDecl):
        return False

    return (
        isinstance(ast_node.type, c_ast.TypeDecl)
        and isinstance(ast_node.type.type, c_ast.IdentifierType)
        and 'const' in ast_node.type.quals
        and 'char' in ast_node.type.type.names
    )


def is_string_span_pair(begin, end) -> bool:
    if begin is None or end is None:
        return False

    try:
        if not (is_cstring(begin.type) and is_cstring(end.type)):
            return False
    except AttributeError:
        return False

    begin_name = begin.name[:-6] if begin.name.endswith('_begin') else begin.name  # in python 3.9, use removesuffix instead

    return end.name.startswith(begin_name) and end.name.endswith('_end')


def is_slice_pair(ptr, length) -> bool:
    if ptr is None or length is None:
        return False

    try:
        if not isinstance(ptr.type, c_ast.PtrDecl):
            return False

        if is_cstring(ptr.type):
            return False

        if not (
            isinstance(length.type, c_ast.TypeDecl)
            and isinstance(length.type.type, c_ast.IdentifierType)
            and (
                'int' in length.type.type.names
                or 'size_t' in length.type.type.names
            )
        ):
            return False

    except AttributeError:
        return False

    base_name = re.sub("_?(?:ptr)$", '', ptr.name)

    return (
        length.name.startswith(base_name)
        and length.name.endswith(('_len', '_length', '_size', '_count'))
    )


def is_out_param(ast_node) -> bool:
    if not isinstance(ast_node, c_ast.Decl) or ast_node.name is None:
        return False

    if not (
        ast_node.name.startswith(('out_', 'Out'))
        or ast_node.name.endswith(('_out', 'Out'))
    ):
        return False

    return (
        isinstance(ast_node.type, c_ast.PtrDecl)
        and isinstance(ast_node.type.type, (c_ast.TypeDecl, c_ast.PtrDecl))
        and 'const' not in ast_node.type.type.quals
    )


def is_exported_proc(ast_node):
    return (
        isinstance(ast_node, c_ast.Decl)
        and isinstance(ast_node.type, c_ast.FuncDecl)
        and ast_node.name
        and '__' not in ast_node.name  # probably intended as private
        and (
            not ast_node.name.startswith(FUNC_PREFIX_BLACKLIST)
            or ast_node.name.startswith(FUNC_PREFIX_WHITELIST)
        )
    )


FUNC_PREFIX_BLACKLIST = (
    'igIm',
    'ImVec',
    'ImBitVector',
    'igGET',
    'igMemAlloc',
    'igMemFree',
    'imBitVector',
)

FUNC_PREFIX_WHITELIST = (
    'igImage',
    'igImFont',
    'igImBezier',
)


def deref(ast_node):
    if isinstance(ast_node, c_ast.TypeDecl):
        ast_node = ast_node.type

    assert isinstance(ast_node, c_ast.PtrDecl)

    return ast_node.type


if __name__ == '__main__':
    main()
