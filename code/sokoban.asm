
include sokoban_input.inc
include sokoban_asset.inc
include sokoban_struct.inc

bmp_header struct
	MagicValue		u16 ?
	FileSize		u32 ?
	Reserved		u32 ?
	BitmapOffset	u32 ?
	biSize			u32 ?
	biWidth			s32 ?
	biHeight		s32 ?
	biPlanes		u16 ?
	biBitCount		u16 ?
	biCompression	u32 ?
	biSizeImage		u32 ?
	biXPelsPerMeter	s32 ?
	biYPelsPerMeter	s32 ?
	biClrUsed		u32 ?
	biClrImportant	u32 ?
bmp_header ends

.data
BoxPath char "asset/box.bmp", 0
PlayerPath char "asset/player.bmp", 0
KeyPath char "asset/key.bmp", 0
FontPath char "asset/consola.ttf", 0
FontFace char "Consolas", 0
TestStr char "HELLg, worlD!", 0
LevelPath char "level/level1.lvl", 0

.code
SokobanInit proto, GameState: ptr game_state, Platform: ptr platform_state, Assets: ptr game_asset, GameTransform: ptr render_transform, ScreenTransform: ptr render_transform, Level: ptr ptr game_level
SokobanUpdate proto, GameState: ptr game_state, GameInput: ptr game_input, Assets: ptr game_asset, GameTransform: ptr render_transform, ScreenTransform: ptr render_transform, Level: ptr ptr game_level, WindowWidth: s32, WindowHeight: s32
SokobanRender proto, GameState: ptr game_state, WindowWidth: s32, WindowHeight: s32, Assets: ptr game_asset, GameTransform: ptr render_transform, ScreenTransform: ptr render_transform, Level: ptr ptr game_level

GetBitmapHandle proc, Assets: ptr game_asset, BitmapId: u32
	mov eax, BitmapId
	mov edi, Assets
	mov eax, [(game_asset ptr[edi]).BitmapHandles + (sizeof u32)*eax]
	ret
GetBitmapHandle endp

GetGlyphHandle proc, Assets: ptr game_asset, FontId: u32, Codepoint: u32
	mov eax, FontId
	mov edi, Assets
	lea edi, [(game_asset ptr[edi]).GlyphHandles]
	mov eax, FontId
	shl eax, 8
	or eax, Codepoint
	imul eax, sizeof u32
	add edi, eax
	mov eax, [edi]
	ret
GetGlyphHandle endp

GetBitmapInfo proc, Assets: ptr game_asset, BitmapId: u32, Result: ptr ptr loaded_bitmap
	mov edi, Assets
	lea edi, [(game_asset ptr[edi]).Bitmaps]
	mov eax, BitmapId
	imul eax, sizeof loaded_bitmap
	add edi, eax
	mov eax, Result
	mov [eax], edi
	ret
GetBitmapInfo endp

GetFontInfo proc, Assets: ptr game_asset, FontId: u32, Result: ptr ptr loaded_font
	mov edi, Assets
	lea edi, [(game_asset ptr[edi]).Fonts]
	mov eax, FontId
	imul eax, sizeof loaded_font
	add edi, eax
	mov eax, Result
	mov [eax], edi
	ret
GetFontInfo endp

GetGlyphInfo proc, Assets: ptr game_asset, FontId: u32, Codepoint: u32, Result: ptr ptr loaded_bitmap
	local Font: ptr loaded_font
	invoke GetFontInfo, Assets, FontId, addr Font
	
	mov edi, Font
	lea edi, [(loaded_font ptr[edi]).Glyphs]
	mov eax, Codepoint
	imul eax, sizeof loaded_bitmap
	add edi, eax
	mov eax, Result
	mov [eax], edi
	ret
GetGlyphInfo endp

LoadBitmap proc, Platform: ptr platform_state, Assets: ptr game_asset, BitmapId: u32, Path: ptr char
	local File: loaded_file
	local BitmapWidth: s32
	local BitmapHeight: s32
	mov edx, Platform
	invoke (platform_state ptr[edx]).LoadFile, Path, addr File
	mov esi, File.Buffer
	mov edi, Assets
	lea edi, (game_asset ptr[edi]).Bitmaps
	assume edi: ptr loaded_bitmap
	mov eax, sizeof loaded_bitmap
	imul BitmapId
	add edi, eax
	mov_mem [edi].BitmapWidth, (bmp_header ptr[esi]).biWidth, eax
	mov_mem [edi].BitmapHeight, (bmp_header ptr[esi]).biHeight, eax
	add esi, (bmp_header ptr[esi]).BitmapOffset
	mov [edi].Buffer, esi
;	mov ecx, [edi].BitmapWidth
;	imul ecx, [edi].BitmapHeight
;START_PIXEL_OPS:
;	cmp ecx, 0
;	jle END_PIXEL_OPS
;	mov ebx, [esi]
;	or ebx, 0ff000000h
;	mov [esi], ebx
;	add esi, 4
;	dec ecx
;	jmp START_PIXEL_OPS
;END_PIXEL_OPS:
	mov esi, Assets
	mov eax, BitmapId
	lea esi, [(game_asset ptr[esi]).BitmapHandles + (sizeof u32)*eax]
	invoke OpenglAllocateTexture, [edi].BitmapWidth, [edi].BitmapHeight, [edi].Buffer, esi
	assume edi: nothing
	ret
LoadBitmap endp

LoadFont proc, Platform: ptr platform_state, Assets: ptr game_asset, FontId: u32, Path: ptr char, FaceName: ptr char
	local RenderContext: u32
	local Font: ptr loaded_font
	local Codepoint: u32
	local GlyphInfo: ptr loaded_bitmap
	
	mov edx, Assets
	lea edx, (game_asset ptr[edx]).Fonts
	mov eax, sizeof loaded_font
	imul eax, FontId
	add edx, eax
	mov Font, edx
	mov edx, Platform
	mov_mem RenderContext, (platform_state ptr[edx]).RenderContext, ebx
	invoke (platform_state ptr[edx]).LoadFont, RenderContext, Path, FaceName, Font
	mov ecx, 255
START_ADD_GLYPH:
	cmp ecx, 0
	mov Codepoint, ecx
	jle END_ADD_GLYPH
		invoke GetGlyphInfo, Assets, FontId, Codepoint, addr GlyphInfo
		mov eax, FontId
		mov edi, Assets
		lea edi, [(game_asset ptr[edi]).GlyphHandles]
		mov eax, FontId
		shl eax, 8
		or eax, Codepoint
		imul eax, sizeof u32
		add edi, eax
		
		mov esi, GlyphInfo
		assume esi: ptr loaded_bitmap
		push ecx
		invoke OpenglAllocateTexture, [esi].BitmapWidth, [esi].BitmapHeight, [esi].Buffer, edi
		pop ecx
		assume esi: nothing
	dec ecx
	jmp START_ADD_GLYPH
END_ADD_GLYPH:
	ret
LoadFont endp

IsDown proc, Input: ptr game_input, ButtonIndex: u32
	mov esi, Input
	lea esi, [(game_input ptr[esi]).Buttons]
	mov eax, ButtonIndex
	mov eax, [esi + (sizeof b32)*eax]
	ret
IsDown endp

WasDown proc, Input: ptr game_input, ButtonIndex: u32
	mov esi, Input
	lea esi, [(game_input ptr[esi]).LastButtons]
	mov eax, ButtonIndex
	mov eax, [esi + (sizeof b32)*eax]
	ret
WasDown endp

IsPressed proc, Input: ptr game_input, ButtonIndex: u32
	invoke WasDown, Input, ButtonIndex
	test eax, eax
	jz WAS_NOT_DOWN
	ret
WAS_NOT_DOWN:
	;Result equals IsDown()
	invoke IsDown, Input, ButtonIndex
	ret
IsPressed endp

WasPressed proc, Input: ptr game_input, ButtonIndex: u32
	invoke IsDown, Input, ButtonIndex
	test eax, eax
	jz IS_NOT_DOWN
	ret
IS_NOT_DOWN:
	;Result equals WasDown()
	invoke WasDown, Input, ButtonIndex
	ret
WasPressed endp

SafeRatio1 macro A, B
	local SAFE_RATIO, lbl
	local DONE, lbl
	comiss B, f1_
	je SAFE_RATIO
	divss A, B
	jmp DONE
SAFE_RATIO:
	movss A, f1_
DONE:
endm

DrawBitmap proc, Transform: ptr render_transform, Assets: ptr game_asset, BitmapId: u32, MinX: f32, MinY: f32, MaxX: f32, MaxY: f32, R: f32, G: f32, B: f32, A: f32
	mov eax, Transform
	movss xmm0, (render_transform ptr[eax]).CameraX
	movss xmm1, (render_transform ptr[eax]).CameraY
	movss xmm2, (render_transform ptr[eax]).ScaleX
	movss xmm3, (render_transform ptr[eax]).ScaleY
	;MinX
	movss xmm4, MinX
	subss xmm4, xmm0
	mulss xmm4, xmm2
	movss MinX, xmm4
	;MinY
	movss xmm4, MinY
	subss xmm4, xmm1
	mulss xmm4, xmm3
	movss MinY, xmm4
	;MaxX
	movss xmm4, MaxX
	subss xmm4, xmm0
	mulss xmm4, xmm2
	movss MaxX, xmm4
	;MaxY
	movss xmm4, MaxY
	subss xmm4, xmm1
	mulss xmm4, xmm3
	movss MaxY, xmm4
	push ebx
	push ecx
	push edx
	invoke GetBitmapHandle, Assets, BitmapId
	invoke OpenglTexturedQuad, MinX, MinY, MaxX, MaxY, R, G, B, A, eax
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret
DrawBitmap endp

DrawString proc, Transform: ptr render_transform, Assets: ptr game_asset, 
	String: ptr char, FontId: u32, X: f32, Y: f32, Height: f32, AlignX: u32, AlignY: u32, R: f32, G: f32, B: f32, A: f32
	local MinX: f32
	local MinY: f32
	local MaxX: f32
	local MaxY: f32
	local Codepoint: u32
	local StringWidth: f32
	local Font: ptr loaded_font
	local Glyph: ptr loaded_bitmap
	local GlyphRatio: f32
	local CameraX: f32
	local CameraY: f32
	
	mov edx, AlignX
	cmp edx, AlignX_ToLeft
	jz X_ALIGN_TO_LEFT
	cmp edx, AlignX_ToMiddle
	jz X_ALIGN_TO_MIDDLE
	cmp edx, AlignX_ToRight
	jz X_ALIGN_TO_RIGHT
	Assert(0)
X_ALIGN_TO_LEFT:
	jmp END_X_ALIGN
X_ALIGN_TO_MIDDLE:
	mov_mem StringWidth, f0_, ebx
	mov esi, String
M_START_STRING_X_COUNT:
	movzx eax, char ptr[esi]
	test eax, eax
	jz M_END_STRING_X_COUNT
		mov Codepoint, eax
		invoke GetGlyphInfo, Assets, FontId, Codepoint, addr Glyph
		mov eax, Glyph
		cvtsi2ss xmm0, (loaded_bitmap ptr[eax]).BitmapWidth
		cvtsi2ss xmm1, (loaded_bitmap ptr[eax]).BitmapHeight
		SafeRatio1 xmm0, xmm1
		mulss xmm0, Height
		addss xmm0, StringWidth
		movss StringWidth, xmm0
	inc esi
	jmp M_START_STRING_X_COUNT
M_END_STRING_X_COUNT:
	movss xmm1, StringWidth
	divss xmm1, f2_
	movss xmm0, X
	subss xmm0, xmm1
	movss X, xmm0
	jmp END_X_ALIGN
X_ALIGN_TO_RIGHT:
	mov_mem StringWidth, f0_, ebx
	mov esi, String
R_START_STRING_X_COUNT:
	movzx eax, char ptr[esi]
	test eax, eax
	jz R_END_STRING_X_COUNT
		mov Codepoint, eax
		invoke GetGlyphInfo, Assets, FontId, Codepoint, addr Glyph
		mov eax, Glyph
		cvtsi2ss xmm0, (loaded_bitmap ptr[eax]).BitmapWidth
		cvtsi2ss xmm1, (loaded_bitmap ptr[eax]).BitmapHeight
		SafeRatio1 xmm0, xmm1
		mulss xmm0, Height
		addss xmm0, StringWidth
		movss StringWidth, xmm0
	inc esi
	jmp R_START_STRING_X_COUNT
R_END_STRING_X_COUNT:
	movss xmm0, X
	subss xmm0, StringWidth
	movss X, xmm0
	jmp END_X_ALIGN
END_X_ALIGN:
	mov edx, AlignY
	cmp edx, AlignY_ToBaseLine
	jz Y_ALIGN_TO_BASELINE
	cmp edx, AlignY_ToTop
	jz Y_ALIGN_TO_TOP
	cmp edx, AlignY_ToBottom
	jz Y_ALIGN_TO_BOTTOM
	jmp END_Y_ALIGN
Y_ALIGN_TO_BASELINE:
	invoke GetFontInfo, Assets, FontId, addr Font
	mov esi, Font
	cvtsi2ss xmm1, (loaded_font ptr[esi]).Descent
	cvtsi2ss xmm2, (loaded_font ptr[esi]).Ascent
	addss xmm2, xmm1
	mulss xmm1, Height
	divss xmm1, xmm2
	movss xmm0, Y
	subss xmm0, xmm1
	movss Y, xmm0
	jmp END_Y_ALIGN
Y_ALIGN_TO_TOP:
	invoke GetFontInfo, Assets, FontId, addr Font
	mov esi, Font
	movss xmm0, Y
	subss xmm0, Height
	movss Y, xmm0
	jmp END_Y_ALIGN
Y_ALIGN_TO_BOTTOM:
	jmp END_Y_ALIGN
END_Y_ALIGN:
	
	mov esi, String
START_DRAW_CODEPOINT:
	movzx eax, char ptr[esi]
	test eax, eax
	jz END_DRAW_CODEPOINT
		mov Codepoint, eax
		invoke GetGlyphInfo, Assets, FontId, Codepoint, addr Glyph
		mov eax, Glyph
		cvtsi2ss xmm4, (loaded_bitmap ptr[eax]).BitmapWidth
		cvtsi2ss xmm5, (loaded_bitmap ptr[eax]).BitmapHeight
		SafeRatio1 xmm4, xmm5
		mov eax, Transform
		movss xmm0, (render_transform ptr[eax]).CameraX
		movss xmm1, (render_transform ptr[eax]).CameraY
		movss xmm2, (render_transform ptr[eax]).ScaleX
		movss xmm3, (render_transform ptr[eax]).ScaleY
		mov_mem MinX, X, ebx
		mov_mem MinY, Y, ebx
		movss xmm5, MinY
		addss xmm5, Height
		movss MaxY, xmm5
		movss xmm5, MinX
		mulss xmm4, Height
		addss xmm5, xmm4
		movss MaxX, xmm5
		mov_mem X, MaxX, ebx
		;MinX
		movss xmm4, MinX
		subss xmm4, xmm0
		mulss xmm4, xmm2
		movss MinX, xmm4
		;MinY
		movss xmm4, MinY
		subss xmm4, xmm1
		mulss xmm4, xmm3
		movss MinY, xmm4
		;MaxX
		movss xmm4, MaxX
		subss xmm4, xmm0
		mulss xmm4, xmm2
		movss MaxX, xmm4
		;MaxY
		movss xmm4, MaxY
		subss xmm4, xmm1
		mulss xmm4, xmm3
		movss MaxY, xmm4
		push ebx
		push ecx
		push edx
		movzx eax, char ptr[esi]
		invoke GetGlyphHandle, Assets, FontId, eax
		invoke OpenglTexturedQuad, MinX, MinY, MaxX, MaxY, R, G, B, A, eax
		pop edx
		pop ecx
		pop ebx
	inc esi
	jmp START_DRAW_CODEPOINT
END_DRAW_CODEPOINT:
	ret
DrawString endp

StartTransformByHeight proc, Transform: ptr render_transform, DisplayHeight: f32, WindowWidth: s32, WindowHeight: s32
	movss xmm1, f2_
	divss xmm1, DisplayHeight
	movss xmm0, xmm1
	cvtsi2ss xmm2, WindowWidth
	cvtsi2ss xmm3, WindowHeight
	SafeRatio1 xmm2, xmm3
	divss xmm0, xmm2
	mov edi, Transform
	movss (render_transform ptr[edi]).ScaleX, xmm0
	movss (render_transform ptr[edi]).ScaleY, xmm1
	ret
StartTransformByHeight endp

FreeLevel proc, Platform: ptr platform_state, Level: ptr game_level
	mov edx, Platform
	invoke (platform_state ptr[edx]).FreeMemory, Level
	ret
FreeLevel endp

SaveLevel proc, GameState: ptr game_state, Platform: ptr platform_state, Path: ptr char
	local Level: ptr game_level
	
	mov eax, GameState
	mov eax, (game_state ptr[eax]).Level
	mov Level, eax
	Assert(Level)
	mov edx, Platform
	invoke (platform_state ptr[edx]).WriteFile, Path, sizeof game_level, Level
	ret
SaveLevel endp

LoadLevel proc, GameState: ptr game_state, Platform: ptr platform_state, Path: ptr char
	local LevelFile: loaded_file
	local Level: ptr game_level
	mov eax, GameState
	mov eax, (game_state ptr[eax]).Level
	test eax, eax
	jz GAME_HAS_NO_LEVEL
	mov Level, eax
	invoke FreeLevel, Platform, Level
GAME_HAS_NO_LEVEL:
	mov edx, Platform
	mov Level, eax
	invoke (platform_state ptr[edx]).LoadFile, Path, addr LevelFile
	cmp LevelFile.FileSize, sizeof game_level
	jne LEVEL_LOAD_FAILED
	
	mov eax, GameState
	lea eax, [(game_state ptr[eax]).Level]
	mov_mem [eax], LevelFile.Buffer, ebx
LEVEL_LOAD_FAILED:
	ret
LoadLevel endp

SetCameraP proc, Transform: ptr render_transform, X: f32, Y: f32
	mov eax, Transform
	mov_mem (render_transform ptr[eax]).CameraX, X, ebx
	mov_mem (render_transform ptr[eax]).CameraY, Y, ebx
	ret
SetCameraP endp

AddCameraP proc, Transform: ptr render_transform, X: f32, Y: f32
	mov eax, Transform
	movss xmm0, (render_transform ptr[eax]).CameraX
	addss xmm0, X
	movss (render_transform ptr[eax]).CameraX, xmm0
	movss xmm0, (render_transform ptr[eax]).CameraY
	addss xmm0, Y
	movss (render_transform ptr[eax]).CameraY, xmm0
	ret
AddCameraP endp

TransformMouse proc, Input: ptr game_input, Transform: ptr render_transform, WindowWidth: s32, WindowHeight: s32
	local X: f32
	local Y: f32
	mov eax, Input
	cvtsi2ss xmm0, (game_input ptr[eax]).MouseX
	cvtsi2ss xmm1, WindowWidth
	divss xmm0, xmm1
	subss xmm0, f_5
	mulss xmm0, f2_
	mov eax, Transform
	movss xmm1, (render_transform ptr[eax]).ScaleX
	SafeRatio1 xmm0, xmm1
	addss xmm0, (render_transform ptr[eax]).CameraX
	movss X, xmm0
	mov eax, Input
	cvtsi2ss xmm0, (game_input ptr[eax]).MouseY
	cvtsi2ss xmm1, WindowHeight
	divss xmm0, xmm1
	subss xmm0, f_5
	mulss xmm0, f2_
	mov eax, Transform
	movss xmm1, (render_transform ptr[eax]).ScaleY
	SafeRatio1 xmm0, xmm1
	addss xmm0, (render_transform ptr[eax]).CameraY
	movss Y, xmm0
	movss xmm0, X
	movss xmm1, Y
	ret
TransformMouse endp

GameInit proc, GameState: ptr game_state, Platform: ptr platform_state
	local Assets: ptr game_asset
	local GameTransform: ptr render_transform
	local ScreenTransform: ptr render_transform
	local Level: ptr ptr game_level
	mov eax, GameState
	lea_mem Assets, (game_state ptr[eax]).Assets, ebx
	lea_mem GameTransform, (game_state ptr[eax]).GameTransform, ebx
	lea_mem ScreenTransform, (game_state ptr[eax]).ScreenTransform, ebx
	lea_mem Level, (game_state ptr[eax]).Level, ebx
	
	invoke SokobanInit, GameState, Platform, Assets, GameTransform, ScreenTransform, Level
	ret
GameInit endp

GameUpdate proc, GameState: ptr game_state, GameInput: ptr game_input, WindowWidth: s32, WindowHeight: s32
	local Assets: ptr game_asset
	local GameTransform: ptr render_transform
	local ScreenTransform: ptr render_transform
	local Level: ptr ptr game_level
	mov eax, GameState
	lea_mem Assets, (game_state ptr[eax]).Assets, ebx
	lea_mem GameTransform, (game_state ptr[eax]).GameTransform, ebx
	lea_mem ScreenTransform, (game_state ptr[eax]).ScreenTransform, ebx
	lea_mem Level, (game_state ptr[eax]).Level, ebx
	
	invoke IsPressed, GameInput, Button_DevMode
	test eax, eax
	jz IN_DEVMODE_IS_NOT_PRESSED
	mov edx, GameState
	mov eax, (game_state ptr[edx]).InDevMode
	xor eax, 1
	mov (game_state ptr[edx]).InDevMode, eax
IN_DEVMODE_IS_NOT_PRESSED:
	invoke SokobanUpdate, GameState, GameInput, Assets, GameTransform, ScreenTransform, Level, WindowWidth, WindowHeight
	ret
GameUpdate endp

GameRender proc, GameState: ptr game_state, WindowWidth: s32, WindowHeight: s32
	local FloatWindowHeight: f32
	local HalfWidth: f32
	local HalfHeight: f32
	local Assets: ptr game_asset
	local GameTransform: ptr render_transform
	local ScreenTransform: ptr render_transform
	local Level: ptr ptr game_level
	
	
	mov eax, GameState
	lea_mem Assets, (game_state ptr[eax]).Assets, ebx
	lea_mem GameTransform, (game_state ptr[eax]).GameTransform, ebx
	lea_mem ScreenTransform, (game_state ptr[eax]).ScreenTransform, ebx
	lea_mem Level, (game_state ptr[eax]).Level, ebx
	
	cvtsi2ss xmm0, WindowHeight
	movss FloatWindowHeight, xmm0
	invoke StartTransformByHeight, ScreenTransform, FloatWindowHeight, WindowWidth, WindowHeight
	
	cvtsi2ss xmm0, WindowWidth
	divss xmm0, f2_
	movss HalfWidth, xmm0
	cvtsi2ss xmm0, WindowHeight
	divss xmm0, f2_
	movss HalfHeight, xmm0
	mov eax, ScreenTransform
	mov_mem (render_transform ptr[eax]).CameraX, HalfWidth, ebx
	mov_mem (render_transform ptr[eax]).CameraY, HalfHeight, ebx
	
	invoke glViewport, 0, 0, WindowWidth, WindowHeight
	invoke glClear, GL_COLOR_BUFFER_BIT
	invoke SokobanRender, GameState, WindowWidth, WindowHeight, Assets, GameTransform, ScreenTransform, Level
	
	ret
GameRender endp