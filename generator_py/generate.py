import argparse
import io
import re
import sys
import textwrap
from collections import defaultdict
from pathlib import Path
from typing import Iterable

from pycparser import parse_file, c_ast

import models
from utils import *

THIS_DIR = Path(__file__).parent.absolute()
CIMGUI_DIR = THIS_DIR.parent / 'cimgui'
CPPIMGUI_DIR = CIMGUI_DIR / 'imgui'
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

    enums = []
    structs = []
    func_types = {}
    foreign_funcs = []
    overload_groups = defaultdict(list)

    class V(c_ast.NodeVisitor):
        def visit_Enum(self, node: c_ast.Enum, name: str | None):
            enums.append(models.CEnum.from_ast(node, name))

        def visit_Struct(self, node: c_ast.Struct):
            if node.decls is None:
                return

            if node.name.startswith(('ImVec', 'ImSpan_', 'ImBitArray_')):
                return

            structs.append(models.CStruct.from_ast(node))

        def visit_Typedef(self, typedef: c_ast.Typedef):
            if isinstance(typedef.type, c_ast.TypeDecl) and isinstance(typedef.type.type, c_ast.Enum):
                    return self.visit_Enum(typedef.type.type, typedef.name)
            elif isinstance(typedef.type, c_ast.PtrDecl) and isinstance(typedef.type.type, c_ast.FuncDecl):
                func_types[typedef.name] = models.ast_to_type(typedef.type.type)
            else:
                return self.generic_visit(typedef)

    for node in header_ast:
        if not is_cimgui(node):
            continue

        if (
            isinstance(node, c_ast.Decl)
            and 'extern' in node.storage
            and isinstance(node.type, c_ast.FuncDecl)
        ):
            if not (
                '__' not in node.name  # probably intended as private
                and (
                    not node.name.startswith(FUNC_PREFIX_BLACKLIST)
                    or node.name.startswith(FUNC_PREFIX_WHITELIST)
                )
                and node.name not in FUNC_BLACKLIST
            ):
                continue

            func = models.CFunc.from_ast(node)

            if func.params and func.params[-1].type == models.NamedCType('va_list'):
                continue

            overload_groups[proc_overload_group(func.name)].append(func)
            foreign_funcs.append(func)

        else:
            V().visit(node)
            # try:
            # except TypeError:
            #     pass

    types = {}

    # for struct in structs:
    #     types[odin_typename(struct.name)] = struct

    for enum in enums:
        types[odin_typename(enum.name)] = enum

    with open(CPPIMGUI_DIR / 'imgui.h') as fp:
        scrape_cpp_for_defaults(fp, 'primary', overload_groups)

    with open(CPPIMGUI_DIR / 'imgui_internal.h') as fp:
        scrape_cpp_for_defaults(fp, 'internal', overload_groups)

    overload_groups['text_buffer_appendf'][0].fmtarg_idx = 1  # special case; not in cpp header

    generate_types(func_types, enums, structs)
    generate_foreign(foreign_funcs, types)
    generate_wrapper(overload_groups, types)


FUNC_BLACKLIST = [
    'igMemAlloc',
    'igMemFree',
    'igPushID_Str',  # should use _StrStr variant
    'igGetID_Str',   # should use _StrStr variant
]

FUNC_PREFIX_BLACKLIST = (
    'igIm',
    'ImVec',
    'ImBitVector',
    'igGET',
    'imBitVector',
)

FUNC_PREFIX_WHITELIST = (
    'igImage',
    'igImFont',
    'igImBezier',
)


def generate_types(
    func_types: dict[str, models.FuncCType],
    enums: list[models.CEnum],
    structs: list[models.CStruct],
):
    with open(ODIN_DIR / 'types_gen.odin', 'w') as fp:
        write_header(fp)

        fp.write("\n// === Function Types ===\n\n")

        for name, proctype in func_types.items():
            fp.write(f"{odin_typename(name)} :: {proctype.as_odin()}\n")

        fp.write("\n// === Enums ===\n\n")

        enums.sort(key=lambda e: (int(e.is_flags), e.name))

        for enum in enums:
            typename = odin_typename(enum.name)
            if typename.endswith('_Private'):
                continue

            if enum.is_flags:
                fp.write(f"{typename} :: bit_set[{typename}_; u32]\n")
                fp.write(f"{typename}_ :: enum {{\n")

                base_flags = []

                for name, value in enum.members.items():
                    if isinstance(value, models.FlagValue):
                        base_flags.append(name)
                        fp.write(f"\t{odin_enumname(name)} = {value.flag},\n")

                fp.write('}\n')

                # non-flag values

                for name, value in enum.members.items():
                    if isinstance(value, models.FlagValue):
                        continue
                    elif value == 0:
                        fp.write(f"{typename}_{odin_enumname(name)} :: {typename}{{}}\n")
                    elif isinstance(value, models.Bits):
                        fp.write(f"{typename}_{odin_enumname(name)} :: {typename}{value.as_flags()}\n")
                    elif isinstance(value, models.MultiFlag):
                        base = []
                        composite = []
                        for flag in value.flags:
                            if flag in base_flags:
                                base.append('.' + odin_enumname(flag))
                            else:
                                composite.append(f"{typename}_{odin_enumname(flag)}")
                        parts = [f"{typename}{{ {', '.join(base)} }}"] if base else []
                        if composite:
                            parts.append(' | '.join(composite))
                        fp.write(f"{typename}_{odin_enumname(name)} :: {' | '.join(parts)}\n")

                fp.write('\n')

            else:
                fp.write(f"{typename} :: enum {{\n")

                external_values = []

                for name, value in enum.members.items():
                    if not name.startswith(enum.name):
                        external_values.append((name, value))
                    elif value is None:
                        fp.write(f"\t{odin_enumname(name)},\n")
                    else:
                        fp.write(f"\t{odin_enumname(name)} = {str(value).replace(f'{typename}.', '')},\n")

                fp.write("}\n")

                for name, value in external_values:
                    fp.write(f"{name} :: {value}\n")

                fp.write('\n')

        fp.write("\n// === Structs ===\n\n")

        for struct in structs:
            fp.write(f"{odin_typename(struct.name)} :: struct {{\n")

            for i, (name, typ) in enumerate(struct.fields):
                fieldname = odin_id(name) if name else f'_{i}_'
                using = 'using ' if name is None else ''
                fp.write(f"\t{using}{fieldname}: {typ.as_odin()},\n")

            fp.write("}\n\n")


def generate_foreign(funcs: Iterable[models.CFunc], types: dict):
    with open(ODIN_DIR / 'foreign_gen.odin', 'w') as fp:
        write_header(fp)
        fp.write(textwrap.dedent("""
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

        for func in funcs:

            odin_params = []

            # TODO: fix defaults

            for i, param in enumerate(func.params):
                prev_param = func.params[i - 1] if i > 0 else None

                if is_string_span_pair(prev_param, param):
                    odin_params[-1:] = [
                        f"{odin_id(prev_param.name)}: [^]u8",
                        f"{odin_id(param.name)}: [^]u8",
                    ]

                else:
                    odin_params.append(param.as_odin(types))

            if func.has_vararg:
                odin_params.append("#c_vararg _args_: ..any")

            if func.ret_type:
                ret = f" -> {func.ret_type.as_odin()}"
            else:
                ret = ''

            fp.write(f'\t@(link_name = "{func.name}")\n')
            fp.write(f"\t{func.odin_name} :: proc({', '.join(odin_params)}){ret} ---\n")

        fp.write("}\n")


def generate_wrapper(overloads: dict[str, list[models.CFunc]], types: dict):
    with open(ODIN_DIR / 'wrapper_gen.odin', 'w') as fp:
        write_header(fp)
        fp.write(textwrap.dedent('''
            import "core:fmt"
            import "core:strings"

        '''))

        for group, funcs in overloads.items():
            if len(funcs) > 1:
                fp.write(f"{group} :: proc {{\n")
                for func in funcs:
                    fp.write(f"\t{odin_procname(func.name)},\n")
                fp.write("}\n")

            for func in funcs:
                in_params = []
                call_args = []
                multiple_returns = []

                setup_lines = []

                needs_wrapper = False

                for i, param in enumerate(func.params):
                    prev_param = func.params[i - 1] if i > 0 else None
                    pname = odin_id(param.name)

                    if param.is_out():
                        needs_wrapper = True
                        multiple_returns.append(
                            f"{pname}: {param.type.to.as_odin()}"
                        )
                        call_args.append(f"&{pname}")

                    elif func.has_vararg and i == func.fmtarg_idx:
                        needs_wrapper = True
                        in_params.append(f"{pname}: string")
                        call_args.append('"%s"')
                        setup_lines += [
                            "_fmt_sb := strings.builder_make(context.temp_allocator)",
                            f"fmt.sbprintf(&_fmt_sb, {pname}, .._args_)",
                            "append(&_fmt_sb.buf, 0)",
                        ]

                    elif is_string_span_pair(prev_param, param):
                        needs_wrapper = True
                        new_pname = odin_id(prev_param.name.removesuffix('_begin'))
                        in_params[-1] = f"{new_pname}: string"
                        call_args[-1:] = [
                            f"raw_data({new_pname})",
                            f"cast([^]u8) (uintptr(raw_data({new_pname})) + uintptr(len({new_pname})))",
                        ]

                    elif is_slice_pair(prev_param, param) and prev_param and not prev_param.is_out():
                        needs_wrapper = True
                        pname = odin_id(re.sub(r"_(?:len(?:gth)?|size|count)$", '', param.name))
                        len_type = param.type.as_odin()
                        in_params[-1] = f"{pname}: []{prev_param.type.to.as_odin()}"
                        call_args[-1:] = [
                            f"raw_data({pname})",
                            f"{f'cast({len_type})' * (len_type != 'int')}len({pname})",
                        ]

                    elif param.type.is_cstring():
                        needs_wrapper = True
                        if param.default == 'nil':
                            in_params.append(f'{pname}: string = ""')
                        elif param.default is not None:
                            in_params.append(f'{pname}: string = {param.default}')
                        else:
                            in_params.append(f"{pname}: string")
                        call_args.append(f"semisafe_string_to_cstring({pname})")

                    else:
                        in_params.append(param.as_odin(types))
                        call_args.append(pname)

                if func.has_vararg:
                    in_params.append('_args_: ..any')
                    call_args.append('cstring(raw_data(_fmt_sb.buf))')

                if needs_wrapper:
                    if multiple_returns:
                        if func.ret_type:
                            multiple_returns.insert(0, f"orig_ret: {func.ret_type.as_odin()}")
                        returns = f" -> ({', '.join(multiple_returns)})"
                    elif func.ret_type:
                        returns = f" -> {func.ret_type.as_odin()}"
                    else:
                        returns = ''

                    fp.write(f"{odin_procname(func.name)} :: proc({', '.join(in_params)}){returns} {{\n")

                    for line in setup_lines:
                        fp.write(f"\t{line}\n")

                    fp.write('\t')

                    if multiple_returns and func.ret_type:
                        fp.write("orig_ret = ")
                    elif func.ret_type:
                        fp.write("return ")

                    fp.write(f"{func.odin_name}({', '.join(call_args)})\n")

                    if multiple_returns:
                        fp.write("\treturn\n")

                    fp.write('}\n')

                else:
                    fp.write(f"{odin_procname(func.name)} :: {func.odin_name}\n")

            fp.write('\n')


def write_header(fp):
    fp.write(textwrap.dedent(f"""
        // GENERATED FILE; DO NOT EDIT
        // this file was generated by generator_v2/{Path(__file__).name}

        package imgui

    """))


def scrape_cpp_for_defaults(
    fp,
    header: str,
    overload_groups: dict[str, list[models.CFunc]],
):
    context = None, None
    disable_level = 0
    for line in fp:

        if line.startswith('#ifndef IMGUI_DISABLE_OBSOLETE'):
            disable_level += 1
            continue
        if disable_level > 0:
            if line.startswith('#endif'):
                disable_level -= 1
            continue

        elif match := re.match(r'(struct|namespace)\s+(?:IMGUI_API\s+)?(\w+)', line):
            context = match[1], match[2]

        elif match := re.match(r'\s*IMGUI_API\s.*?\s(~?\w+)\((.*?)\)\s*(?:IM_FMT(?:ARGS|LIST)\((\d+)\))?(?:const)?;', line):
            match context:
                case ('namespace', 'ImGui'):
                    c_name = 'ig' + match[1]
                case ('struct', struct_name):
                    if match[1].startswith('~'):
                        c_name = f"{struct_name}_destroy"
                    else:
                        c_name = f"{struct_name}_{match[1]}"
                case _:
                    continue

            params = bracket_aware_split(match[2])

            defaults: list[str | None] = []
            argnames: list[str] = []
            if context[0] == 'struct': # is a method
                defaults = [None]
                argnames = ['self']

            for param in params:
                if '=' in param:
                    cdecl, default = param.split('=', maxsplit=1)
                    defaults.append(cpp_to_odin(default))
                    argnames.append(cpp_argname(cdecl))
                elif param and '...' not in param:
                    defaults.append(None)
                    argnames.append(cpp_argname(param))

            # find the right func in the overload group
            ffunc = None
            ogroup = proc_overload_group(c_name)
            # print(ogroup, [proc.name for proc in overload_groups[ogroup]])
            if ogroup in overload_groups:
                if len(overload_groups[ogroup]) == 1:
                    ffunc = overload_groups[ogroup][0]
                else:
                    ffunc = match_overload(overload_groups[ogroup], argnames)

            if ffunc is None:
                continue

            if ffunc.cpp_header is not None:
                raise Exception(f"{c_name}({', '.join(argnames)}) was already enriched with cpp header data")

            if ffunc.params and ffunc.params[0].name == 'pOut':
                defaults.insert(0, None)

            for param, default in zip(ffunc.params, defaults):
                param.default = default
            ffunc.cpp_header = header
            if match[3] is not None:
                ffunc.fmtarg_idx = int(match[3]) - int(context[0] == 'namespace')


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


def is_cimgui(ast_node) -> bool:
    if coord := getattr(ast_node, 'coord', None):
        return coord.file.endswith('cimgui.h')
    return False


def match_overload(funcs: list[models.CFunc], argnames: list[str]):
    for func in funcs:
        if func.cpp_header is not None:  # assumption: overloads are in the same order
            continue

        if len(func.params) == len(argnames) and all(arg.name == argname for arg, argname in zip(func.params, argnames)):
            return func

    return None


def is_string_span_pair(begin: models.CParam | None, end: models.CParam | None) -> bool:
    if begin is None or end is None:
        return False

    try:
        if not (begin.type.is_cstring() and end.type.is_cstring()):
            return False
    except AttributeError:
        return False

    begin_name = begin.name.removesuffix('_begin')  # in python 3.9, use removesuffix instead

    return end.name.startswith(begin_name) and end.name.endswith('_end')


def is_slice_pair(ptr: models.CParam | None, length: models.CParam | None) -> bool:
    if ptr is None or length is None:
        return False

    if not (
        isinstance(ptr.type, models.PtrCType)
        and isinstance(length.type, models.NamedCType)
        and length.type.name in (
            'int', 'size_t',
            'ImS8', 'ImU8',
            'ImS16', 'ImS16',
            'ImS32', 'ImS32',
            'ImS64', 'ImS64',
        )
    ):
        return False

    base_name = re.sub("_?(?:ptr)$", '', ptr.name)

    return (
        length.name.startswith(base_name)
        and length.name.endswith(('_len', '_length', '_size', '_count'))
    )


if __name__ == '__main__':
    main()
