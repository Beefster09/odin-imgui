import re
from dataclasses import dataclass, field
from typing import Optional, Self, Union

from pycparser import c_ast

from utils import *


@dataclass
class NamedCType:
    name: str
    is_const: bool = False

    def as_odin(self) -> str:
        return odin_typename(self.name)

    def is_cstring(self) -> bool:
        return False

@dataclass
class PtrCType:
    to: 'AnyCType'
    is_const: bool = False
    array_hint: bool = False

    def as_odin(self) -> str:
        if self.array_hint:
            return '[^]' + self.to.as_odin()
        elif self.is_cstring():
            return 'cstring'
        elif isinstance(self.to, NamedCType) and self.to.name == 'void':
            return 'rawptr'
        else:
            return '^' + self.to.as_odin()

    def is_cstring(self) -> bool:
        return (
            isinstance(self.to, NamedCType)
            and self.to.name == 'char'
            and (self.is_const or self.to.is_const)
        )


@dataclass
class ArrayCType:  # fixed array; non-fixed arrays are actually pointers in C
    of: 'AnyCType'
    count: c_ast.Node | int
    is_const: bool = False

    def as_odin(self) -> str:
        return f"[{odin_expr(self.count)}]{self.of.as_odin()}"

    def is_cstring(self) -> bool:
        return False


@dataclass
class FuncCType:
    ret_type: Optional['AnyCType']
    params: list['CParam']

    def as_odin(self) -> str:
        return f"""#type proc "c"({
            ', '.join(
                f"{param.name}: {param.type.as_odin()}"
                for param in self.params
            )
        }){f' -> {self.ret_type.as_odin()}' if self.ret_type else ''}"""

    def is_cstring(self) -> bool:
        return False


@dataclass
class UnionCType:
    orig_name: str | None
    fields: list[tuple[str, 'AnyCType']]

    def as_odin(self) -> str:
        inner = ''.join([
            f"\t\t{name}: {typ.as_odin()},\n"
            for name, typ in self.fields
        ])
        return f"struct #raw_union {{\n{inner}\t}}"

    def is_cstring(self) -> bool:
        return False


AnyCType = NamedCType | ArrayCType | PtrCType | FuncCType | UnionCType

STRUCTURED_TYPES: dict[str, AnyCType] = {
    'ImBitArrayPtr': PtrCType(NamedCType('ImU8'), array_hint=True),
    'ImVec1': ArrayCType(NamedCType('float'), 1),
    'ImVec2': ArrayCType(NamedCType('float'), 2),
    'ImVec3': ArrayCType(NamedCType('float'), 3),
    'ImVec4': ArrayCType(NamedCType('float'), 4),
    'ImVec1ih': ArrayCType(NamedCType('ImS16'), 1),
    'ImVec2ih': ArrayCType(NamedCType('ImS16'), 2),
    'ImVec3ih': ArrayCType(NamedCType('ImS16'), 3),
    'ImVec4ih': ArrayCType(NamedCType('ImS16'), 4),
}


def ast_to_type(node: c_ast.Node) -> AnyCType:
    if isinstance(node, c_ast.IdentifierType):
        name = ' '.join(node.names)
        if name in STRUCTURED_TYPES:
            return STRUCTURED_TYPES[name]
        return NamedCType(name)

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
                params.append(CVarArgs())
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
    default: str | None = None

    def is_out(self) -> bool:
        if not (
            self.name.startswith(('out_', 'Out'))
            or self.name.endswith(('_out', 'Out'))
        ):
            return False

        return (
            isinstance(self.type, PtrCType)
            and not self.type.to.is_const
        )

    def as_odin(self, types: dict[str, Union['CStruct', 'CEnum']]) -> str:
        name = odin_id(self.name)
        typename = self.type.as_odin()
        if self.default:
            if isinstance(self.type, NamedCType) and typename in types:
                return f"{name}: {typename} = {types[typename].value_as_odin(self.default)}"

            return f"{name}: {typename} = {self.default}"
        else:
            return f"{name}: {typename}"


@dataclass
class _VA:
    def as_odin(self):
        return "..any"


@dataclass
class CVarArgs:
    name: str = '#c_vararg _args_'
    type: _VA = field(default_factory=_VA)

    def is_out(self):
        return False

    def as_odin(self):
        return "#c_vararg _args_: ..any"


@dataclass(kw_only=True)
class CFunc:
    name: str
    odin_name: str
    ret_type: AnyCType | None
    params: list[CParam]
    has_vararg: bool = False
    fmtarg_idx: int | None = None
    cpp_header: str | None = None

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
            if match[1] == match[2]:
                odin_name = f"{match[1]}_new"
            else:
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

    def __str__(self):
        return f"1 << {self.flag}"


@dataclass
class Bits:
    value: int
    shift: int

    def __str__(self):
        return f"{self.value} << {self.shift}"

    def as_flags(self):
        flagbits = []
        for i, bit in enumerate(reversed(bin(self.value))):
            if bit == '1':
                flagbits.append(f".Bit{self.shift + i}")
        return f"{{ {', '.join(flagbits)} }}"


@dataclass
class MultiFlag:
    flags: list[str]

    def __str__(self):
        return ' | '.join(self.flags)


@dataclass
class Mask:
    hexvalue: str

    def __str__(self):
        return self.hexvalue


@dataclass
class Expr:
    expr_node: str

    def __str__(self):
        return odin_expr(self.expr_node)


@dataclass
class CEnum:
    name: str
    members: dict[str, int | FlagValue | Bits | Mask | MultiFlag | Expr | None]
    is_flags: bool = False

    @classmethod
    def from_ast(cls, node: c_ast.Enum, name: str) -> Self:
        enum = cls(node.name or name, {})

        bits_groups: dict[int, Bits] = {}
        prev_member = None
        for member in node.values:
            value = cls._value(member.value)
            enum.members[member.name] = value

            if isinstance(value, FlagValue) and member.name.startswith(enum.name):
                enum.is_flags = True

            if isinstance(value, Bits):
                if isinstance(prev_flag := enum.members[prev_member], FlagValue):
                    enum.members[prev_member] = b = Bits(1, prev_flag.flag)
                    bits_groups[value.shift] = [b]
                bits_groups[value.shift].append(value)

            prev_member = member.name

        for shift, values in bits_groups.items():
            bits_needed = max(v.value.bit_length() for v in values)
            for i in range(bits_needed):
                enum.members[f"{enum.name.rstrip('_')}_Bit{shift + i}"] = FlagValue(shift + i)

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

        elif isinstance(value, c_ast.UnaryOp):
            if value.op == '-':
                inner = cls._value(value.expr)
                if isinstance(inner, int):
                    return -inner

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

        return Expr(value)

    def value_as_odin(self, cpp_value: str):
        if cpp_value.isdigit():
            int_value = int(cpp_value)
            if self.is_flags:
                flags = []
                for i, bit in enumerate(reversed(bin(int_value))):
                    if bit == '1':
                        for name, value in self.members.items():
                            if isinstance(value, FlagValue) and value.flag == i:
                                flags.append('.' + odin_enumname(name))
                                break
                return f"{{ {', '.join(flags)} }}"
            else:
                for name, value in self.members.items():
                    if value == int_value:
                        return '.' + odin_enumname(name)
        else:
            if self.is_flags and cpp_value.endswith('_None'):
                return '{}'
            elif self.is_flags:
                return f"{{ .{odin_enumname(cpp_value)} }}"
            else:
                return '.' + odin_enumname(cpp_value)


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

    if isinstance(value_node, int):
        return str(value_node)

    elif isinstance(value_node, c_ast.ID):
        ident: str = value_node.name
        if '_' in ident:
            _, suffix = ident.rsplit('_', 1)
            if suffix.isupper():
                enum, _ = ident.split('_', 1)
                return f"{odin_typename(enum)}.{odin_enumname(ident)}"

        return value_node.name

    elif isinstance(value_node, c_ast.Constant):
        return value_node.value

    elif isinstance(value_node, c_ast.BinaryOp):
        return f"({odin_expr(value_node.left)} {value_node.op} {odin_expr(value_node.right)})"

    elif isinstance(value_node, c_ast.UnaryOp):
        return f"({value_node.op}{odin_expr(value_node.expr)})"

    raise Exception(f"Unhandled {type(value_node)} at {value_node.coord}")
