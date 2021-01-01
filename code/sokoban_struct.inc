
AlignX_ToLeft	equ 0
AlignX_ToMiddle	equ 1
AlignX_ToRight	equ 2
AlignY_ToBaseLine	equ 0
AlignY_ToTop		equ 1
AlignY_ToBottom		equ 2

loaded_bitmap struct
	BitmapWidth		s32 ?
	BitmapHeight	s32 ?
	Buffer			voidptr ?
loaded_bitmap ends

loaded_font struct
	Ascent s32 ?
	Descent s32 ?
	Glyphs loaded_bitmap 256 dup(<>)
loaded_font ends

platform_free_memory typedef proto, Memory: voidptr
platform_load_file typedef proto, Path: ptr char, Result: ptr loaded_file
platform_write_file typedef proto, Path: ptr char, BufferSize: u32, Buffer: voidptr
platform_load_font typedef proto, RenderContext: u32, Path: ptr char, FaceName: ptr char, Result: ptr loaded_font
platform_free_memory_ptr typedef ptr platform_free_memory
platform_load_file_ptr typedef ptr platform_load_file
platform_write_file_ptr typedef ptr platform_write_file
platform_load_font_ptr typedef ptr platform_load_font
platform_state struct
	RenderContext u32 0
	FreeMemory	platform_free_memory_ptr 0
	LoadFile	platform_load_file_ptr 0
	WriteFile	platform_write_file_ptr 0
	LoadFont	platform_load_font_ptr 0
platform_state ends

game_input struct
	MouseX s32 ?
	MouseY s32 ?
	WheelDelta s32 ?
	Buttons		b32 Button_Count dup(?)
	LastButtons	b32 Button_Count dup(?)
game_input ends

game_asset struct
	Bitmaps loaded_bitmap Bitmap_Count dup(<>)
	BitmapHandles u32 Bitmap_Count dup(0)
	
	Fonts loaded_font Font_Count dup (<>)
	GlyphHandles u32 Font_Count*256 dup(0)
game_asset ends

render_transform struct
	ScaleX f32 ?
	ScaleY f32 ?
	CameraX f32 ?
	CameraY f32 ?
render_transform ends

game_level struct
	LevelVars s32 1024 dup(?)
	LevelMap u8 65536 dup(?)
game_level ends

game_state struct
	InDevMode b32 ?
	Assets game_asset <>
	GameTransform render_transform <>
	ScreenTransform render_transform <>
	Level voidptr ?
game_state ends
