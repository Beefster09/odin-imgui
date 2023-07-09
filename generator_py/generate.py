import argparse
from pathlib import Path

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
    print({type(node) for node in header_ast})

    # print({type(node) for node in header_ast})
    generate_structs(header_ast)


def generate_structs(ast):
    with open(ODIN_DIR / 'structs.odin', 'w') as odin:
        for node in ast:
            if isinstance(node, c_ast.Typedef) and node.name == 'ImGuiStyle':
                node.show()


def generate_foreign(ast):
    ...


def generate_enums(ast):
    ...


def generate_wrapper(ast):
    ...


def is_cimgui(ast_node):
    if coord := getattr(ast_node, 'coord', None):
        return coord.file.endswith('cimgui.h')
    return False


if __name__ == '__main__':
    main()
