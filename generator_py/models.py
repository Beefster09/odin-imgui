import re
from dataclasses import dataclass
from typing import Optional, Self

from pycparser import c_ast

from utils import *


@dataclass
class NamedCType:
    name: str
    is_const: bool = False

    def as_odin(self) -> str:
        return odin_typename(self.name)

@dataclass
class PtrCType:
    to: 'AnyCType'
    is_const: bool = False
    array_hint: bool = False

    def as_odin(self) -> str:
        if self.array_hint:
            return '[^]' + self.to.as_odin()
        elif isinstance(self.to, NamedCType) and self.to.name == 'char':
            return 'cstring'
        elif isinstance(self.to, NamedCType) and self.to.name == 'void':
            return 'rawptr'
        else:
            return '^' + self.to.as_odin()


@dataclass
class ArrayCType:  # fixed array; non-fixed arrays are actually pointers in C
    of: 'AnyCType'
    count: c_ast.Node
    is_const: bool = False

    def as_odin(self) -> str:
        return f"[{odin_expr(self.count)}]{self.of.as_odin()}"


@dataclass
class FuncCType:
    ret_type: Optional['AnyCType']
    params: list['CParam']

    def as_odin(self) -> str:
        return f"""#type proc({
            ', '.join(
                f"{param.name}: {param.type.as_odin()}"
                for param in self.params
            )
        }){f' -> {self.ret_type.as_odin()}' if self.ret_type else ''}"""


@dataclass
class UnionCType:
    orig_name: str | None
    fields: list[tuple[str, 'AnyCType']]

    def as_odin(self) -> str:
        return f"""struct #raw_union {{ {
            ', '.join([
                f"{name}: {typ.as_odin()}"
                for name, typ in self.fields
            ])
        } }}"""


AnyCType = NamedCType | ArrayCType | PtrCType | FuncCType | UnionCType


def ast_to_type(node: c_ast.Node) -> AnyCType:
    if isinstance(node, c_ast.IdentifierType):
        return NamedCType(' '.join(node.names))

    if isinstance(node, c_ast.Struct):
        return NamedCType(node.name)

    elif isinstance(node, c_ast.PtrDecl):
        if isinstance(node.type, c_ast.FuncDecl):
            return ast_to_type(node.type)
        else:
            return PtrCType(ast_to_type(node.type), 'const' in node.quals)

    elif isinstance(node, c_ast.ArrayDecl):
        if node.dim:
            return ArrayCType(ast_to_type(node.type), node.dim)
        else:
            return PtrCType(ast_to_type(node.type), array_hint=True)

    elif isinstance(node, c_ast.FuncDecl):
        params: list[CParam] = []
        for param in node.args:
            if isinstance(param, c_ast.EllipsisParam):
                raise TypeError(param)
            else:
                params.append(CParam(param.name, ast_to_type(param.type)))

        ret_type = ast_to_type(node.type)

        if isinstance(ret_type, NamedCType) and ret_type.name == 'void':
            return FuncCType(None, params)
        else:
            return FuncCType(ret_type, params)

    elif isinstance(node, c_ast.TypeDecl):
        typ = ast_to_type(node.type)
        if hasattr(typ, 'is_const'):
            typ.is_const = 'const' in node.quals

        return typ

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
    odin_name: str
    ret_type: AnyCType | None
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

        ret_type = ast_to_type(decl.type.type)
        if isinstance(ret_type, NamedCType) and ret_type.name == 'void':
            ret_type = None

        odin_name = decl.name.removeprefix('ig')
        if match := re.match(r'^Im(?:Gui)?([A-Z][A-Za-z]*)_(?:Im(?:Gui)?)?(.*)$', odin_name):
            odin_name = f"{match[1]}_{match[2]}"

        return cls(
            name=decl.name,
            odin_name=odin_name,
            ret_type=ret_type,
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


def odin_expr(value_node) -> str:
    assert value_node is not None

    if isinstance(value_node, c_ast.ID):
        return value_node.name

    elif isinstance(value_node, c_ast.Constant):
        return value_node.value

    elif isinstance(value_node, c_ast.BinaryOp):
        return f"({odin_expr(value_node.left)} {value_node.op} {odin_expr(value_node.right)})"

    elif isinstance(value_node, c_ast.UnaryOp):
        return f"({value_node.op}{odin_expr(value_node.expr)})"

    raise Exception(f"Unhandled {type(value_node)} at {value_node.coord}")
