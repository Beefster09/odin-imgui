package imgui

Texture_ID :: distinct uintptr
File_Handle :: distinct uintptr

ID :: distinct u32
Key_Chord :: distinct i32
Draw_Idx :: u16
Table_Column_Idx :: i16
Table_Draw_Channel_Idx :: u16
Pool_Idx :: i32
Key_Routing_Index :: i16

Items_Getter_Proc :: #type proc "c" (data: rawptr, idx: i32, out_text: ^cstring) -> bool
Value_Getter_Proc :: #type proc "c" (data: rawptr, idx: i32) -> f32

Vector :: struct(T : typeid) {
    size:     i32, 
    capacity: i32,
    data:     [^]T,
}

Span :: struct(T : typeid) {
    data:     [^]T,
    data_end: [^]T,
}

COL32_WHITE :: u32(0xFF_FFFFFF)
COL32_BLACK :: u32(0xFF_000000)

Font_Glyph :: struct {
    codepoint_and_flags: u32,
    advance_x: f32,
    x0: f32,
    y0: f32,
    x1: f32,
    y1: f32,
    u0: f32,
    v0: f32,
    u1: f32,
    v1: f32,
}

Dock_Request :: struct{ /* OPAQUE */ }
Dock_Node_Settings :: struct{ /* OPAQUE */ }
