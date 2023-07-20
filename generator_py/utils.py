import re

from pycparser import c_ast


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
    'ImBitArrayPtr': '[^]u8',
    'ImVec1': '[1]f32',
    'ImVec2': '[2]f32',
    'ImVec3': '[3]f32',
    'ImVec4': '[4]f32',
    'ImVec1ih': '[1]i16',
    'ImVec2ih': '[2]i16',
    'ImVec3ih': '[3]i16',
    'ImVec4ih': '[4]i16',
    'size_t': 'int',
    'va_list': '^libc.va_list',
}
for k, v in list(TYPE_MAP.items()):
    if ' ' in k:
        TYPE_MAP[k.replace(' ', '_')] = v


def odin_typename(name: str) -> str:
    if name in TYPE_MAP:
        return TYPE_MAP[name]

    name = name.rstrip('_')

    if name.startswith('ImVector_'):
        _, elem = name.split('_', 1)

        if elem.endswith('PPtr'):
            return f"Vector(^^{odin_typename(elem[:-4])})"

        elif elem.endswith('Ptr'):
            return f"Vector(^{odin_typename(elem[:-3])})"

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


def cpp_to_odin(expr: str) -> str:
    expr = expr.strip()\
        .replace('FLT_MIN', 'min(f32)')\
        .replace('FLT_MAX', 'max(f32)')\
        .replace('sizeof(float)', 'size_of(f32)')

    if expr in ('NULL', 'nullptr'):
        return 'nil'

    if match := re.match(r'ImVec\w+\((.*)\)', expr):
        return f"{{{', '.join(map(cpp_to_odin, match[1].split(',')))}}}"

    if match := re.match(r'([-+]?\d+\.\d+)f', expr):
        return match[1]

    return re.sub(r'IM_([A-Z_]+)', r'\1', expr)


def cpp_argname(argdecl: str) -> str:
    argdecl = argdecl.strip()
    if match := re.fullmatch(r'(?:\w+[&*]*\s+)*(\w+)(?:\[.*\])?', argdecl):  # simple types
        return match[1]
    elif match := re.fullmatch(r'(?:\w+[&*]*\s*)*\(\*(\w+)\)\(.*\)', argdecl):  # func pointer
        return match[1]
    elif match := re.fullmatch(r'\w+\<.+?\>\**\s+(\w+)', argdecl):  # template type
        return match[1]
    else:
        raise ValueError(argdecl)


ACRONYMS = (
    'IO', 'ID', 'BEGIN', 'END', 'COUNT', 'SIZE', 'OFFSET', 'OSX', 'STB',
    'RGB', 'RGBA', 'RGBA32', 'HSV', 'TTY', 'UV', 'TTF',
    'NS', 'EW', 'NESW', 'NWSE', 'TL', 'TR', 'BL', 'BR',
)


def camel_split(s: str) -> list[str]:
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
            result.append(s[start:i].rstrip('_'))
            start = i
    result.append(s[start:].rstrip('_'))
    if result[0] == '':
        result = result[1:]
    return result


def bracket_aware_split(s: str) -> list[str]:
    result = []
    start = 0
    bracket_stack = []
    for i, c in enumerate(s):
        if (x := '({['.find(c)) >= 0:
            bracket_stack.append(')}]'[x])
        elif bracket_stack:
            if c == bracket_stack[-1]:
                bracket_stack.pop()
        elif c == ',':
            result.append(s[start:i])
            start = i + 1
    result.append(s[start:])
    return result


def trim_type_prefix(s: str) -> str:
    if s.startswith('ImGui'):
        return s[5:]

    elif s.startswith('Im'):
        return s[2:]

    return s
