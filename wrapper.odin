package imgui

import "core:fmt"
import "core:strings"


text :: proc(fmt_: string, _args_: ..any) {
	_fmt_sb := strings.builder_make(context.temp_allocator)
	fmt.sbprintf(&_fmt_sb, fmt_, .._args_)
	text_unformatted(strings.to_string(_fmt_sb))
}

font_atlas_add_font_from_memory_ttf :: proc(
	self: ^Font_Atlas,
	font_data: []u8,
	size_pixels: f32,
	font_config: ^Font_Config = nil,
	glyph_ranges: [][2]u16 = nil,
) -> ^Font {
	glyph_ranges_array: []u16
	if glyph_ranges != nil {
		glyph_ranges_array = make([]u16, len(glyph_ranges) * 2 + 1, context.temp_allocator)
		for range, i in glyph_ranges {
			glyph_ranges_array[2*i + 0] = range[0]
			glyph_ranges_array[2*i + 1] = range[1]
		}
		glyph_ranges_array[len(glyph_ranges) * 2] = 0
	}
	return FontAtlas_AddFontFromMemoryTTF(self, raw_data(font_data), i32(len(font_data)),
		size_pixels, font_config, raw_data(glyph_ranges_array))
}

font_atlas_add_font_from_memory_compressed_ttf :: proc(
	self: ^Font_Atlas,
	font_data: []u8,
	size_pixels: f32,
	font_config: ^Font_Config = nil,
	glyph_ranges: [][2]u16 = nil,
) -> ^Font {
	glyph_ranges_array: []u16
	if glyph_ranges != nil {
		glyph_ranges_array = make([]u16, len(glyph_ranges) * 2 + 1, context.temp_allocator)
		for range, i in glyph_ranges {
			glyph_ranges_array[2*i + 0] = range[0]
			glyph_ranges_array[2*i + 1] = range[1]
		}
		glyph_ranges_array[len(glyph_ranges) * 2] = 0
	}
	return FontAtlas_AddFontFromMemoryCompressedTTF(self, raw_data(font_data), i32(len(font_data)),
		size_pixels, font_config, raw_data(glyph_ranges_array))
}
