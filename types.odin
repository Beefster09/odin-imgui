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
