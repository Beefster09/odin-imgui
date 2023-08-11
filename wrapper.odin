package imgui

import "core:fmt"
import "core:strings"


text :: proc(fmt_: string, _args_: ..any) {
	_fmt_sb := strings.builder_make(context.temp_allocator)
	fmt.sbprintf(&_fmt_sb, fmt_, .._args_)
	text_unformatted(strings.to_string(_fmt_sb))
}
