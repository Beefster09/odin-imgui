import argparse
from pathlib import Path
import re
import sys
from typing import List

from pycparser import parse_file, c_ast


THIS_DIR = Path(__file__).parent.absolute()
CIMGUI_DIR = THIS_DIR.parent / 'cimgui'
ODIN_DIR = THIS_DIR.parent


def main():
    header_ast = parse_file(
        CIMGUI_DIR / 'cimgui.h',
        use_cpp=True,
        cpp_args= [
            '-DCIMGUI_DEFINE_ENUMS_AND_STRUCTS',
            '-DCIMGUI_NO_EXPORT',
            '-D_WIN32',  # hack to force no declspec
            '-isystem', str(THIS_DIR / 'fake_libc')
        ],
    )

    header_ast = [
        node for node in header_ast
        if is_cimgui(node)
    ]

    generate_structs(header_ast)
    generate_enums(header_ast)
    # generate_structs(header_ast)
    # generate_structs(header_ast)


def generate_structs(ast):
    class SV(c_ast.NodeVisitor):
        def __init__(self, fp):
            self.fp = fp

        def visit_Struct(self, struct: c_ast.Struct):
            if struct.decls is None:
                return

            if struct.name.startswith(('ImVec', 'ImSpan_', 'BitArray_')):
                return

            self.fp.write(f"{odin_typename(struct.name)} :: struct {{\n")
            for i, decl in enumerate(struct.decls):
                using = '' if decl.name is not None else 'using '
                field_name = odin_id(decl.name or f'_field_{i}')
                self.fp.write(f"\t{using}{field_name}: {type_as_odin(decl.type)},\n")
            self.fp.write("}\n\n")

    with open(ODIN_DIR / 'structs.odin', 'w') as fp:
        fp.write("package imgui\n\n")
        sv = SV(fp)
        for node in ast:
            sv.visit(node)


def generate_foreign(ast):
    ...


def generate_enums(ast):
    ...


def generate_wrapper(ast):
    ...


def value_as_odin(value_node) -> str:
    if isinstance(value_node, c_ast.ID):
        return value_node.name

    elif isinstance(value_node, c_ast.Constant):
        return value_node.value

    elif isinstance(value_node, c_ast.BinaryOp):
        return f"({value_as_odin(value_node.left)} {value_node.op} {value_as_odin(value_node.right)})"

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
    'unsigned int': 'i32',
    'short': 'i16',
    'float': 'f32',
    'double': 'f64',
    'unsigned char': 'u8',
    'ImWchar': 'u16',
    'ImVec1': '[1]f32',
    'ImVec2': '[2]f32',
    'ImVec3': '[3]f32',
    'ImVec4': '[4]f32',
    'ImVec2ih': '[2]i16',
}


def odin_typename(name: str) -> str:
    if name in TYPE_MAP:
        return TYPE_MAP[name]

    if name.startswith('ImVector_'):
        _, elem = name.split('_', 1)
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
    return '_'.join(map(str.lower, camel_split(name)))


ACRONYMS = 'IO', 'ID', 'BEGIN', 'COUNT', 'SIZE', 'OSX', 'STB', 'RGB', 'RGBA'


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
