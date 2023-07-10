package imgui

Col :: distinct i32
Cond :: bit_set[ImGuiCond_; u32]
Data_Type :: distinct i32
Dir :: distinct i32
Mouse_Button :: distinct i32
Mouse_Cursor :: distinct i32
Sort_Direction :: distinct i32
Style_Var :: distinct i32
Table_Bg_Target :: distinct i32
Draw_Flags :: bit_set[ImDrawFlags_; u32]
Draw_List_Flags :: bit_set[ImDrawListFlags_; u32]
Font_Atlas_Flags :: bit_set[ImFontAtlasFlags_; u32]
Backend_Flags :: bit_set[ImGuiBackendFlags_; u32]
Button_Flags :: bit_set[ImGuiButtonFlags_; u32]
Color_Edit_Flags :: bit_set[ImGuiColorEditFlags_; u32]
Config_Flags :: bit_set[ImGuiConfigFlags_; u32]
Combo_Flags :: bit_set[ImGuiComboFlags_; u32]
Drag_Drop_Flags :: bit_set[ImGuiDragDropFlags_; u32]
Focused_Flags :: bit_set[ImGuiFocusedFlags_; u32]
Hovered_Flags :: bit_set[ImGuiHoveredFlags_; u32]
Input_Text_Flags :: bit_set[ImGuiInputTextFlags_; u32]
Key_Chord :: distinct i32
Popup_Flags :: bit_set[ImGuiPopupFlags_; u32]
Selectable_Flags :: bit_set[ImGuiSelectableFlags_; u32]
Slider_Flags :: bit_set[ImGuiSliderFlags_; u32]
Tab_Bar_Flags :: bit_set[ImGuiTabBarFlags_; u32]
Tab_Item_Flags :: bit_set[ImGuiTabItemFlags_; u32]
Table_Flags :: bit_set[ImGuiTableFlags_; u32]
Table_Column_Flags :: bit_set[ImGuiTableColumnFlags_; u32]
Table_Row_Flags :: bit_set[ImGuiTableRowFlags_; u32]
Tree_Node_Flags :: bit_set[ImGuiTreeNodeFlags_; u32]
Viewport_Flags :: bit_set[ImGuiViewportFlags_; u32]
Window_Flags :: bit_set[ImGuiWindowFlags_; u32]
Draw_Idx :: distinct u16
ID :: distinct u32

ImGuiWindowFlags_ :: enum {
	No_Title_Bar = 0,
	No_Resize = 1,
	No_Move = 2,
	No_Scrollbar = 3,
	No_Scroll_With_Mouse = 4,
	No_Collapse = 5,
	Always_Auto_Resize = 6,
	No_Background = 7,
	No_Saved_Settings = 8,
	No_Mouse_Inputs = 9,
	Menu_Bar = 10,
	Horizontal_Scrollbar = 11,
	No_Focus_On_Appearing = 12,
	No_Bring_To_Front_On_Focus = 13,
	Always_Vertical_Scrollbar = 14,
	Always_Horizontal_Scrollbar = 15,
	Always_Use_Window_Padding = 16,
	No_Nav_Inputs = 18,
	No_Nav_Focus = 19,
	Unsaved_Document = 20,
	Nav_Flattened = 23,
	Child_Window = 24,
	Tooltip = 25,
	Popup = 26,
	Modal = 27,
	Child_Menu = 28,
}
Window_Flags_NO_NAV :: Window_Flags{ .No_Nav_Inputs, .No_Nav_Focus }
Window_Flags_NO_DECORATION :: Window_Flags{ .No_Title_Bar, .No_Resize, .No_Scrollbar, .No_Collapse }
Window_Flags_NO_INPUTS :: Window_Flags{ .No_Mouse_Inputs, .No_Nav_Inputs, .No_Nav_Focus }

ImGuiInputTextFlags_ :: enum {
	Chars_Decimal = 0,
	Chars_Hexadecimal = 1,
	Chars_Uppercase = 2,
	Chars_No_Blank = 3,
	Auto_Select_All = 4,
	Enter_Returns_True = 5,
	Callback_Completion = 6,
	Callback_History = 7,
	Callback_Always = 8,
	Callback_Char_Filter = 9,
	Allow_Tab_Input = 10,
	Ctrl_Enter_For_New_Line = 11,
	No_Horizontal_Scroll = 12,
	Always_Overwrite = 13,
	Read_Only = 14,
	Password = 15,
	No_Undo_Redo = 16,
	Chars_Scientific = 17,
	Callback_Resize = 18,
	Callback_Edit = 19,
	Escape_Clears_All = 20,
}

ImGuiTreeNodeFlags_ :: enum {
	Selected = 0,
	Framed = 1,
	Allow_Item_Overlap = 2,
	No_Tree_Push_On_Open = 3,
	No_Auto_Open_On_Log = 4,
	Default_Open = 5,
	Open_On_Double_Click = 6,
	Open_On_Arrow = 7,
	Leaf = 8,
	Bullet = 9,
	Frame_Padding = 10,
	Span_Avail_Width = 11,
	Span_Full_Width = 12,
	Nav_Left_Jumps_Back_Here = 13,
}
Tree_Node_Flags_COLLAPSING_HEADER :: Tree_Node_Flags{ .Framed, .No_Tree_Push_On_Open, .No_Auto_Open_On_Log }

ImGuiPopupFlags_ :: enum {
	No_Open_Over_Existing_Popup = 5,
	No_Open_Over_Items = 6,
	Any_Popup_Id = 7,
	Any_Popup_Level = 8,
}
Popup_Flags_ANY_POPUP :: Popup_Flags{ .Any_Popup_Id, .Any_Popup_Level }

ImGuiSelectableFlags_ :: enum {
	Dont_Close_Popups = 0,
	Span_All_Columns = 1,
	Allow_Double_Click = 2,
	Disabled = 3,
	Allow_Item_Overlap = 4,
}

ImGuiComboFlags_ :: enum {
	Popup_Align_Left = 0,
	Height_Small = 1,
	Height_Regular = 2,
	Height_Large = 3,
	Height_Largest = 4,
	No_Arrow_Button = 5,
	No_Preview = 6,
}
Combo_Flags_HEIGHT_MASK :: Combo_Flags{ .Height_Small, .Height_Regular, .Height_Large, .Height_Largest }

ImGuiTabBarFlags_ :: enum {
	Reorderable = 0,
	Auto_Select_New_Tabs = 1,
	Tab_List_Popup_Button = 2,
	No_Close_With_Middle_Mouse_Button = 3,
	No_Tab_List_Scrolling_Buttons = 4,
	No_Tooltip = 5,
	Fitting_Policy_Resize_Down = 6,
	Fitting_Policy_Scroll = 7,
}
Tab_Bar_Flags_FITTING_POLICY_MASK :: Tab_Bar_Flags{ .Fitting_Policy_Resize_Down, .Fitting_Policy_Scroll }

ImGuiTabItemFlags_ :: enum {
	Unsaved_Document = 0,
	Set_Selected = 1,
	No_Close_With_Middle_Mouse_Button = 2,
	No_Push_Id = 3,
	No_Tooltip = 4,
	No_Reorder = 5,
	Leading = 6,
	Trailing = 7,
}

ImGuiTableFlags_ :: enum {
	Resizable = 0,
	Reorderable = 1,
	Hideable = 2,
	Sortable = 3,
	No_Saved_Settings = 4,
	Context_Menu_In_Body = 5,
	Row_Bg = 6,
	Borders_Inner_H = 7,
	Borders_Outer_H = 8,
	Borders_Inner_V = 9,
	Borders_Outer_V = 10,
	No_Borders_In_Body = 11,
	No_Borders_In_Body_Until_Resize = 12,
	Sizing_Fixed_Fit = 13,
	// Sizing_Fixed_Same = (2 << 13), // Cannot represent cleanly :-/ 
	// Sizing_Stretch_Prop = (3 << 13), // Cannot represent cleanly :-/ 
	// Sizing_Stretch_Same = (4 << 13), // Cannot represent cleanly :-/ 
	No_Host_Extend_X = 16,
	No_Host_Extend_Y = 17,
	No_Keep_Columns_Visible = 18,
	Precise_Widths = 19,
	No_Clip = 20,
	Pad_Outer_X = 21,
	No_Pad_Outer_X = 22,
	No_Pad_Inner_X = 23,
	Scroll_X = 24,
	Scroll_Y = 25,
	Sort_Multi = 26,
	Sort_Tristate = 27,
}
Table_Flags_BORDERS_H :: Table_Flags{ .Borders_Inner_H, .Borders_Outer_H }
Table_Flags_BORDERS_V :: Table_Flags{ .Borders_Inner_V, .Borders_Outer_V }
Table_Flags_BORDERS_INNER :: Table_Flags{ .Borders_Inner_V, .Borders_Inner_H }
Table_Flags_BORDERS_OUTER :: Table_Flags{ .Borders_Outer_V, .Borders_Outer_H }
Table_Flags_BORDERS :: Table_Flags{ .Borders_Inner, .Borders_Outer }
Table_Flags_SIZING_MASK :: Table_Flags{ .Sizing_Fixed_Fit, .Sizing_Fixed_Same, .Sizing_Stretch_Prop, .Sizing_Stretch_Same }

ImGuiTableColumnFlags_ :: enum {
	Disabled = 0,
	Default_Hide = 1,
	Default_Sort = 2,
	Width_Stretch = 3,
	Width_Fixed = 4,
	No_Resize = 5,
	No_Reorder = 6,
	No_Hide = 7,
	No_Clip = 8,
	No_Sort = 9,
	No_Sort_Ascending = 10,
	No_Sort_Descending = 11,
	No_Header_Label = 12,
	No_Header_Width = 13,
	Prefer_Sort_Ascending = 14,
	Prefer_Sort_Descending = 15,
	Indent_Enable = 16,
	Indent_Disable = 17,
	Is_Enabled = 24,
	Is_Visible = 25,
	Is_Sorted = 26,
	Is_Hovered = 27,
	No_Direct_Resize_ = 30,
}
Table_Column_Flags_WIDTH_MASK :: Table_Column_Flags{ .Width_Stretch, .Width_Fixed }
Table_Column_Flags_INDENT_MASK :: Table_Column_Flags{ .Indent_Enable, .Indent_Disable }
Table_Column_Flags_STATUS_MASK :: Table_Column_Flags{ .Is_Enabled, .Is_Visible, .Is_Sorted, .Is_Hovered }

ImGuiTableRowFlags_ :: enum {
	Headers = 0,
}

Table_Bg_Target_ :: enum i32 {
	None = 0,
	Row_Bg0 = 1,
	Row_Bg1 = 2,
	Cell_Bg = 3,
}

ImGuiFocusedFlags_ :: enum {
	Child_Windows = 0,
	Root_Window = 1,
	Any_Window = 2,
	No_Popup_Hierarchy = 3,
}
Focused_Flags_ROOT_AND_CHILD_WINDOWS :: Focused_Flags{ .Root_Window, .Child_Windows }

ImGuiHoveredFlags_ :: enum {
	Child_Windows = 0,
	Root_Window = 1,
	Any_Window = 2,
	No_Popup_Hierarchy = 3,
	Allow_When_Blocked_By_Popup = 5,
	Allow_When_Blocked_By_Active_Item = 7,
	Allow_When_Overlapped = 8,
	Allow_When_Disabled = 9,
	No_Nav_Override = 10,
	Delay_Normal = 11,
	Delay_Short = 12,
	No_Shared_Delay = 13,
}
Hovered_Flags_RECT_ONLY :: Hovered_Flags{ .Allow_When_Blocked_By_Popup, .Allow_When_Blocked_By_Active_Item, .Allow_When_Overlapped }
Hovered_Flags_ROOT_AND_CHILD_WINDOWS :: Hovered_Flags{ .Root_Window, .Child_Windows }

ImGuiDragDropFlags_ :: enum {
	Source_No_Preview_Tooltip = 0,
	Source_No_Disable_Hover = 1,
	Source_No_Hold_To_Open_Others = 2,
	Source_Allow_Null_ID = 3,
	Source_Extern = 4,
	Source_Auto_Expire_Payload = 5,
	Accept_Before_Delivery = 10,
	Accept_No_Draw_Default_Rect = 11,
	Accept_No_Preview_Tooltip = 12,
}
Drag_Drop_Flags_ACCEPT_PEEK_ONLY :: Drag_Drop_Flags{ .Accept_Before_Delivery, .Accept_No_Draw_Default_Rect }

Data_Type_ :: enum i32 {
	S8,
	U8,
	S16,
	U16,
	S32,
	U32,
	S64,
	U64,
	Float,
	Double,
}
ImGuiDataType_COUNT :: len(Data_Type_)

Dir_ :: enum i32 {
	None = (-1),
	Left = 0,
	Right = 1,
	Up = 2,
	Down = 3,
}
ImGuiDir_COUNT :: len(Dir_)

Sort_Direction_ :: enum i32 {
	None = 0,
	Ascending = 1,
	Descending = 2,
}

Key :: enum i32 {
	None = 0,
	Tab = 512,
	Left_Arrow = 513,
	Right_Arrow = 514,
	Up_Arrow = 515,
	Down_Arrow = 516,
	Page_Up = 517,
	Page_Down = 518,
	Home = 519,
	End = 520,
	Insert = 521,
	Delete = 522,
	Backspace = 523,
	Space = 524,
	Enter = 525,
	Escape = 526,
	Left_Ctrl = 527,
	Left_Shift = 528,
	Left_Alt = 529,
	Left_Super = 530,
	Right_Ctrl = 531,
	Right_Shift = 532,
	Right_Alt = 533,
	Right_Super = 534,
	Menu = 535,
	_0 = 536,
	_1 = 537,
	_2 = 538,
	_3 = 539,
	_4 = 540,
	_5 = 541,
	_6 = 542,
	_7 = 543,
	_8 = 544,
	_9 = 545,
	A = 546,
	B = 547,
	C = 548,
	D = 549,
	E = 550,
	F = 551,
	G = 552,
	H = 553,
	I = 554,
	J = 555,
	K = 556,
	L = 557,
	M = 558,
	N = 559,
	O = 560,
	P = 561,
	Q = 562,
	R = 563,
	S = 564,
	T = 565,
	U = 566,
	V = 567,
	W = 568,
	X = 569,
	Y = 570,
	Z = 571,
	F1 = 572,
	F2 = 573,
	F3 = 574,
	F4 = 575,
	F5 = 576,
	F6 = 577,
	F7 = 578,
	F8 = 579,
	F9 = 580,
	F10 = 581,
	F11 = 582,
	F12 = 583,
	Apostrophe = 584,
	Comma = 585,
	Minus = 586,
	Period = 587,
	Slash = 588,
	Semicolon = 589,
	Equal = 590,
	Left_Bracket = 591,
	Backslash = 592,
	Right_Bracket = 593,
	Grave_Accent = 594,
	Caps_Lock = 595,
	Scroll_Lock = 596,
	Num_Lock = 597,
	Print_Screen = 598,
	Pause = 599,
	Keypad0 = 600,
	Keypad1 = 601,
	Keypad2 = 602,
	Keypad3 = 603,
	Keypad4 = 604,
	Keypad5 = 605,
	Keypad6 = 606,
	Keypad7 = 607,
	Keypad8 = 608,
	Keypad9 = 609,
	Keypad_Decimal = 610,
	Keypad_Divide = 611,
	Keypad_Multiply = 612,
	Keypad_Subtract = 613,
	Keypad_Add = 614,
	Keypad_Enter = 615,
	Keypad_Equal = 616,
	Gamepad_Start = 617,
	Gamepad_Back = 618,
	Gamepad_Face_Left = 619,
	Gamepad_Face_Right = 620,
	Gamepad_Face_Up = 621,
	Gamepad_Face_Down = 622,
	Gamepad_Dpad_Left = 623,
	Gamepad_Dpad_Right = 624,
	Gamepad_Dpad_Up = 625,
	Gamepad_Dpad_Down = 626,
	Gamepad_L1 = 627,
	Gamepad_R1 = 628,
	Gamepad_L2 = 629,
	Gamepad_R2 = 630,
	Gamepad_L3 = 631,
	Gamepad_R3 = 632,
	Gamepad_L_Stick_Left = 633,
	Gamepad_L_Stick_Right = 634,
	Gamepad_L_Stick_Up = 635,
	Gamepad_L_Stick_Down = 636,
	Gamepad_R_Stick_Left = 637,
	Gamepad_R_Stick_Right = 638,
	Gamepad_R_Stick_Up = 639,
	Gamepad_R_Stick_Down = 640,
	Mouse_Left = 641,
	Mouse_Right = 642,
	Mouse_Middle = 643,
	Mouse_X1 = 644,
	Mouse_X2 = 645,
	Mouse_Wheel_X = 646,
	Mouse_Wheel_Y = 647,
	Reserved_For_Mod_Ctrl = 648,
	Reserved_For_Mod_Shift = 649,
	Reserved_For_Mod_Alt = 650,
	Reserved_For_Mod_Super = 651,
	None = 0,
	Ctrl = (1 << 12),
	Shift = (1 << 13),
	Alt = (1 << 14),
	Super = (1 << 15),
	Shortcut = (1 << 11),
	Mask_ = 0xF800,
}
ImGuiKey_COUNT :: len(Key)
ImGuiKey_NamedKey_BEGIN :: 512
ImGuiKey_NamedKey_END :: ImGuiKey_COUNT
ImGuiKey_NamedKey_COUNT :: (ImGuiKey_NamedKey_END - ImGuiKey_NamedKey_BEGIN)
ImGuiKey_KeysData_SIZE :: ImGuiKey_COUNT
ImGuiKey_KeysData_OFFSET :: 0

Nav_Input :: enum i32 {
	Activate,
	Cancel,
	Input,
	Menu,
	Dpad_Left,
	Dpad_Right,
	Dpad_Up,
	Dpad_Down,
	L_Stick_Left,
	L_Stick_Right,
	L_Stick_Up,
	L_Stick_Down,
	Focus_Prev,
	Focus_Next,
	Tweak_Slow,
	Tweak_Fast,
}
ImGuiNavInput_COUNT :: len(Nav_Input)

ImGuiConfigFlags_ :: enum {
	Nav_Enable_Keyboard = 0,
	Nav_Enable_Gamepad = 1,
	Nav_Enable_Set_Mouse_Pos = 2,
	Nav_No_Capture_Keyboard = 3,
	No_Mouse = 4,
	No_Mouse_Cursor_Change = 5,
	Is_S_RGB = 20,
	Is_Touch_Screen = 21,
}

ImGuiBackendFlags_ :: enum {
	Has_Gamepad = 0,
	Has_Mouse_Cursors = 1,
	Has_Set_Mouse_Pos = 2,
	Renderer_Has_Vtx_Offset = 3,
}

Col_ :: enum i32 {
	Text,
	Text_Disabled,
	Window_Bg,
	Child_Bg,
	Popup_Bg,
	Border,
	Border_Shadow,
	Frame_Bg,
	Frame_Bg_Hovered,
	Frame_Bg_Active,
	Title_Bg,
	Title_Bg_Active,
	Title_Bg_Collapsed,
	Menu_Bar_Bg,
	Scrollbar_Bg,
	Scrollbar_Grab,
	Scrollbar_Grab_Hovered,
	Scrollbar_Grab_Active,
	Check_Mark,
	Slider_Grab,
	Slider_Grab_Active,
	Button,
	Button_Hovered,
	Button_Active,
	Header,
	Header_Hovered,
	Header_Active,
	Separator,
	Separator_Hovered,
	Separator_Active,
	Resize_Grip,
	Resize_Grip_Hovered,
	Resize_Grip_Active,
	Tab,
	Tab_Hovered,
	Tab_Active,
	Tab_Unfocused,
	Tab_Unfocused_Active,
	Plot_Lines,
	Plot_Lines_Hovered,
	Plot_Histogram,
	Plot_Histogram_Hovered,
	Table_Header_Bg,
	Table_Border_Strong,
	Table_Border_Light,
	Table_Row_Bg,
	Table_Row_Bg_Alt,
	Text_Selected_Bg,
	Drag_Drop_Target,
	Nav_Highlight,
	Nav_Windowing_Highlight,
	Nav_Windowing_Dim_Bg,
	Modal_Window_Dim_Bg,
}
ImGuiCol_COUNT :: len(Col_)

Style_Var_ :: enum i32 {
	Alpha,
	Disabled_Alpha,
	Window_Padding,
	Window_Rounding,
	Window_Border_Size,
	Window_Min_Size,
	Window_Title_Align,
	Child_Rounding,
	Child_Border_Size,
	Popup_Rounding,
	Popup_Border_Size,
	Frame_Padding,
	Frame_Rounding,
	Frame_Border_Size,
	Item_Spacing,
	Item_Inner_Spacing,
	Indent_Spacing,
	Cell_Padding,
	Scrollbar_Size,
	Scrollbar_Rounding,
	Grab_Min_Size,
	Grab_Rounding,
	Tab_Rounding,
	Button_Text_Align,
	Selectable_Text_Align,
	Separator_Text_Border_Size,
	Separator_Text_Align,
	Separator_Text_Padding,
}
ImGuiStyleVar_COUNT :: len(Style_Var_)

ImGuiButtonFlags_ :: enum {
	Mouse_Button_Left = 0,
	Mouse_Button_Right = 1,
	Mouse_Button_Middle = 2,
}
Button_Flags_MOUSE_BUTTON_MASK :: Button_Flags{ .Mouse_Button_Left, .Mouse_Button_Right, .Mouse_Button_Middle }

ImGuiColorEditFlags_ :: enum {
	No_Alpha = 1,
	No_Picker = 2,
	No_Options = 3,
	No_Small_Preview = 4,
	No_Inputs = 5,
	No_Tooltip = 6,
	No_Label = 7,
	No_Side_Preview = 8,
	No_Drag_Drop = 9,
	No_Border = 10,
	Alpha_Bar = 16,
	Alpha_Preview = 17,
	Alpha_Preview_Half = 18,
	H_D_R = 19,
	Display_RGB = 20,
	Display_HSV = 21,
	Display_Hex = 22,
	Uint8 = 23,
	Float = 24,
	Picker_Hue_Bar = 25,
	Picker_Hue_Wheel = 26,
	Input_RGB = 27,
	Input_HSV = 28,
}
Color_Edit_Flags_DEFAULT_OPTIONS :: Color_Edit_Flags{ .Uint8, .Display_RGB, .Input_RGB, .Picker_Hue_Bar }
Color_Edit_Flags_DISPLAY_MASK :: Color_Edit_Flags{ .Display_RGB, .Display_HSV, .Display_Hex }
Color_Edit_Flags_DATA_TYPE_MASK :: Color_Edit_Flags{ .Uint8, .Float }
Color_Edit_Flags_PICKER_MASK :: Color_Edit_Flags{ .Picker_Hue_Wheel, .Picker_Hue_Bar }
Color_Edit_Flags_INPUT_MASK :: Color_Edit_Flags{ .Input_RGB, .Input_HSV }

ImGuiSliderFlags_ :: enum {
	Always_Clamp = 4,
	Logarithmic = 5,
	No_Round_To_Format = 6,
	No_Input = 7,
}

Mouse_Button_ :: enum i32 {
	Left = 0,
	Right = 1,
	Middle = 2,
}
ImGuiMouseButton_COUNT :: len(Mouse_Button_)

Mouse_Cursor_ :: enum i32 {
	None = (-1),
	Arrow = 0,
	Text_Input,
	Resize_All,
	Resize_NS,
	Resize_EW,
	Resize_NESW,
	Resize_NWSE,
	Hand,
	Not_Allowed,
}
ImGuiMouseCursor_COUNT :: len(Mouse_Cursor_)

Mouse_Source :: enum i32 {
	Mouse = 0,
	Touch_Screen = 1,
	Pen = 2,
}
ImGuiMouseSource_COUNT :: len(Mouse_Source)

ImGuiCond_ :: enum {
	Always = 0,
	Once = 1,
	First_Use_Ever = 2,
	Appearing = 3,
}

Style :: struct {
	alpha: f32,
	disabled_alpha: f32,
	window_padding: [2]f32,
	window_rounding: f32,
	window_border_size: f32,
	window_min_size: [2]f32,
	window_title_align: [2]f32,
	window_menu_button_position: Dir,
	child_rounding: f32,
	child_border_size: f32,
	popup_rounding: f32,
	popup_border_size: f32,
	frame_padding: [2]f32,
	frame_rounding: f32,
	frame_border_size: f32,
	item_spacing: [2]f32,
	item_inner_spacing: [2]f32,
	cell_padding: [2]f32,
	touch_extra_padding: [2]f32,
	indent_spacing: f32,
	columns_min_spacing: f32,
	scrollbar_size: f32,
	scrollbar_rounding: f32,
	grab_min_size: f32,
	grab_rounding: f32,
	log_slider_deadzone: f32,
	tab_rounding: f32,
	tab_border_size: f32,
	tab_min_width_for_close_button: f32,
	color_button_position: Dir,
	button_text_align: [2]f32,
	selectable_text_align: [2]f32,
	separator_text_border_size: f32,
	separator_text_align: [2]f32,
	separator_text_padding: [2]f32,
	display_window_padding: [2]f32,
	display_safe_area_padding: [2]f32,
	mouse_cursor_scale: f32,
	anti_aliased_lines: bool,
	anti_aliased_lines_use_tex: bool,
	anti_aliased_fill: bool,
	curve_tessellation_tol: f32,
	circle_tessellation_max_error: f32,
	colors: [ImGuiCol_COUNT][4]f32,
}

Key_Data :: struct {
	down: bool,
	down_duration: f32,
	down_duration_prev: f32,
	analog_value: f32,
}

IO :: struct {
	config_flags: Config_Flags,
	backend_flags: Backend_Flags,
	display_size: [2]f32,
	delta_time: f32,
	ini_saving_rate: f32,
	ini_filename: ^i8,
	log_filename: ^i8,
	mouse_double_click_time: f32,
	mouse_double_click_max_dist: f32,
	mouse_drag_threshold: f32,
	key_repeat_delay: f32,
	key_repeat_rate: f32,
	hover_delay_normal: f32,
	hover_delay_short: f32,
	user_data: rawptr,
	fonts: ^Font_Atlas,
	font_global_scale: f32,
	font_allow_user_scaling: bool,
	font_default: ^Font,
	display_framebuffer_scale: [2]f32,
	mouse_draw_cursor: bool,
	config_mac_osx_behaviors: bool,
	config_input_trickle_event_queue: bool,
	config_input_text_cursor_blink: bool,
	config_input_text_enter_keep_active: bool,
	config_drag_click_to_input_text: bool,
	config_windows_resize_from_edges: bool,
	config_windows_move_from_title_bar_only: bool,
	config_memory_compact_timer: f32,
	config_debug_begin_return_value_once: bool,
	config_debug_begin_return_value_loop: bool,
	backend_platform_name: ^i8,
	backend_renderer_name: ^i8,
	backend_platform_user_data: rawptr,
	backend_renderer_user_data: rawptr,
	backend_language_user_data: rawptr,
	get_clipboard_text_fn: proc "c" (user_data: rawptr) -> ^i8,
	set_clipboard_text_fn: proc "c" (user_data: rawptr, text: ^i8),
	clipboard_user_data: rawptr,
	set_platform_ime_data_fn: proc "c" (viewport: ^Viewport, data: ^Platform_Ime_Data),
	__unused_padding: rawptr,
	want_capture_mouse: bool,
	want_capture_keyboard: bool,
	want_text_input: bool,
	want_set_mouse_pos: bool,
	want_save_ini_settings: bool,
	nav_active: bool,
	nav_visible: bool,
	framerate: f32,
	metrics_render_vertices: i32,
	metrics_render_indices: i32,
	metrics_render_windows: i32,
	metrics_active_windows: i32,
	metrics_active_allocations: i32,
	mouse_delta: [2]f32,
	key_map: [ImGuiKey_COUNT]i32,
	keys_down: [ImGuiKey_COUNT]bool,
	nav_inputs: [ImGuiNavInput_COUNT]f32,
	ctx: ^Context,
	mouse_pos: [2]f32,
	mouse_down: [5]bool,
	mouse_wheel: f32,
	mouse_wheel_h: f32,
	mouse_source: Mouse_Source,
	key_ctrl: bool,
	key_shift: bool,
	key_alt: bool,
	key_super: bool,
	key_mods: Key_Chord,
	keys_data: [ImGuiKey_KeysData_SIZE]Key_Data,
	want_capture_mouse_unless_popup_close: bool,
	mouse_pos_prev: [2]f32,
	mouse_clicked_pos: [5][2]f32,
	mouse_clicked_time: [5]f64,
	mouse_clicked: [5]bool,
	mouse_double_clicked: [5]bool,
	mouse_clicked_count: [5]u16,
	mouse_clicked_last_count: [5]u16,
	mouse_released: [5]bool,
	mouse_down_owned: [5]bool,
	mouse_down_owned_unless_popup_close: [5]bool,
	mouse_wheel_request_axis_swap: bool,
	mouse_down_duration: [5]f32,
	mouse_down_duration_prev: [5]f32,
	mouse_drag_max_distance_sqr: [5]f32,
	pen_pressure: f32,
	app_focus_lost: bool,
	app_accepting_events: bool,
	backend_using_legacy_key_arrays: i8,
	backend_using_legacy_nav_input_array: bool,
	input_queue_surrogate: u16,
	input_queue_characters: Vector(u16),
}

Input_Text_Callback_Data :: struct {
	ctx: ^Context,
	event_flag: Input_Text_Flags,
	flags: Input_Text_Flags,
	user_data: rawptr,
	event_char: u16,
	event_key: Key,
	buf: ^i8,
	buf_text_len: i32,
	buf_size: i32,
	buf_dirty: bool,
	cursor_pos: i32,
	selection_start: i32,
	selection_end: i32,
}

Size_Callback_Data :: struct {
	user_data: rawptr,
	pos: [2]f32,
	current_size: [2]f32,
	desired_size: [2]f32,
}

Payload :: struct {
	data: rawptr,
	data_size: i32,
	source_id: ID,
	source_parent_id: ID,
	data_frame_count: i32,
	data_type: [(32 + 1)]i8,
	preview: bool,
	delivery: bool,
}

Table_Column_Sort_Specs :: struct {
	column_user_id: ID,
	column_index: i16,
	sort_order: i16,
	sort_direction: Sort_Direction,
}

Table_Sort_Specs :: struct {
	specs: ^Table_Column_Sort_Specs,
	specs_count: i32,
	specs_dirty: bool,
}

Once_Upon_A_Frame :: struct {
	ref_frame: i32,
}

Text_Range :: struct {
	b: ^i8,
	e: ^i8,
}

Text_Filter :: struct {
	input_buf: [256]i8,
	filters: Vector(Text_Range),
	count_grep: i32,
}

Text_Buffer :: struct {
	buf: Vector(i8),
}

Storage_Pair :: struct {
	key: ID,
	using _field_1: struct #raw_union {
		val_i: i32,
		val_f: f32,
		val_p: rawptr,
	},
}

Storage :: struct {
	data: Vector(Storage_Pair),
}

List_Clipper :: struct {
	ctx: ^Context,
	display_start: i32,
	display_end: i32,
	items_count: i32,
	items_height: f32,
	start_pos_y: f32,
	temp_data: rawptr,
}

Color :: struct {
	value: [4]f32,
}

Draw_Cmd :: struct {
	clip_rect: [4]f32,
	texture_id: Texture_ID,
	vtx_offset: u32,
	idx_offset: u32,
	elem_count: u32,
	user_callback: Draw_Callback,
	user_callback_data: rawptr,
}

Draw_Vert :: struct {
	pos: [2]f32,
	uv: [2]f32,
	col: u32,
}

Draw_Cmd_Header :: struct {
	clip_rect: [4]f32,
	texture_id: Texture_ID,
	vtx_offset: u32,
}

Draw_Channel :: struct {
	__cmd_buffer: Vector(Draw_Cmd),
	__idx_buffer: Vector(Draw_Idx),
}

Draw_List_Splitter :: struct {
	__current: i32,
	__count: i32,
	__channels: Vector(Draw_Channel),
}

ImDrawFlags_ :: enum {
	Closed = 0,
	Round_Corners_Top_Left = 4,
	Round_Corners_Top_Right = 5,
	Round_Corners_Bottom_Left = 6,
	Round_Corners_Bottom_Right = 7,
	Round_Corners_None = 8,
}
Draw_Flags_ROUND_CORNERS_TOP :: Draw_Flags{ .Round_Corners_Top_Left, .Round_Corners_Top_Right }
Draw_Flags_ROUND_CORNERS_BOTTOM :: Draw_Flags{ .Round_Corners_Bottom_Left, .Round_Corners_Bottom_Right }
Draw_Flags_ROUND_CORNERS_LEFT :: Draw_Flags{ .Round_Corners_Bottom_Left, .Round_Corners_Top_Left }
Draw_Flags_ROUND_CORNERS_RIGHT :: Draw_Flags{ .Round_Corners_Bottom_Right, .Round_Corners_Top_Right }
Draw_Flags_ROUND_CORNERS_ALL :: Draw_Flags{ .Round_Corners_Top_Left, .Round_Corners_Top_Right, .Round_Corners_Bottom_Left, .Round_Corners_Bottom_Right }
Draw_Flags_ROUND_CORNERS_MASK :: Draw_Flags{ .Round_Corners_All, .Round_Corners_None }

ImDrawListFlags_ :: enum {
	Anti_Aliased_Lines = 0,
	Anti_Aliased_Lines_Use_Tex = 1,
	Anti_Aliased_Fill = 2,
	Allow_Vtx_Offset = 3,
}

Draw_List :: struct {
	cmd_buffer: Vector(Draw_Cmd),
	idx_buffer: Vector(Draw_Idx),
	vtx_buffer: Vector(Draw_Vert),
	flags: Draw_List_Flags,
	__vtx_current_idx: u32,
	__data: ^Draw_List_Shared_Data,
	__owner_name: ^i8,
	__vtx_write_ptr: ^Draw_Vert,
	__idx_write_ptr: ^Draw_Idx,
	__clip_rect_stack: Vector([4]f32),
	__texture_id_stack: Vector(Texture_ID),
	__path: Vector([2]f32),
	__cmd_header: Draw_Cmd_Header,
	__splitter: Draw_List_Splitter,
	__fringe_scale: f32,
}

Draw_Data :: struct {
	valid: bool,
	cmd_lists_count: i32,
	total_idx_count: i32,
	total_vtx_count: i32,
	cmd_lists: ^^Draw_List,
	display_pos: [2]f32,
	display_size: [2]f32,
	framebuffer_scale: [2]f32,
}

Font_Config :: struct {
	font_data: rawptr,
	font_data_size: i32,
	font_data_owned_by_atlas: bool,
	font_no: i32,
	size_pixels: f32,
	oversample_h: i32,
	oversample_v: i32,
	pixel_snap_h: bool,
	glyph_extra_spacing: [2]f32,
	glyph_offset: [2]f32,
	glyph_ranges: ^u16,
	glyph_min_advance_x: f32,
	glyph_max_advance_x: f32,
	merge_mode: bool,
	font_builder_flags: u32,
	rasterizer_multiply: f32,
	ellipsis_char: u16,
	name: [40]i8,
	dst_font: ^Font,
}

Font_Glyph :: struct {
	colored: u32,
	visible: u32,
	codepoint: u32,
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

Font_Glyph_Ranges_Builder :: struct {
	used_chars: Vector(u32),
}

Font_Atlas_Custom_Rect :: struct {
	width: u16,
	height: u16,
	x: u16,
	y: u16,
	glyph_id: u32,
	glyph_advance_x: f32,
	glyph_offset: [2]f32,
	font: ^Font,
}

ImFontAtlasFlags_ :: enum {
	No_Power_Of_Two_Height = 0,
	No_Mouse_Cursors = 1,
	No_Baked_Lines = 2,
}

Font_Atlas :: struct {
	flags: Font_Atlas_Flags,
	tex_id: Texture_ID,
	tex_desired_width: i32,
	tex_glyph_padding: i32,
	locked: bool,
	user_data: rawptr,
	tex_ready: bool,
	tex_pixels_use_colors: bool,
	tex_pixels_alpha8: ^u8,
	tex_pixels_rgb_a32: ^u32,
	tex_width: i32,
	tex_height: i32,
	tex_uv_scale: [2]f32,
	tex_uv_white_pixel: [2]f32,
	fonts: Vector(^Font),
	custom_rects: Vector(Font_Atlas_Custom_Rect),
	config_data: Vector(Font_Config),
	tex_uv_lines: [(63 + 1)][4]f32,
	font_builder_io: ^Font_Builder_IO,
	font_builder_flags: u32,
	pack_id_mouse_cursors: i32,
	pack_id_lines: i32,
}

Font :: struct {
	index_advance_x: Vector(f32),
	fallback_advance_x: f32,
	font_size: f32,
	index_lookup: Vector(u16),
	glyphs: Vector(Font_Glyph),
	fallback_glyph: ^Font_Glyph,
	container_atlas: ^Font_Atlas,
	config_data: ^Font_Config,
	config_data_count: i16,
	fallback_char: u16,
	ellipsis_char: u16,
	ellipsis_char_count: i16,
	ellipsis_width: f32,
	ellipsis_char_step: f32,
	dirty_lookup_tables: bool,
	scale: f32,
	ascent: f32,
	descent: f32,
	metrics_total_surface: i32,
	used4k_pages_map: [(((0xFFFF + 1) / 4096) / 8)]u8,
}

ImGuiViewportFlags_ :: enum {
	Is_Platform_Window = 0,
	Is_Platform_Monitor = 1,
	Owned_By_App = 2,
}

Viewport :: struct {
	flags: Viewport_Flags,
	pos: [2]f32,
	size: [2]f32,
	work_pos: [2]f32,
	work_size: [2]f32,
	platform_handle_raw: rawptr,
}

Platform_Ime_Data :: struct {
	want_visible: bool,
	input_pos: [2]f32,
	input_line_height: f32,
}
Layout_Type :: distinct i32
Activate_Flags :: bit_set[ImGuiActivateFlags_; u32]
Debug_Log_Flags :: bit_set[ImGuiDebugLogFlags_; u32]
Input_Flags :: bit_set[ImGuiInputFlags_; u32]
Item_Flags :: bit_set[ImGuiItemFlags_; u32]
Item_Status_Flags :: bit_set[ImGuiItemStatusFlags_; u32]
Old_Column_Flags :: bit_set[ImGuiOldColumnFlags_; u32]
Nav_Highlight_Flags :: bit_set[ImGuiNavHighlightFlags_; u32]
Nav_Move_Flags :: bit_set[ImGuiNavMoveFlags_; u32]
Next_Item_Data_Flags :: bit_set[ImGuiNextItemDataFlags_; u32]
Next_Window_Data_Flags :: bit_set[ImGuiNextWindowDataFlags_; u32]
Scroll_Flags :: bit_set[ImGuiScrollFlags_; u32]
Separator_Flags :: bit_set[ImGuiSeparatorFlags_; u32]
Text_Flags :: bit_set[ImGuiTextFlags_; u32]
Tooltip_Flags :: bit_set[ImGuiTooltipFlags_; u32]

Stb_Undo_Record :: struct {
	where_: i32,
	insert_length: i32,
	delete_length: i32,
	char_storage: i32,
}

Stb_Undo_State :: struct {
	undo_rec: [99]Stb_Undo_Record,
	undo_char: [999]u16,
	undo_point: i16,
	redo_point: i16,
	undo_char_point: i32,
	redo_char_point: i32,
}

STB_TexteditState :: struct {
	cursor: i32,
	select_start: i32,
	select_end: i32,
	insert_mode: u8,
	row_count_per_page: i32,
	cursor_at_end_of_line: u8,
	initialized: u8,
	has_preferred_x: u8,
	single_line: u8,
	padding1: u8,
	padding2: u8,
	padding3: u8,
	preferred_x: f32,
	undostate: Stb_Undo_State,
}

Stb_Textedit_Row :: struct {
	x0: f32,
	x1: f32,
	baseline_y_delta: f32,
	ymin: f32,
	ymax: f32,
	num_chars: i32,
}

Rect :: struct {
	min: [2]f32,
	max: [2]f32,
}

Bit_Vector :: struct {
	storage: Vector(u32),
}
Pool_Idx :: distinct i32

Text_Index :: struct {
	line_offsets: Vector(i32),
	end_offset: i32,
}

Draw_List_Shared_Data :: struct {
	tex_uv_white_pixel: [2]f32,
	font: ^Font,
	font_size: f32,
	curve_tessellation_tol: f32,
	circle_segment_max_error: f32,
	clip_rect_fullscreen: [4]f32,
	initial_flags: Draw_List_Flags,
	temp_buffer: Vector([2]f32),
	arc_fast_vtx: [48][2]f32,
	arc_fast_radius_cutoff: f32,
	circle_segment_counts: [64]u8,
	tex_uv_lines: ^[4]f32,
}

Draw_Data_Builder :: struct {
	layers: [2]Vector(^Draw_List),
}

ImGuiItemFlags_ :: enum {
	No_Tab_Stop = 0,
	Button_Repeat = 1,
	Disabled = 2,
	No_Nav = 3,
	No_Nav_Default_Focus = 4,
	Selectable_Dont_Close_Popup = 5,
	Mixed_Value = 6,
	Read_Only = 7,
	No_Window_Hoverable_Check = 8,
	Inputable = 10,
}

ImGuiItemStatusFlags_ :: enum {
	Hovered_Rect = 0,
	Has_Display_Rect = 1,
	Edited = 2,
	Toggled_Selection = 3,
	Toggled_Open = 4,
	Has_Deactivated = 5,
	Deactivated = 6,
	Hovered_Window = 7,
	Focused_By_Tabbing = 8,
	Visible = 9,
}

Input_Text_Flags_Private_ :: enum i32 {
	Multiline = (1 << 26),
	No_Mark_Edited = (1 << 27),
	Merged_Item = (1 << 28),
}

Button_Flags_Private_ :: enum i32 {
	Pressed_On_Click = (1 << 4),
	Pressed_On_Click_Release = (1 << 5),
	Pressed_On_Click_Release_Anywhere = (1 << 6),
	Pressed_On_Release = (1 << 7),
	Pressed_On_Double_Click = (1 << 8),
	Pressed_On_Drag_Drop_Hold = (1 << 9),
	Repeat = (1 << 10),
	Flatten_Children = (1 << 11),
	Allow_Item_Overlap = (1 << 12),
	Dont_Close_Popups = (1 << 13),
	Align_Text_Base_Line = (1 << 15),
	No_Key_Modifiers = (1 << 16),
	No_Holding_Active_Id = (1 << 17),
	No_Nav_Focus = (1 << 18),
	No_Hovered_On_Focus = (1 << 19),
	No_Set_Key_Owner = (1 << 20),
	No_Test_Key_Owner = (1 << 21),
	Pressed_On_Mask_ = (((((ImGuiButtonFlags_PressedOnClick | ImGuiButtonFlags_PressedOnClickRelease) | ImGuiButtonFlags_PressedOnClickReleaseAnywhere) | ImGuiButtonFlags_PressedOnRelease) | ImGuiButtonFlags_PressedOnDoubleClick) | ImGuiButtonFlags_PressedOnDragDropHold),
	Pressed_On_Default_ = ImGuiButtonFlags_PressedOnClickRelease,
}

Combo_Flags_Private_ :: enum i32 {
	Custom_Preview = (1 << 20),
}

Slider_Flags_Private_ :: enum i32 {
	Vertical = (1 << 20),
	Read_Only = (1 << 21),
}

Selectable_Flags_Private_ :: enum i32 {
	No_Holding_Active_ID = (1 << 20),
	Select_On_Nav = (1 << 21),
	Select_On_Click = (1 << 22),
	Select_On_Release = (1 << 23),
	Span_Avail_Width = (1 << 24),
	Set_Nav_Id_On_Hover = (1 << 25),
	No_Pad_With_Half_Spacing = (1 << 26),
	No_Set_Key_Owner = (1 << 27),
}

Tree_Node_Flags_Private_ :: enum i32 {
	Clip_Label_For_Trailing_Button = (1 << 20),
}

ImGuiSeparatorFlags_ :: enum {
	Horizontal = 0,
	Vertical = 1,
	Span_All_Columns = 2,
}

ImGuiTextFlags_ :: enum {
	No_Width_For_Large_Clipped_Text = 0,
}

ImGuiTooltipFlags_ :: enum {
	Override_Previous_Tooltip = 0,
}

Layout_Type_ :: enum i32 {
	Horizontal = 0,
	Vertical = 1,
}

Log_Type :: enum i32 {
	None = 0,
	T_T_Y,
	File,
	Buffer,
	Clipboard,
}

Axis :: enum i32 {
	None = (-1),
	X = 0,
	Y = 1,
}

Plot_Type :: enum i32 {
	Lines,
	Histogram,
}

Popup_Position_Policy :: enum i32 {
	Default,
	Combo_Box,
	Tooltip,
}

Data_Var_Info :: struct {
	type: Data_Type,
	count: u32,
	offset: u32,
}

Data_Type_Temp_Storage :: struct {
	data: [8]u8,
}

Data_Type_Info :: struct {
	size: size_t,
	name: ^i8,
	print_fmt: ^i8,
	scan_fmt: ^i8,
}

Data_Type_Private_ :: enum i32 {
	String = (ImGuiDataType_COUNT + 1),
	Pointer,
	ID,
}

Color_Mod :: struct {
	col: Col,
	backup_value: [4]f32,
}

Style_Mod :: struct {
	var_idx: Style_Var,
	using _field_1: struct #raw_union {
		BackupInt: [2]i32,
		BackupFloat: [2]f32,
	},
}

Combo_Preview_Data :: struct {
	preview_rect: Rect,
	backup_cursor_pos: [2]f32,
	backup_cursor_max_pos: [2]f32,
	backup_cursor_pos_prev_line: [2]f32,
	backup_prev_line_text_base_offset: f32,
	backup_layout: Layout_Type,
}

Group_Data :: struct {
	window_id: ID,
	backup_cursor_pos: [2]f32,
	backup_cursor_max_pos: [2]f32,
	backup_indent: [1]f32,
	backup_group_offset: [1]f32,
	backup_curr_line_size: [2]f32,
	backup_curr_line_text_base_offset: f32,
	backup_active_id_is_alive: ID,
	backup_active_id_previous_frame_is_alive: bool,
	backup_hovered_id_is_alive: bool,
	emit_item: bool,
}

Menu_Columns :: struct {
	total_width: u32,
	next_total_width: u32,
	spacing: u16,
	offset_icon: u16,
	offset_label: u16,
	offset_shortcut: u16,
	offset_mark: u16,
	widths: [4]u16,
}

Input_Text_Deactivated_State :: struct {
	id: ID,
	text_a: Vector(i8),
}

Input_Text_State :: struct {
	ctx: ^Context,
	id: ID,
	cur_len_w: i32,
	cur_len_a: i32,
	text_w: Vector(u16),
	text_a: Vector(i8),
	initial_text_a: Vector(i8),
	text_a_is_valid: bool,
	buf_capacity_a: i32,
	scroll_x: f32,
	stb: STB_TexteditState,
	cursor_anim: f32,
	cursor_follow: bool,
	selected_all_mouse_lock: bool,
	edited: bool,
	flags: Input_Text_Flags,
}

Popup_Data :: struct {
	popup_id: ID,
	window: ^Window,
	backup_nav_window: ^Window,
	parent_nav_layer: i32,
	open_frame_count: i32,
	open_parent_id: ID,
	open_popup_pos: [2]f32,
	open_mouse_pos: [2]f32,
}

ImGuiNextWindowDataFlags_ :: enum {
	Has_Pos = 0,
	Has_Size = 1,
	Has_Content_Size = 2,
	Has_Collapsed = 3,
	Has_Size_Constraint = 4,
	Has_Focus = 5,
	Has_Bg_Alpha = 6,
	Has_Scroll = 7,
}

Next_Window_Data :: struct {
	flags: Next_Window_Data_Flags,
	pos_cond: Cond,
	size_cond: Cond,
	collapsed_cond: Cond,
	pos_val: [2]f32,
	pos_pivot_val: [2]f32,
	size_val: [2]f32,
	content_size_val: [2]f32,
	scroll_val: [2]f32,
	collapsed_val: bool,
	size_constraint_rect: Rect,
	size_callback: Size_Callback,
	size_callback_user_data: rawptr,
	bg_alpha_val: f32,
	menu_bar_offset_min_val: [2]f32,
}

ImGuiNextItemDataFlags_ :: enum {
	Has_Width = 0,
	Has_Open = 1,
}

Next_Item_Data :: struct {
	flags: Next_Item_Data_Flags,
	width: f32,
	focus_scope_id: ID,
	open_cond: Cond,
	open_val: bool,
}

Last_Item_Data :: struct {
	id: ID,
	in_flags: Item_Flags,
	status_flags: Item_Status_Flags,
	rect: Rect,
	nav_rect: Rect,
	display_rect: Rect,
}

Stack_Sizes :: struct {
	size_of_id_stack: i16,
	size_of_color_stack: i16,
	size_of_style_var_stack: i16,
	size_of_font_stack: i16,
	size_of_focus_scope_stack: i16,
	size_of_group_stack: i16,
	size_of_item_flags_stack: i16,
	size_of_begin_popup_stack: i16,
	size_of_disabled_stack: i16,
}

Window_Stack_Data :: struct {
	window: ^Window,
	parent_last_item_data_backup: Last_Item_Data,
	stack_sizes_on_begin: Stack_Sizes,
}

Shrink_Width_Item :: struct {
	index: i32,
	width: f32,
	initial_width: f32,
}

Ptr_Or_Index :: struct {
	ptr: rawptr,
	index: i32,
}

Bit_Array__Im_Gui_Key__Named_Key__COUNT__lessImGuiKey_NamedKey_BEGIN :: struct {
	storage: [((ImGuiKey_NamedKey_COUNT + 31) >> 5)]u32,
}
Bit_Array_For_Named_Keys :: distinct Bit_Array__Im_Gui_Key__Named_Key__COUNT__lessImGuiKey_NamedKey_BEGIN

Input_Event_Type :: enum i32 {
	None = 0,
	Mouse_Pos,
	Mouse_Wheel,
	Mouse_Button,
	Key,
	Text,
	Focus,
}
ImGuiInputEventType_COUNT :: len(Input_Event_Type)

Input_Source :: enum i32 {
	None = 0,
	Mouse,
	Keyboard,
	Gamepad,
	Clipboard,
}
ImGuiInputSource_COUNT :: len(Input_Source)

Input_Event_Mouse_Pos :: struct {
	pos_x: f32,
	pos_y: f32,
	mouse_source: Mouse_Source,
}

Input_Event_Mouse_Wheel :: struct {
	wheel_x: f32,
	wheel_y: f32,
	mouse_source: Mouse_Source,
}

Input_Event_Mouse_Button :: struct {
	button: i32,
	down: bool,
	mouse_source: Mouse_Source,
}

Input_Event_Key :: struct {
	key: Key,
	down: bool,
	analog_value: f32,
}

Input_Event_Text :: struct {
	char: u32,
}

Input_Event_App_Focused :: struct {
	focused: bool,
}

Input_Event :: struct {
	type: Input_Event_Type,
	source: Input_Source,
	event_id: u32,
	using _field_3: struct #raw_union {
		MousePos: Input_Event_Mouse_Pos,
		MouseWheel: Input_Event_Mouse_Wheel,
		MouseButton: Input_Event_Mouse_Button,
		Key: Input_Event_Key,
		Text: Input_Event_Text,
		AppFocused: Input_Event_App_Focused,
	},
	added_by_test_engine: bool,
}
Key_Routing_Index :: distinct i16

Key_Routing_Data :: struct {
	next_entry_index: Key_Routing_Index,
	mods: u16,
	routing_next_score: u8,
	routing_curr: ID,
	routing_next: ID,
}

Key_Routing_Table :: struct {
	index: [ImGuiKey_NamedKey_COUNT]Key_Routing_Index,
	entries: Vector(Key_Routing_Data),
	entries_next: Vector(Key_Routing_Data),
}

Key_Owner_Data :: struct {
	owner_curr: ID,
	owner_next: ID,
	lock_this_frame: bool,
	lock_until_release: bool,
}

ImGuiInputFlags_ :: enum {
	Repeat = 0,
	Repeat_Rate_Default = 1,
	Repeat_Rate_Nav_Move = 2,
	Repeat_Rate_Nav_Tweak = 3,
	Cond_Hovered = 4,
	Cond_Active = 5,
	Lock_This_Frame = 6,
	Lock_Until_Release = 7,
	Route_Focused = 8,
	Route_Global_Low = 9,
	Route_Global = 10,
	Route_Global_High = 11,
	Route_Always = 12,
	Route_Unless_Bg_Focused = 13,
}
Input_Flags_REPEAT_RATE_MASK :: Input_Flags{ .Repeat_Rate_Default, .Repeat_Rate_Nav_Move, .Repeat_Rate_Nav_Tweak }
Input_Flags_COND_DEFAULT :: Input_Flags{ .Cond_Hovered, .Cond_Active }
Input_Flags_COND_MASK :: Input_Flags{ .Cond_Hovered, .Cond_Active }
Input_Flags_ROUTE_MASK :: Input_Flags{ .Route_Focused, .Route_Global, .Route_Global_Low, .Route_Global_High }
Input_Flags_ROUTE_EXTRA_MASK :: Input_Flags{ .Route_Always, .Route_Unless_Bg_Focused }
Input_Flags_SUPPORTED_BY_IS_KEY_PRESSED :: Input_Flags{ .Repeat, .Repeat_Rate_Mask_ }
Input_Flags_SUPPORTED_BY_SHORTCUT :: Input_Flags{ .Repeat, .Repeat_Rate_Mask_, .Route_Mask_, .Route_Extra_Mask_ }
Input_Flags_SUPPORTED_BY_SET_KEY_OWNER :: Input_Flags{ .Lock_This_Frame, .Lock_Until_Release }
Input_Flags_SUPPORTED_BY_SET_ITEM_KEY_OWNER :: Input_Flags{ .Supported_By_Set_Key_Owner, .Cond_Mask_ }

List_Clipper_Range :: struct {
	min: i32,
	max: i32,
	pos_to_index_convert: bool,
	pos_to_index_offset_min: i8,
	pos_to_index_offset_max: i8,
}

List_Clipper_Data :: struct {
	list_clipper: ^List_Clipper,
	lossyness_offset: f32,
	step_no: i32,
	items_frozen: i32,
	ranges: Vector(List_Clipper_Range),
}

ImGuiActivateFlags_ :: enum {
	Prefer_Input = 0,
	Prefer_Tweak = 1,
	Try_To_Preserve_State = 2,
}

ImGuiScrollFlags_ :: enum {
	Keep_Visible_Edge_X = 0,
	Keep_Visible_Edge_Y = 1,
	Keep_Visible_Center_X = 2,
	Keep_Visible_Center_Y = 3,
	Always_Center_X = 4,
	Always_Center_Y = 5,
	No_Scroll_Parent = 6,
}
Scroll_Flags_MASK_X :: Scroll_Flags{ .Keep_Visible_Edge_X, .Keep_Visible_Center_X, .Always_Center_X }
Scroll_Flags_MASK_Y :: Scroll_Flags{ .Keep_Visible_Edge_Y, .Keep_Visible_Center_Y, .Always_Center_Y }

ImGuiNavHighlightFlags_ :: enum {
	Type_Default = 0,
	Type_Thin = 1,
	Always_Draw = 2,
	No_Rounding = 3,
}

ImGuiNavMoveFlags_ :: enum {
	Loop_X = 0,
	Loop_Y = 1,
	Wrap_X = 2,
	Wrap_Y = 3,
	Allow_Current_Nav_Id = 4,
	Also_Score_Visible_Set = 5,
	Scroll_To_Edge_Y = 6,
	Forwarded = 7,
	Debug_No_Result = 8,
	Focus_Api = 9,
	Tabbing = 10,
	Activate = 11,
	Dont_Set_Nav_Highlight = 12,
}

Nav_Layer :: enum i32 {
	Main = 0,
	Menu = 1,
}
ImGuiNavLayer_COUNT :: len(Nav_Layer)

Nav_Item_Data :: struct {
	window: ^Window,
	id: ID,
	focus_scope_id: ID,
	rect_rel: Rect,
	in_flags: Item_Flags,
	dist_box: f32,
	dist_center: f32,
	dist_axial: f32,
}

ImGuiOldColumnFlags_ :: enum {
	No_Border = 0,
	No_Resize = 1,
	No_Preserve_Widths = 2,
	No_Force_Within_Window = 3,
	Grow_Parent_Contents_Size = 4,
}

Old_Column_Data :: struct {
	offset_norm: f32,
	offset_norm_before_resize: f32,
	flags: Old_Column_Flags,
	clip_rect: Rect,
}

Old_Columns :: struct {
	id: ID,
	flags: Old_Column_Flags,
	is_first_frame: bool,
	is_being_resized: bool,
	current: i32,
	count: i32,
	off_min_x: f32,
	off_max_x: f32,
	line_min_y: f32,
	line_max_y: f32,
	host_cursor_pos_y: f32,
	host_cursor_max_pos_x: f32,
	host_initial_clip_rect: Rect,
	host_backup_clip_rect: Rect,
	host_backup_parent_work_rect: Rect,
	columns: Vector(Old_Column_Data),
	splitter: Draw_List_Splitter,
}

Viewport_P :: struct {
	__im_gui_viewport: Viewport,
	draw_lists_last_frame: [2]i32,
	draw_lists: [2]^Draw_List,
	draw_data_p: Draw_Data,
	draw_data_builder: Draw_Data_Builder,
	work_offset_min: [2]f32,
	work_offset_max: [2]f32,
	build_work_offset_min: [2]f32,
	build_work_offset_max: [2]f32,
}

Window_Settings :: struct {
	id: ID,
	pos: [2]i16,
	size: [2]i16,
	collapsed: bool,
	want_apply: bool,
	want_delete: bool,
}

Settings_Handler :: struct {
	type_name: ^i8,
	type_hash: ID,
	clear_all_fn: proc "c" (ctx: ^Context, handler: ^Settings_Handler),
	read_init_fn: proc "c" (ctx: ^Context, handler: ^Settings_Handler),
	read_open_fn: proc "c" (ctx: ^Context, handler: ^Settings_Handler, name: ^i8) -> rawptr,
	read_line_fn: proc "c" (ctx: ^Context, handler: ^Settings_Handler, entry: rawptr, line: ^i8),
	apply_all_fn: proc "c" (ctx: ^Context, handler: ^Settings_Handler),
	write_all_fn: proc "c" (ctx: ^Context, handler: ^Settings_Handler, out_buf: ^Text_Buffer),
	user_data: rawptr,
}

Loc_Key :: enum i32 {
	Table_Size_One = 0,
	Table_Size_All_Fit = 1,
	Table_Size_All_Default = 2,
	Table_Reset_Order = 3,
	Windowing_Main_Menu_Bar = 4,
	Windowing_Popup = 5,
	Windowing_Untitled = 6,
}
ImGuiLocKey_COUNT :: len(Loc_Key)

Loc_Entry :: struct {
	key: Loc_Key,
	text: ^i8,
}

ImGuiDebugLogFlags_ :: enum {
	Event_Active_Id = 0,
	Event_Focus = 1,
	Event_Popup = 2,
	Event_Nav = 3,
	Event_Clipper = 4,
	Event_Selection = 5,
	Event_IO = 6,
	Output_To_T_T_Y = 10,
}
Debug_Log_Flags_EVENT_MASK :: Debug_Log_Flags{ .Event_Active_Id, .Event_Focus, .Event_Popup, .Event_Nav, .Event_Clipper, .Event_Selection, .Event_IO }

Metrics_Config :: struct {
	show_debug_log: bool,
	show_stack_tool: bool,
	show_windows_rects: bool,
	show_windows_begin_order: bool,
	show_tables_rects: bool,
	show_draw_cmd_mesh: bool,
	show_draw_cmd_bounding_boxes: bool,
	show_atlas_tinted_with_text_color: bool,
	show_windows_rects_type: i32,
	show_tables_rects_type: i32,
}

Stack_Level_Info :: struct {
	id: ID,
	query_frame_count: i8,
	query_success: bool,
	data_type: Data_Type,
	desc: [57]i8,
}

Stack_Tool :: struct {
	last_active_frame: i32,
	stack_level: i32,
	query_id: ID,
	results: Vector(Stack_Level_Info),
	copy_to_clipboard_on_ctrl_c: bool,
	copy_to_clipboard_last_time: f32,
}

Context_Hook_Type :: enum i32 {
	New_Frame_Pre,
	New_Frame_Post,
	End_Frame_Pre,
	End_Frame_Post,
	Render_Pre,
	Render_Post,
	Shutdown,
	Pending_Removal_,
}

Context_Hook :: struct {
	hook_id: ID,
	type: Context_Hook_Type,
	owner: ID,
	callback: Context_Hook_Callback,
	user_data: rawptr,
}

Pool__Im_Gui_Table :: struct {
	buf: Vector(Table),
	map_: Storage,
	free_idx: Pool_Idx,
	alive_count: Pool_Idx,
}

Pool__Im_Gui_Tab_Bar :: struct {
	buf: Vector(Tab_Bar),
	map_: Storage,
	free_idx: Pool_Idx,
	alive_count: Pool_Idx,
}

Chunk_Stream__Im_Gui_Window_Settings :: struct {
	buf: Vector(i8),
}

Chunk_Stream__Im_Gui_Table_Settings :: struct {
	buf: Vector(i8),
}

Context :: struct {
	initialized: bool,
	font_atlas_owned_by_context: bool,
	io: IO,
	style: Style,
	font: ^Font,
	font_size: f32,
	font_base_size: f32,
	draw_list_shared_data: Draw_List_Shared_Data,
	time: f64,
	frame_count: i32,
	frame_count_ended: i32,
	frame_count_rendered: i32,
	within_frame_scope: bool,
	within_frame_scope_with_implicit_window: bool,
	within_end_child: bool,
	gc_compact_all: bool,
	test_engine_hook_items: bool,
	test_engine: rawptr,
	input_events_queue: Vector(Input_Event),
	input_events_trail: Vector(Input_Event),
	input_events_next_mouse_source: Mouse_Source,
	input_events_next_event_id: u32,
	windows: Vector(^Window),
	windows_focus_order: Vector(^Window),
	windows_temp_sort_buffer: Vector(^Window),
	current_window_stack: Vector(Window_Stack_Data),
	windows_by_id: Storage,
	windows_active_count: i32,
	windows_hover_padding: [2]f32,
	current_window: ^Window,
	hovered_window: ^Window,
	hovered_window_under_moving_window: ^Window,
	moving_window: ^Window,
	wheeling_window: ^Window,
	wheeling_window_ref_mouse_pos: [2]f32,
	wheeling_window_start_frame: i32,
	wheeling_window_release_timer: f32,
	wheeling_window_wheel_remainder: [2]f32,
	wheeling_axis_avg: [2]f32,
	debug_hook_id_info: ID,
	hovered_id: ID,
	hovered_id_previous_frame: ID,
	hovered_id_allow_overlap: bool,
	hovered_id_disabled: bool,
	hovered_id_timer: f32,
	hovered_id_not_active_timer: f32,
	active_id: ID,
	active_id_is_alive: ID,
	active_id_timer: f32,
	active_id_is_just_activated: bool,
	active_id_allow_overlap: bool,
	active_id_no_clear_on_focus_loss: bool,
	active_id_has_been_pressed_before: bool,
	active_id_has_been_edited_before: bool,
	active_id_has_been_edited_this_frame: bool,
	active_id_click_offset: [2]f32,
	active_id_window: ^Window,
	active_id_source: Input_Source,
	active_id_mouse_button: i32,
	active_id_previous_frame: ID,
	active_id_previous_frame_is_alive: bool,
	active_id_previous_frame_has_been_edited_before: bool,
	active_id_previous_frame_window: ^Window,
	last_active_id: ID,
	last_active_id_timer: f32,
	keys_owner_data: [ImGuiKey_NamedKey_COUNT]Key_Owner_Data,
	keys_routing_table: Key_Routing_Table,
	active_id_using_nav_dir_mask: u32,
	active_id_using_all_keyboard_keys: bool,
	active_id_using_nav_input_mask: u32,
	current_focus_scope_id: ID,
	current_item_flags: Item_Flags,
	debug_locate_id: ID,
	next_item_data: Next_Item_Data,
	last_item_data: Last_Item_Data,
	next_window_data: Next_Window_Data,
	color_stack: Vector(Color_Mod),
	style_var_stack: Vector(Style_Mod),
	font_stack: Vector(^Font),
	focus_scope_stack: Vector(ID),
	item_flags_stack: Vector(Item_Flags),
	group_stack: Vector(Group_Data),
	open_popup_stack: Vector(Popup_Data),
	begin_popup_stack: Vector(Popup_Data),
	begin_menu_count: i32,
	viewports: Vector(^Viewport_P),
	nav_window: ^Window,
	nav_id: ID,
	nav_focus_scope_id: ID,
	nav_activate_id: ID,
	nav_activate_down_id: ID,
	nav_activate_pressed_id: ID,
	nav_activate_flags: Activate_Flags,
	nav_just_moved_to_id: ID,
	nav_just_moved_to_focus_scope_id: ID,
	nav_just_moved_to_key_mods: Key_Chord,
	nav_next_activate_id: ID,
	nav_next_activate_flags: Activate_Flags,
	nav_input_source: Input_Source,
	nav_layer: Nav_Layer,
	nav_id_is_alive: bool,
	nav_mouse_pos_dirty: bool,
	nav_disable_highlight: bool,
	nav_disable_mouse_hover: bool,
	nav_any_request: bool,
	nav_init_request: bool,
	nav_init_request_from_move: bool,
	nav_init_result_id: ID,
	nav_init_result_rect_rel: Rect,
	nav_move_submitted: bool,
	nav_move_scoring_items: bool,
	nav_move_forward_to_next_frame: bool,
	nav_move_flags: Nav_Move_Flags,
	nav_move_scroll_flags: Scroll_Flags,
	nav_move_key_mods: Key_Chord,
	nav_move_dir: Dir,
	nav_move_dir_for_debug: Dir,
	nav_move_clip_dir: Dir,
	nav_scoring_rect: Rect,
	nav_scoring_no_clip_rect: Rect,
	nav_scoring_debug_count: i32,
	nav_tabbing_dir: i32,
	nav_tabbing_counter: i32,
	nav_move_result_local: Nav_Item_Data,
	nav_move_result_local_visible: Nav_Item_Data,
	nav_move_result_other: Nav_Item_Data,
	nav_tabbing_result_first: Nav_Item_Data,
	config_nav_windowing_key_next: Key_Chord,
	config_nav_windowing_key_prev: Key_Chord,
	nav_windowing_target: ^Window,
	nav_windowing_target_anim: ^Window,
	nav_windowing_list_window: ^Window,
	nav_windowing_timer: f32,
	nav_windowing_highlight_alpha: f32,
	nav_windowing_toggle_layer: bool,
	nav_windowing_accum_delta_pos: [2]f32,
	nav_windowing_accum_delta_size: [2]f32,
	dim_bg_ratio: f32,
	mouse_cursor: Mouse_Cursor,
	drag_drop_active: bool,
	drag_drop_within_source: bool,
	drag_drop_within_target: bool,
	drag_drop_source_flags: Drag_Drop_Flags,
	drag_drop_source_frame_count: i32,
	drag_drop_mouse_button: i32,
	drag_drop_payload: Payload,
	drag_drop_target_rect: Rect,
	drag_drop_target_id: ID,
	drag_drop_accept_flags: Drag_Drop_Flags,
	drag_drop_accept_id_curr_rect_surface: f32,
	drag_drop_accept_id_curr: ID,
	drag_drop_accept_id_prev: ID,
	drag_drop_accept_frame_count: i32,
	drag_drop_hold_just_pressed_id: ID,
	drag_drop_payload_buf_heap: Vector(u8),
	drag_drop_payload_buf_local: [16]u8,
	clipper_temp_data_stacked: i32,
	clipper_temp_data: Vector(List_Clipper_Data),
	current_table: ^Table,
	tables_temp_data_stacked: i32,
	tables_temp_data: Vector(Table_Temp_Data),
	tables: Pool__Im_Gui_Table,
	tables_last_time_active: Vector(f32),
	draw_channels_temp_merge_buffer: Vector(Draw_Channel),
	current_tab_bar: ^Tab_Bar,
	tab_bars: Pool__Im_Gui_Tab_Bar,
	current_tab_bar_stack: Vector(Ptr_Or_Index),
	shrink_width_buffer: Vector(Shrink_Width_Item),
	hover_delay_id: ID,
	hover_delay_id_previous_frame: ID,
	hover_delay_timer: f32,
	hover_delay_clear_timer: f32,
	mouse_last_valid_pos: [2]f32,
	input_text_state: Input_Text_State,
	input_text_deactivated_state: Input_Text_Deactivated_State,
	input_text_password_font: Font,
	temp_input_id: ID,
	color_edit_options: Color_Edit_Flags,
	color_edit_current_id: ID,
	color_edit_saved_id: ID,
	color_edit_saved_hue: f32,
	color_edit_saved_sat: f32,
	color_edit_saved_color: u32,
	color_picker_ref: [4]f32,
	combo_preview_data: Combo_Preview_Data,
	slider_grab_click_offset: f32,
	slider_current_accum: f32,
	slider_current_accum_dirty: bool,
	drag_current_accum_dirty: bool,
	drag_current_accum: f32,
	drag_speed_default_ratio: f32,
	scrollbar_click_delta_to_grab_center: f32,
	disabled_alpha_backup: f32,
	disabled_stack_size: i16,
	tooltip_override_count: i16,
	clipboard_handler_data: Vector(i8),
	menus_id_submitted_this_frame: Vector(ID),
	platform_ime_data: Platform_Ime_Data,
	platform_ime_data_prev: Platform_Ime_Data,
	platform_locale_decimal_point: i8,
	settings_loaded: bool,
	settings_dirty_timer: f32,
	settings_ini_data: Text_Buffer,
	settings_handlers: Vector(Settings_Handler),
	settings_windows: Chunk_Stream__Im_Gui_Window_Settings,
	settings_tables: Chunk_Stream__Im_Gui_Table_Settings,
	hooks: Vector(Context_Hook),
	hook_id_next: ID,
	localization_table: [ImGuiLocKey_COUNT]^i8,
	log_enabled: bool,
	log_type: Log_Type,
	log_file: File_Handle,
	log_buffer: Text_Buffer,
	log_next_prefix: ^i8,
	log_next_suffix: ^i8,
	log_line_pos_y: f32,
	log_line_first_item: bool,
	log_depth_ref: i32,
	log_depth_to_expand: i32,
	log_depth_to_expand_default: i32,
	debug_log_flags: Debug_Log_Flags,
	debug_log_buf: Text_Buffer,
	debug_log_index: Text_Index,
	debug_log_clipper_auto_disable_frames: u8,
	debug_locate_frames: u8,
	debug_begin_return_value_cull_depth: i8,
	debug_item_picker_active: bool,
	debug_item_picker_mouse_button: u8,
	debug_item_picker_break_id: ID,
	debug_metrics_config: Metrics_Config,
	debug_stack_tool: Stack_Tool,
	framerate_sec_per_frame: [60]f32,
	framerate_sec_per_frame_idx: i32,
	framerate_sec_per_frame_count: i32,
	framerate_sec_per_frame_accum: f32,
	want_capture_mouse_next_frame: i32,
	want_capture_keyboard_next_frame: i32,
	want_text_input_next_frame: i32,
	temp_buffer: Vector(i8),
}

Window_Temp_Data :: struct {
	cursor_pos: [2]f32,
	cursor_pos_prev_line: [2]f32,
	cursor_start_pos: [2]f32,
	cursor_max_pos: [2]f32,
	ideal_max_pos: [2]f32,
	curr_line_size: [2]f32,
	prev_line_size: [2]f32,
	curr_line_text_base_offset: f32,
	prev_line_text_base_offset: f32,
	is_same_line: bool,
	is_set_pos: bool,
	indent: [1]f32,
	columns_offset: [1]f32,
	group_offset: [1]f32,
	cursor_start_pos_lossyness: [2]f32,
	nav_layer_current: Nav_Layer,
	nav_layers_active_mask: i16,
	nav_layers_active_mask_next: i16,
	nav_hide_highlight_one_frame: bool,
	nav_has_scroll: bool,
	menu_bar_appending: bool,
	menu_bar_offset: [2]f32,
	menu_columns: Menu_Columns,
	tree_depth: i32,
	tree_jump_to_parent_on_pop_mask: u32,
	child_windows: Vector(^Window),
	state_storage: ^Storage,
	current_columns: ^Old_Columns,
	current_table_idx: i32,
	layout_type: Layout_Type,
	parent_layout_type: Layout_Type,
	item_width: f32,
	text_wrap_pos: f32,
	item_width_stack: Vector(f32),
	text_wrap_pos_stack: Vector(f32),
}

Window :: struct {
	ctx: ^Context,
	name: ^i8,
	id: ID,
	flags: Window_Flags,
	viewport: ^Viewport_P,
	pos: [2]f32,
	size: [2]f32,
	size_full: [2]f32,
	content_size: [2]f32,
	content_size_ideal: [2]f32,
	content_size_explicit: [2]f32,
	window_padding: [2]f32,
	window_rounding: f32,
	window_border_size: f32,
	deco_outer_size_x1: f32,
	deco_outer_size_y1: f32,
	deco_outer_size_x2: f32,
	deco_outer_size_y2: f32,
	deco_inner_size_x1: f32,
	deco_inner_size_y1: f32,
	name_buf_len: i32,
	move_id: ID,
	child_id: ID,
	scroll: [2]f32,
	scroll_max: [2]f32,
	scroll_target: [2]f32,
	scroll_target_center_ratio: [2]f32,
	scroll_target_edge_snap_dist: [2]f32,
	scrollbar_sizes: [2]f32,
	scrollbar_x: bool,
	scrollbar_y: bool,
	active: bool,
	was_active: bool,
	write_accessed: bool,
	collapsed: bool,
	want_collapse_toggle: bool,
	skip_items: bool,
	appearing: bool,
	hidden: bool,
	is_fallback_window: bool,
	is_explicit_child: bool,
	has_close_button: bool,
	resize_border_held: i8,
	begin_count: i16,
	begin_count_previous_frame: i16,
	begin_order_within_parent: i16,
	begin_order_within_context: i16,
	focus_order: i16,
	popup_id: ID,
	auto_fit_frames_x: i8,
	auto_fit_frames_y: i8,
	auto_fit_child_axises: i8,
	auto_fit_only_grows: bool,
	auto_pos_last_direction: Dir,
	hidden_frames_can_skip_items: i8,
	hidden_frames_cannot_skip_items: i8,
	hidden_frames_for_render_only: i8,
	disable_inputs_frames: i8,
	set_window_pos_allow_flags: Cond,
	set_window_size_allow_flags: Cond,
	set_window_collapsed_allow_flags: Cond,
	set_window_pos_val: [2]f32,
	set_window_pos_pivot: [2]f32,
	id_stack: Vector(ID),
	d_c: Window_Temp_Data,
	outer_rect_clipped: Rect,
	inner_rect: Rect,
	inner_clip_rect: Rect,
	work_rect: Rect,
	parent_work_rect: Rect,
	clip_rect: Rect,
	content_region_rect: Rect,
	hit_test_hole_size: [2]i16,
	hit_test_hole_offset: [2]i16,
	last_frame_active: i32,
	last_time_active: f32,
	item_width_default: f32,
	state_storage: Storage,
	columns_storage: Vector(Old_Columns),
	font_window_scale: f32,
	settings_offset: i32,
	draw_list: ^Draw_List,
	draw_list_inst: Draw_List,
	parent_window: ^Window,
	parent_window_in_begin_stack: ^Window,
	root_window: ^Window,
	root_window_popup_tree: ^Window,
	root_window_for_title_bar_highlight: ^Window,
	root_window_for_nav: ^Window,
	nav_last_child_nav_window: ^Window,
	nav_last_ids: [ImGuiNavLayer_COUNT]ID,
	nav_rect_rel: [ImGuiNavLayer_COUNT]Rect,
	nav_root_focus_scope_id: ID,
	memory_draw_list_idx_capacity: i32,
	memory_draw_list_vtx_capacity: i32,
	memory_compacted: bool,
}

Tab_Bar_Flags_Private_ :: enum i32 {
	Dock_Node = (1 << 20),
	Is_Focused = (1 << 21),
	Save_Settings = (1 << 22),
}

Tab_Item_Flags_Private_ :: enum i32 {
	Section_Mask_ = (ImGuiTabItemFlags_Leading | ImGuiTabItemFlags_Trailing),
	No_Close_Button = (1 << 20),
	Button = (1 << 21),
}

Tab_Item :: struct {
	id: ID,
	flags: Tab_Item_Flags,
	last_frame_visible: i32,
	last_frame_selected: i32,
	offset: f32,
	width: f32,
	content_width: f32,
	requested_width: f32,
	name_offset: i32,
	begin_order: i16,
	index_during_layout: i16,
	want_close: bool,
}

Tab_Bar :: struct {
	tabs: Vector(Tab_Item),
	flags: Tab_Bar_Flags,
	id: ID,
	selected_tab_id: ID,
	next_selected_tab_id: ID,
	visible_tab_id: ID,
	curr_frame_visible: i32,
	prev_frame_visible: i32,
	bar_rect: Rect,
	curr_tabs_contents_height: f32,
	prev_tabs_contents_height: f32,
	width_all_tabs: f32,
	width_all_tabs_ideal: f32,
	scrolling_anim: f32,
	scrolling_target: f32,
	scrolling_target_dist_to_visibility: f32,
	scrolling_speed: f32,
	scrolling_rect_min_x: f32,
	scrolling_rect_max_x: f32,
	reorder_request_tab_id: ID,
	reorder_request_offset: i16,
	begin_count: i8,
	want_layout: bool,
	visible_tab_was_submitted: bool,
	tabs_added_new: bool,
	tabs_active_count: i16,
	last_tab_item_idx: i16,
	item_spacing_y: f32,
	frame_padding: [2]f32,
	backup_cursor_pos: [2]f32,
	tabs_names: Text_Buffer,
}
Table_Column_Idx :: distinct i16
Table_Draw_Channel_Idx :: distinct u16

Table_Column :: struct {
	flags: Table_Column_Flags,
	width_given: f32,
	min_x: f32,
	max_x: f32,
	width_request: f32,
	width_auto: f32,
	stretch_weight: f32,
	init_stretch_weight_or_width: f32,
	clip_rect: Rect,
	user_id: ID,
	work_min_x: f32,
	work_max_x: f32,
	item_width: f32,
	content_max_x_frozen: f32,
	content_max_x_unfrozen: f32,
	content_max_x_headers_used: f32,
	content_max_x_headers_ideal: f32,
	name_offset: i16,
	display_order: Table_Column_Idx,
	index_within_enabled_set: Table_Column_Idx,
	prev_enabled_column: Table_Column_Idx,
	next_enabled_column: Table_Column_Idx,
	sort_order: Table_Column_Idx,
	draw_channel_current: Table_Draw_Channel_Idx,
	draw_channel_frozen: Table_Draw_Channel_Idx,
	draw_channel_unfrozen: Table_Draw_Channel_Idx,
	is_enabled: bool,
	is_user_enabled: bool,
	is_user_enabled_next_frame: bool,
	is_visible_x: bool,
	is_visible_y: bool,
	is_request_output: bool,
	is_skip_items: bool,
	is_preserve_width_auto: bool,
	nav_layer_current: i8,
	auto_fit_queue: u8,
	cannot_skip_items_queue: u8,
	sort_direction: u8,
	sort_directions_avail_count: u8,
	sort_directions_avail_mask: u8,
	sort_directions_avail_list: u8,
}

Table_Cell_Data :: struct {
	bg_color: u32,
	column: Table_Column_Idx,
}

Table_Instance_Data :: struct {
	table_instance_id: ID,
	last_outer_height: f32,
	last_first_row_height: f32,
	last_frozen_height: f32,
}

Table :: struct {
	id: ID,
	flags: Table_Flags,
	raw_data: rawptr,
	temp_data: ^Table_Temp_Data,
	columns: Span(Table_Column),
	display_order_to_index: Span(Table_Column_Idx),
	row_cell_data: Span(Table_Cell_Data),
	enabled_mask_by_display_order: Bit_Array_Ptr,
	enabled_mask_by_index: Bit_Array_Ptr,
	visible_mask_by_index: Bit_Array_Ptr,
	settings_loaded_flags: Table_Flags,
	settings_offset: i32,
	last_frame_active: i32,
	columns_count: i32,
	current_row: i32,
	current_column: i32,
	instance_current: i16,
	instance_interacted: i16,
	row_pos_y1: f32,
	row_pos_y2: f32,
	row_min_height: f32,
	row_text_baseline: f32,
	row_indent_offset_x: f32,
	row_flags: Table_Row_Flags,
	last_row_flags: Table_Row_Flags,
	row_bg_color_counter: i32,
	row_bg_color: [2]u32,
	border_color_strong: u32,
	border_color_light: u32,
	border_x1: f32,
	border_x2: f32,
	host_indent_x: f32,
	min_column_width: f32,
	outer_padding_x: f32,
	cell_padding_x: f32,
	cell_padding_y: f32,
	cell_spacing_x1: f32,
	cell_spacing_x2: f32,
	inner_width: f32,
	columns_given_width: f32,
	columns_auto_fit_width: f32,
	columns_stretch_sum_weights: f32,
	resized_column_next_width: f32,
	resize_lock_min_contents_x2: f32,
	ref_scale: f32,
	outer_rect: Rect,
	inner_rect: Rect,
	work_rect: Rect,
	inner_clip_rect: Rect,
	bg_clip_rect: Rect,
	bg0_clip_rect_for_draw_cmd: Rect,
	bg2_clip_rect_for_draw_cmd: Rect,
	host_clip_rect: Rect,
	host_backup_inner_clip_rect: Rect,
	outer_window: ^Window,
	inner_window: ^Window,
	columns_names: Text_Buffer,
	draw_splitter: ^Draw_List_Splitter,
	instance_data_first: Table_Instance_Data,
	instance_data_extra: Vector(Table_Instance_Data),
	sort_specs_single: Table_Column_Sort_Specs,
	sort_specs_multi: Vector(Table_Column_Sort_Specs),
	sort_specs: Table_Sort_Specs,
	sort_specs_count: Table_Column_Idx,
	columns_enabled_count: Table_Column_Idx,
	columns_enabled_fixed_count: Table_Column_Idx,
	decl_columns_count: Table_Column_Idx,
	hovered_column_body: Table_Column_Idx,
	hovered_column_border: Table_Column_Idx,
	auto_fit_single_column: Table_Column_Idx,
	resized_column: Table_Column_Idx,
	last_resized_column: Table_Column_Idx,
	held_header_column: Table_Column_Idx,
	reorder_column: Table_Column_Idx,
	reorder_column_dir: Table_Column_Idx,
	left_most_enabled_column: Table_Column_Idx,
	right_most_enabled_column: Table_Column_Idx,
	left_most_stretched_column: Table_Column_Idx,
	right_most_stretched_column: Table_Column_Idx,
	context_popup_column: Table_Column_Idx,
	freeze_rows_request: Table_Column_Idx,
	freeze_rows_count: Table_Column_Idx,
	freeze_columns_request: Table_Column_Idx,
	freeze_columns_count: Table_Column_Idx,
	row_cell_data_current: Table_Column_Idx,
	dummy_draw_channel: Table_Draw_Channel_Idx,
	bg2_draw_channel_current: Table_Draw_Channel_Idx,
	bg2_draw_channel_unfrozen: Table_Draw_Channel_Idx,
	is_layout_locked: bool,
	is_inside_row: bool,
	is_initializing: bool,
	is_sort_specs_dirty: bool,
	is_using_headers: bool,
	is_context_popup_open: bool,
	is_settings_request_load: bool,
	is_settings_dirty: bool,
	is_default_display_order: bool,
	is_reset_all_request: bool,
	is_reset_display_order_request: bool,
	is_unfrozen_rows: bool,
	is_default_sizing_policy: bool,
	has_scrollbar_y_curr: bool,
	has_scrollbar_y_prev: bool,
	memory_compacted: bool,
	host_skip_items: bool,
}

Table_Temp_Data :: struct {
	table_index: i32,
	last_time_active: f32,
	user_outer_size: [2]f32,
	draw_splitter: Draw_List_Splitter,
	host_backup_work_rect: Rect,
	host_backup_parent_work_rect: Rect,
	host_backup_prev_line_size: [2]f32,
	host_backup_curr_line_size: [2]f32,
	host_backup_cursor_max_pos: [2]f32,
	host_backup_columns_offset: [1]f32,
	host_backup_item_width: f32,
	host_backup_item_width_stack_size: i32,
}

Table_Column_Settings :: struct {
	width_or_weight: f32,
	user_id: ID,
	index: Table_Column_Idx,
	display_order: Table_Column_Idx,
	sort_order: Table_Column_Idx,
	sort_direction: u8,
	is_enabled: u8,
	is_stretch: u8,
}

Table_Settings :: struct {
	id: ID,
	save_flags: Table_Flags,
	ref_scale: f32,
	columns_count: Table_Column_Idx,
	columns_count_max: Table_Column_Idx,
	want_apply: bool,
}

Font_Builder_IO :: struct {
	font_builder__build: proc "c" (atlas: ^Font_Atlas) -> bool,
}
