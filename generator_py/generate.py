import argparse
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
    # generate_structs(header_ast)
    # generate_structs(header_ast)


class TypegenVisitor(c_ast.NodeVisitor):
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

        elif type_name.endswith(('Flags_', 'Cond_')):
            composite_flags = []

            self.fp.write(f"\n{type_name} :: enum {{\n")

            for flag in enum.values:
                flag_name = odin_enumname(flag.name)

                # TODO: handle ImGuiTableFlags

                if isinstance(flag.value, c_ast.BinaryOp) and flag.value.op == '<<':
                    assert isinstance(flag.value.left, c_ast.Constant)
                    assert isinstance(flag.value.right, c_ast.Constant)
                    if flag.value.left.value == '1':
                        self.fp.write(f"\t{flag_name} = {flag.value.right.value},\n")
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

                class CV(c_ast.NodeVisitor):  # quick and dirty hack that makes assumptions
                    def visit_ID(self, ident: c_ast.ID):
                        bit_set_values.append('.' + odin_enumname(ident.name))

                CV().visit(flag)

                self.fp.write(f"{odin_typename(ename)}_{odin_id(vname).upper()} :: {bit_set_name}{{ {', '.join(bit_set_values)} }}\n")

        else:
            # TODO: handle ImGuiMod_ constants in ImGuiKey_ enum correctly

            special_enum_values = []
            enum_typename = odin_typename(type_name)

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

            for enum_value in special_enum_values:
                enum_name = odin_enumname(enum_value.name)

                if enum_name == 'COUNT':
                    if last_value is None:
                        self.fp.write(f"{enum_value.name} :: len({enum_typename})\n")
                    else:
                        self.fp.write(f"{enum_value.name} :: {last_value + 1}\n")
                else:
                    assert enum_value.value is not None, f"Unhandled {type(enum_value)} at {enum_value.coord}"
                    self.fp.write(f"{enum_value.name} :: {value_as_odin(enum_value.value)}\n")

    def visit_Typedef(self, typedef: c_ast.Typedef):
        if (
            isinstance(typedef.type, c_ast.TypeDecl)
            and isinstance(typedef.type.type, c_ast.IdentifierType)
            and typedef.name not in TYPE_MAP
        ):
            if typedef.name.endswith(('Flags', 'Cond')):
                self.fp.write(f"{odin_typename(typedef.name)} :: bit_set[{typedef.name}_; u32]\n")
            else:
                self.fp.write(f"{odin_typename(typedef.name)} :: distinct {type_as_odin(typedef.type)}\n")
        elif (
            isinstance(typedef.type, c_ast.TypeDecl)
            and isinstance(typedef.type.type, c_ast.Enum)
        ):
            self.visit_Enum(typedef.type.type, typedef.name)
        else:
            return self.generic_visit(typedef)

def generate_types(ast):
    with open(ODIN_DIR / 'types_gen.odin', 'w') as fp:
        write_header(fp)
        visitor = TypegenVisitor(fp)
        for node in ast:
            visitor.visit(node)


def generate_foreign(ast):
    ...


def generate_enums(ast):
    ...


def generate_wrapper(ast):
    ...


def write_header(fp):
    fp.write(textwrap.dedent(f"""
        // GENERATED FILE; DO NOT EDIT
        // this file was generated by generator_v2/{Path(__file__).name}

        package imgui


    """))


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
        inner = type_as_odin(type_node.type)
        if inner == 'void':
            return 'rawptr'
        elif inner in ('unsigned char', 'char'):
            return 'cstring'
        elif inner.startswith('proc'):  # HACK: would break on pointer to function pointer
            return inner
        else:
            return f"^{inner}"

    elif isinstance(type_node, c_ast.ArrayDecl):
        inner = type_as_odin(type_node.type)
        return f"[{value_as_odin(type_node.dim)}]{inner}"

    elif isinstance(type_node, c_ast.TypeDecl):
        t = type_node.type
        if isinstance(t, c_ast.IdentifierType):
            return odin_typename(' '.join(t.names))
        else:
            raise Exception(f"Unhandled type decl type: {type(t)}")

    elif isinstance(type_node, c_ast.FuncDecl):
        ret_type = type_as_odin(type_node.type)
        ret = f" -> {ret_type}" if ret_type != 'void' else ''
        params = ', '.join(
            f"{odin_id(param.name)}: {type_as_odin(param.type)}"
            for param in type_node.args
        )
        return f'proc "c" ({params}){ret}'

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
    'ImVec1': '[1]f32',
    'ImVec2': '[2]f32',
    'ImVec3': '[3]f32',
    'ImVec4': '[4]f32',
    'ImVec2ih': '[2]i16',
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

    elif name.startswith('ImGui'):
        name = name[5:]

    elif name.startswith('Im'):
        name = name[2:]

    return '_'.join(camel_split(name))


def odin_id(name: str) -> str:
    base_id = '_'.join(map(str.lower, camel_split(name)))

    if base_id in ('where', 'map'):
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


ACRONYMS = 'IO', 'ID', 'BEGIN', 'COUNT', 'SIZE', 'OSX', 'STB', 'RGB', 'RGBA', 'NS', 'EW', 'NESW', 'NWSE', 'HSV'


def camel_split(s: str) -> List[str]:
    result = []
    start = 0
    for i, c in enumerate(s):
        if c.isupper():
            if s[start:].startswith(ACRONYMS) and s[start:i] not in ACRONYMS:
                continue
            result.append(s[start:i])
            start = i
    result.append(s[start:])
    if result[0] == '':
        result = result[1:]
    return result


def is_cimgui(ast_node):
    if coord := getattr(ast_node, 'coord', None):
        return coord.file.endswith('cimgui.h')
    return False


if __name__ == '__main__':
    main()
