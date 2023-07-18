from dataclasses import dataclass
from typing import Self

from pycparser import c_ast


@dataclass
class NamedCType:
    name: str
    is_const: bool = False


@dataclass
class PtrCType:
    to: 'AnyCType'
    is_const: bool = False
    array_hint: bool = False


@dataclass
class ArrayCType:  # fixed array; non-fixed arrays are actually pointers in C
    of: 'AnyCType'
    count: c_ast.Node
    is_const: bool = False


@dataclass
class FuncCType:
    ret_type: 'AnyCType'
    params: list['CParam']
    has_vararg: bool = False


@dataclass
class UnionCType:
    orig_name: str | None
    fields: list[tuple[str, 'AnyCType']]


AnyCType = NamedCType | ArrayCType | PtrCType | FuncCType | UnionCType


def ast_to_type(node: c_ast.Node) -> AnyCType:
    if isinstance(node, c_ast.IdentifierType):
        return NamedCType(' '.join(node.names))

    if isinstance(node, c_ast.Struct):
        return NamedCType(node.name)

    elif isinstance(node, c_ast.PtrDecl):
        return PtrCType(ast_to_type(node.type), 'const' in node.quals)

    elif isinstance(node, c_ast.ArrayDecl):
        if node.dim:
            return ArrayCType(ast_to_type(node.type), node.dim)
        else:
            return PtrCType(ast_to_type(node.type), array_hint=True)

    elif isinstance(node, c_ast.FuncDecl):
        params: list[CParam] = []
        va = False
        for param in node.args:
            if isinstance(param, c_ast.EllipsisParam):
                va = True
            else:
                params.append(CParam(param.name, ast_to_type(param.type)))

        return FuncCType(ast_to_type(node.type), params, va)

    elif isinstance(node, c_ast.TypeDecl):
        return ast_to_type(node.type)

    elif isinstance(node, c_ast.Union):
        return UnionCType(node.name, [
            (field.name, ast_to_type(field.type))
            for field in node
        ])

    else:
        raise TypeError(f"Unsupported node type: {type(node).__qualname__}")


@dataclass
class CParam:
    name: str
    type: AnyCType


@dataclass(kw_only=True)
class ForeignFunc:
    name: str
    ret_type: AnyCType
    params: list[CParam]
    has_vararg: bool = False

    @classmethod
    def from_ast(cls, decl: c_ast.Decl) -> Self:
        if not isinstance(decl.type, c_ast.FuncDecl):
            raise TypeError(decl)

        params: list[CParam] = []
        va = False
        for param in decl.type.args:
            if isinstance(param, c_ast.EllipsisParam):
                va = True
            else:
                params.append(CParam(param.name, ast_to_type(param.type)))

        if len(params) == 1 and params[0].type == NamedCType('void'):
            params = []

        return cls(
            name=decl.name,
            ret_type=ast_to_type(decl.type.type),
            params=params,
            has_vararg=va,
        )

@dataclass
class FlagValue:
    flag: int


@dataclass
class Bits:
    value: int
    shift: int


@dataclass
class MultiFlag:
    flags: list[str]


@dataclass
class Mask:
    hexvalue: str


@dataclass
class CEnum:
    none: str | None
    members: list[tuple[str, int | FlagValue | Bits | Mask | MultiFlag | None]]

    @classmethod
    def from_ast(cls, node: c_ast.Enum) -> Self:
        enum = cls(node.name, [])

        for member in node.values:
            enum.members.append((member.name, cls._value(member.value)))

        return enum

    @classmethod
    def _value(cls, value: c_ast.Node | None):
        if value is None:
            return None

        elif isinstance(value, c_ast.Constant):
            if value.value.startswith('0x'):
                return Mask(value.value)
            else:
                return int(value.value)

        elif isinstance(value, c_ast.BinaryOp):
            if value.op == '<<':
                assert isinstance(value.left, c_ast.Constant)
                assert isinstance(value.right, c_ast.Constant)
                if value.left.value == '1':
                    return FlagValue(int(value.right.value))
                else:
                    return Bits(int(value.left.value), int(value.right.value))

            elif value.op == '|':
                flags: list[str] = []

                def _walk(value: c_ast.Node):
                    if isinstance(value, c_ast.ID):
                        flags.append(value.name)
                    elif isinstance(value, c_ast.BinaryOp) and value.op == '|':
                        _walk(value.left)
                        _walk(value.right)
                    else:
                        raise TypeError(value)

                _walk(value.left)
                _walk(value.right)
                return MultiFlag(flags)


@dataclass
class CStruct:
    name: str
    fields: list[tuple[str | None, AnyCType]]

    @classmethod
    def from_ast(cls, struct: c_ast.Struct):
        return cls(struct.name, [
            (field.name, ast_to_type(field.type))
            for field in struct
        ])
