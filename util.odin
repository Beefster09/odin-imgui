package imgui

import "core:log"
import "core:runtime"
import "core:strings"


semisafe_string_to_cstring :: proc(s: string) -> cstring {
    if len(s) == 0 {
        return nil
    } else if raw_data(s)[len(s)] == '\x00' {
        // NOTE: this can segfault if the string is exactly at the end of addressible memory space
        return strings.unsafe_string_to_cstring(s)
    } else {
        return strings.clone_to_cstring(s, context.temp_allocator)
    }
}

vector_to_slice :: #force_inline proc(vec: Vector($T)) -> []T {
    return from_ptr(vec.data, int(vec.size))
}

draw_list_add_closure :: proc(dl: ^Draw_List, data: $T, $cb: #type proc(data: ^T, dl: ^Draw_List, cmd: ^Draw_Cmd)) {
    _data_with_context :: struct {
        ctx: runtime.Context,
        data: T,
    }

    _wrapper :: proc "c" (dl: ^Draw_List, cmd: ^Draw_Cmd) {
        dwc := cast(^_data_with_context) cmd.user_callback_data
        context = dwc.ctx
        cb(&dwc.data, dl, cmd)
    }

    dwc := new(_data_with_context, context.temp_allocator)
    dwc.data = data
    dwc.ctx = context

    draw_list_add_callback(dl, _wrapper, dwc)
}

@(deferred_out=_cleanup_context)
use_current_odin_context :: proc() -> rawptr {
    ctx := new(runtime.Context)
    ctx^ = context

    set_allocator_functions(_alloc_wrapper, _free_wrapper, ctx)

    return ctx
}

@(private="file")
_cleanup_context :: proc (mem: rawptr) {
    runtime.mem_free(mem)
}

@private
_alloc_wrapper :: proc "c" (size: int, ctx_raw: rawptr) -> rawptr {
    context = (cast(^runtime.Context) ctx_raw)^
    mem, err := runtime.mem_alloc(int(size))
    if err != .None {
        log.errorf("failed to allocate %d bytes for ImGUI (Error: %s)", size, err)
        return nil
    }
    return raw_data(mem)
}

@private
_free_wrapper :: proc "c" (data: rawptr, ctx_raw: rawptr) {
    context = (cast(^runtime.Context) ctx_raw)^
    err := runtime.mem_free(data)
    if err != .None {
        log.errorf("failed to free %p for ImGUI (Error: %s)", data, err)
    }
}
