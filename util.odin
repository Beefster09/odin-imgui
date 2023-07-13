package imgui

import "core:log"
import "core:runtime"
import "core:strings"
import "core:slice"


semisafe_string_to_cstring :: proc(s: string) -> cstring {
    if raw_data(s)[len(s)] == '\x00' {
        // NOTE: this can segfault if the string is exactly at the end of addressible memory space
        return strings.unsafe_string_to_cstring(s)
    } else {
        return strings.clone_to_cstring(s, context.temp_allocator)
    }
}


vector_to_slice :: #force_inline proc(vec: Vector($T)) -> []T {
    return slice.from_ptr(vec.data, int(vec.size))
}


@(deferred_out=_free)
use_current_odin_context :: proc() -> rawptr {
    ctx := new(runtime.Context)
    ctx^ = context

    set_allocator_functions(_alloc_wrapper, _free_wrapper, ctx)

    return ctx
}

@(private="file")
_free :: proc (mem: rawptr) {
    runtime.mem_free(mem)
}

@private
_alloc_wrapper :: proc "c" (size: i64, ctx_raw: rawptr) -> rawptr {
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
