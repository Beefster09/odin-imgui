package imgui_impl_glfw

import "core:runtime"
import "core:strings"

import glfw "vendor:glfw"

import imgui "../.."


// cursor constants from GLFW 3.4
GLFW_RESIZE_NWSE_CURSOR :: 0x00036007
GLFW_RESIZE_NESW_CURSOR :: 0x00036008
GLFW_RESIZE_ALL_CURSOR  :: 0x00036009
GLFW_NOT_ALLOWED_CURSOR :: 0x0003600A


@private
state: GLFW_State

GLFW_State :: struct {
    window: glfw.WindowHandle,
    time: f64,
    mouse_just_pressed: [len(imgui.IO{}.mouse_down)]bool,
    mouse_cursors: [imgui.Mouse_Cursor_COUNT]glfw.CursorHandle,
    installed_callbacks: bool,
    prev_user_callback_mouse_button: glfw.MouseButtonProc,
    prev_user_callback_scroll: glfw.ScrollProc,
    prev_user_callback_key: glfw.KeyProc,
    prev_user_callback_char: glfw.CharProc,
}

setup_state :: proc(window: glfw.WindowHandle, install_callbacks: bool) {
    state.window = window
    state.time = 0.0

    io := imgui.get_io()
    io.backend_flags |= {.Has_Mouse_Cursors, .Has_Set_Mouse_Pos}
    io.backend_platform_name = "GLFW"

    io.key_map[imgui.Key.Tab]         = i32(glfw.KEY_TAB)
    io.key_map[imgui.Key.Left_Arrow]   = i32(glfw.KEY_LEFT)
    io.key_map[imgui.Key.Right_Arrow]  = i32(glfw.KEY_RIGHT)
    io.key_map[imgui.Key.Up_Arrow]     = i32(glfw.KEY_UP)
    io.key_map[imgui.Key.Down_Arrow]   = i32(glfw.KEY_DOWN)
    io.key_map[imgui.Key.Page_Up]      = i32(glfw.KEY_PAGE_UP)
    io.key_map[imgui.Key.Page_Down]    = i32(glfw.KEY_PAGE_DOWN)
    io.key_map[imgui.Key.Home]        = i32(glfw.KEY_HOME)
    io.key_map[imgui.Key.End]         = i32(glfw.KEY_END)
    io.key_map[imgui.Key.Insert]      = i32(glfw.KEY_INSERT)
    io.key_map[imgui.Key.Delete]      = i32(glfw.KEY_DELETE)
    io.key_map[imgui.Key.Backspace]   = i32(glfw.KEY_BACKSPACE)
    io.key_map[imgui.Key.Space]       = i32(glfw.KEY_SPACE)
    io.key_map[imgui.Key.Enter]       = i32(glfw.KEY_ENTER)
    io.key_map[imgui.Key.Escape]      = i32(glfw.KEY_ESCAPE)
    io.key_map[imgui.Key.Keypad_Enter] = i32(glfw.KEY_KP_ENTER)
    for i in 0..<26 {
        io.key_map[int(imgui.Key.A) + i] = i32(glfw.KEY_A + i)
    }
    for i in 0..=9 {
        io.key_map[int(imgui.Key._0) + i] = i32(glfw.KEY_0 + i)
        io.key_map[int(imgui.Key.Keypad0) + i] = i32(glfw.KEY_KP_0 + i)
    }
    for i in 0..<12 {
        io.key_map[int(imgui.Key.F1) + i] = i32(glfw.KEY_F1 + i)
    }

    io.get_clipboard_text_fn = get_clipboard_text
    io.set_clipboard_text_fn = set_clipboard_text
    io.clipboard_user_data = state.window

    when ODIN_OS == .Windows {
        // io.ime_window_handle = rawptr(glfw.GetWin32Window(state.window))
    }

    prev_error_callback: glfw.ErrorProc = glfw.SetErrorCallback(nil)

    state.mouse_cursors[imgui.Mouse_Cursor.Arrow]      = glfw.CreateStandardCursor(glfw.ARROW_CURSOR)
    state.mouse_cursors[imgui.Mouse_Cursor.Text_Input]  = glfw.CreateStandardCursor(glfw.IBEAM_CURSOR)
    state.mouse_cursors[imgui.Mouse_Cursor.Resize_NS]   = glfw.CreateStandardCursor(glfw.VRESIZE_CURSOR)
    state.mouse_cursors[imgui.Mouse_Cursor.Resize_EW]   = glfw.CreateStandardCursor(glfw.HRESIZE_CURSOR)
    state.mouse_cursors[imgui.Mouse_Cursor.Hand]       = glfw.CreateStandardCursor(glfw.HAND_CURSOR)

    if version_maj, version_min, _ := glfw.GetVersion(); version_maj > 3 || version_maj == 3 && version_min >= 4 {
        state.mouse_cursors[imgui.Mouse_Cursor.Resize_All]  = glfw.CreateStandardCursor(GLFW_RESIZE_ALL_CURSOR)
        state.mouse_cursors[imgui.Mouse_Cursor.Resize_NESW] = glfw.CreateStandardCursor(GLFW_RESIZE_NESW_CURSOR)
        state.mouse_cursors[imgui.Mouse_Cursor.Resize_NWSE] = glfw.CreateStandardCursor(GLFW_RESIZE_NWSE_CURSOR)
        state.mouse_cursors[imgui.Mouse_Cursor.Not_Allowed] = glfw.CreateStandardCursor(GLFW_NOT_ALLOWED_CURSOR)
    } else {
        state.mouse_cursors[imgui.Mouse_Cursor.Resize_All]  = glfw.CreateStandardCursor(glfw.ARROW_CURSOR)
        state.mouse_cursors[imgui.Mouse_Cursor.Resize_NESW] = glfw.CreateStandardCursor(glfw.ARROW_CURSOR)
        state.mouse_cursors[imgui.Mouse_Cursor.Resize_NWSE] = glfw.CreateStandardCursor(glfw.ARROW_CURSOR)
        state.mouse_cursors[imgui.Mouse_Cursor.Not_Allowed] = glfw.CreateStandardCursor(glfw.ARROW_CURSOR)
    }

    glfw.SetErrorCallback(prev_error_callback)

    state.prev_user_callback_mouse_button = nil
    state.prev_user_callback_scroll       = nil
    state.prev_user_callback_key          = nil
    state.prev_user_callback_char         = nil

    if (install_callbacks)
    {
        state.installed_callbacks = true
        state.prev_user_callback_mouse_button = glfw.SetMouseButtonCallback(window, mouse_button_callback)
        state.prev_user_callback_scroll       = glfw.SetScrollCallback(window, scroll_callback)
        state.prev_user_callback_key          = glfw.SetKeyCallback(window, key_callback)
        state.prev_user_callback_char         = glfw.SetCharCallback(window, char_callback)
    }
}

update_mouse :: proc() {
    io := imgui.get_io()

    for i in 0..<len(io.mouse_down) {
        io.mouse_down[i] = state.mouse_just_pressed[i] || glfw.GetMouseButton(state.window, i32(i)) != glfw.RELEASE
        state.mouse_just_pressed[i] = false
    }

    mouse_pos_backup := io.mouse_pos
    io.mouse_pos = { min(f32), min(f32) }

    if glfw.GetWindowAttrib(state.window, glfw.FOCUSED) != 0 {
        if io.want_set_mouse_pos && mouse_pos_backup.x >= 0 && mouse_pos_backup.y >= 0 {
            glfw.SetCursorPos(state.window, f64(mouse_pos_backup.x), f64(mouse_pos_backup.y))
        } else {
            x, y := glfw.GetCursorPos(state.window)
            io.mouse_pos = { f32(x), f32(y) }
        }
    }

    if .No_Mouse_Cursor_Change in io.config_flags {
        desired_cursor := imgui.get_mouse_cursor()
        if(io.mouse_draw_cursor || desired_cursor == .None) {
            glfw.SetInputMode(state.window, glfw.CURSOR, glfw.CURSOR_HIDDEN)
        } else {
            new_cursor: glfw.CursorHandle
            if state.mouse_cursors[desired_cursor] != nil {
                new_cursor = state.mouse_cursors[desired_cursor]
            } else {
                new_cursor = state.mouse_cursors[imgui.Mouse_Cursor.Arrow]
            }
            glfw.SetCursor(state.window, new_cursor)
            glfw.SetInputMode(state.window, glfw.CURSOR, glfw.CURSOR_NORMAL)
        }
    }
}

update_display_size :: proc() {
    w, h := glfw.GetWindowSize(state.window)
    io := imgui.get_io()
    io.display_size = { f32(w), f32(h) }
    if w > 0 && h > 0 {
        display_w, display_h := glfw.GetFramebufferSize(state.window)
        io.display_framebuffer_scale = { f32(display_w) / f32(w), f32(display_h) / f32(h) }
    }
}

update_dt :: proc() {
    io := imgui.get_io()
    now := glfw.GetTime()
    io.delta_time = state.time > 0.0 ? f32(now - state.time) : f32(1.0/60.0)
    state.time = now
}

@private
get_clipboard_text :: proc "c" (user_data: rawptr) -> cstring
{
    context = runtime.default_context()
    s := glfw.GetClipboardString(glfw.WindowHandle(user_data))
    return strings.unsafe_string_to_cstring(s)
}

@private
set_clipboard_text :: proc "c" (user_data: rawptr, text: cstring)
{
    context = runtime.default_context()
    glfw.SetClipboardString(glfw.WindowHandle(user_data), text)
}

@private
key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
    context = runtime.default_context()

    if (state.prev_user_callback_key != nil) {
        state.prev_user_callback_key(window, key, scancode, action, mods)
    }

    io := imgui.get_io()

    if      action == i32(glfw.PRESS)   do io.keys_down[key] = true
    else if action == i32(glfw.RELEASE) do io.keys_down[key] = false

    io.key_ctrl  = io.keys_down[glfw.KEY_LEFT_CONTROL] || io.keys_down[glfw.KEY_RIGHT_CONTROL]
    io.key_shift = io.keys_down[glfw.KEY_LEFT_SHIFT] || io.keys_down[glfw.KEY_RIGHT_SHIFT]
    io.key_alt   = io.keys_down[glfw.KEY_LEFT_ALT] || io.keys_down[glfw.KEY_RIGHT_ALT]

    when ODIN_OS == .Windows {
        io.key_super = false
    } else {
        io.key_super = io.keys_down[glfw.KEY_LEFT_SUPER] || io.keys_down[glfw.KEY_RIGHT_SUPER]
    }
}

@private
mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
    context = runtime.default_context()

    if (state.prev_user_callback_mouse_button != nil) {
        state.prev_user_callback_mouse_button(window, button, action, mods)
    }

    if action == i32(glfw.PRESS) && button >= 0 && button < len(state.mouse_just_pressed) {
        state.mouse_just_pressed[button] = true
    }
}

@private
scroll_callback :: proc "c" (window: glfw.WindowHandle, xoffset, yoffset: f64) {
    context = runtime.default_context()

    if (state.prev_user_callback_scroll != nil) {
        state.prev_user_callback_scroll(window, xoffset, yoffset)
    }

    io := imgui.get_io()
    io.mouse_wheel_h += f32(xoffset)
    io.mouse_wheel   += f32(yoffset)
}

@private
char_callback :: proc "c" (window: glfw.WindowHandle, codepoint: rune) {
    context = runtime.default_context()

    if (state.prev_user_callback_char != nil) {
        state.prev_user_callback_char(window, codepoint)
    }

    imgui.io_add_input_character(imgui.get_io(), u32(codepoint))
}
