package imgui

import "core:strings"


semisafe_string_to_cstring :: proc(s: string) -> cstring {
    if raw_data(s)[len(s)] == '\x00' {
        // NOTE: this can segfault if the string is exactly at the end of addressible memory space
        return strings.unsafe_string_to_cstring(s)
    } else {
        return strings.clone_to_cstring(s, context.temp_allocator)
    }
}
