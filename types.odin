package imgui

Texture_ID :: distinct rawptr

File_Handle :: distinct uintptr

Context_Hook_Callback :: #type proc "c" (ctx: ^Context, hook: ^Context_Hook)
Error_Log_Callback :: #type proc "c" (user_data: rawptr, fmt: cstring, #c_vararg args: ..any)
Draw_Callback :: #type proc "c" (parent_list: ^Draw_List, cmd: ^Draw_Cmd)
Input_Text_Callback :: #type proc "c" (data: ^Input_Text_Callback_Data) -> int
Size_Callback :: #type proc "c" (data: ^Size_Callback_Data)

Alloc_Func :: #type proc "c" (size: i64, user_data: rawptr) -> rawptr
Free_Func :: #type proc "c" (ptr: rawptr, user_data: rawptr)

Mem_Alloc_Func :: #type proc "c" (size: i64, user_data: rawptr) -> rawptr
Mem_Free_Func :: #type proc "c" (ptr: rawptr, user_data: rawptr)

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

