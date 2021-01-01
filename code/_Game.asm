
;game-relative struct difinitions are in "sokoban_struct.inc"

;----------ASSET-----------
;LoadBitmap proc, Platform: ptr platform_state, Assets: ptr game_asset, BitmapId: u32, Path: ptr char
;Load a bitmap from disk into the game, so the game can access it from its bitmap id.
;Bitmap Ids are inside sokoban_asset.inc.

;LoadFont proc, Platform: ptr platform_state, Assets: ptr game_asset, FontId: u32, Path: ptr char, FaceName: ptr char
;Load a font from disk into the game, you need specify 'FaceName' with the font name because Windows say so, 
;the game can therefore access it from its bitmap id.
;Font Ids are inside sokoban_asset.inc.


;----------INPUT----------
;Button Ids are in sokoban_input.inc

;IsDown proc, Input: ptr game_input, ButtonIndex: u32
;Tell if a specific button is being held down.
;returns in eax

;WasDown proc, Input: ptr game_input, ButtonIndex: u32
;Tell if a specific button is held down last frame, it might also be held down at this frame.
;returns in eax

;IsPressed proc, Input: ptr game_input, ButtonIndex: u32
;Tell if a specific button is pressed at this frame, only return 1 when this is the frame the 
;button start being held.
;returns in eax

;WasPressed proc, Input: ptr game_input, ButtonIndex: u32
;Tell if a specific button is released at this frame, only return 1 when this is the frame the 
;button stop being held. 
;returns in eax

;----------TRANSFORM-----------
;StartTransformByHeight proc, Transform: ptr render_transform, DisplayHeight: f32, WindowWidth: s32, WindowHeight: s32
;Scale Transform space so it can fit DisplayHeight meter vertically in the screen, 
;you must call this function every frame, because the window's size might change every frame.
;e.g. when DisplayHeight = 8, the screen will scale the world so it can fit 8 meter on the screen.

;SetCameraP proc, Transform: ptr render_transform, X: f32, Y: f32
;Set camera of Transform space to {X, Y}. (the camera coordiante will show at the center of the screen.)

;AddCameraP proc, Transform: ptr render_transform, X: f32, Y: f32
;Add {X, Y} to the camera of Transform space.

;TransformMouse proc, Input: ptr game_input, Transform: ptr render_transform, WindowWidth: s32, WindowHeight: s32
;Get the mouse position inside specific Transform space.
;returns in {xmm0, xmm1}

;----------RENDER-----------
;DrawBitmap proc, Transform: ptr render_transform, Assets: ptr game_asset, BitmapId: u32, MinX: f32, MinY: f32, MaxX: f32, MaxY: f32, R: f32, G: f32, B: f32, A: f32
;Draw a bitmap via bitmap id at {MinX, MinY} to {MaxX, MaxY} in Transform space, 
;with a (R, G, B, A) filter on it. 

;DrawString proc, Transform: ptr render_transform, Assets: ptr game_asset, String: ptr char, FontId: u32, X: f32, Y: f32, Height: f32, AlignX: u32, AlignY: u32, R: f32, G: f32, B: f32, A: f32
;Draw a string at via font id at {X, Y} in Transform space, 
;you can specify how string aligned horizontally and vertically by AlignX and AlignY
;AlignX_ToLeft
;AlignX_ToMiddle
;AlignX_ToRight
;AlignY_ToBaseLine
;AlignY_ToTop
;AlignY_ToBottom

;----------LEVEL-------------
;SaveLevel proc, GameState: ptr game_state, Platform: ptr platform_state, Path: ptr char
;Save the game's current level to Path.

;LoadLevel proc, GameState: ptr game_state, Platform: ptr platform_state, Path: ptr char
;Load the game's current level from Path.


.data

.code

SokobanInit proc, GameState: ptr game_state, Platform: ptr platform_state, 
	Assets: ptr game_asset, GameTransform: ptr render_transform, ScreenTransform: ptr render_transform, 
	Level: ptr ptr game_level
	
	;
	;Init Code
	;
	invoke SetCameraP, GameTransform, f4_, f4_
	invoke LoadBitmap, Platform, Assets, Bitmap_Box, offset BoxPath
	invoke LoadBitmap, Platform, Assets, Bitmap_Player, offset PlayerPath
	invoke LoadBitmap, Platform, Assets, Bitmap_Key, offset KeyPath
	invoke LoadFont, Platform, Assets, Font_Debug, offset FontPath, offset FontFace
	
	;invoke SaveLevel, GameState, Platform, offset LevelPath
	invoke LoadLevel, GameState, Platform, offset LevelPath
	mov eax, Level
	mov eax, [eax]
	lea eax, (game_level ptr[eax]).LevelWidth
	mov ecx, 16
	mov [eax], ecx
	invoke SaveLevel, GameState, Platform, offset LevelPath
	
	ret
SokobanInit endp

SokobanUpdate proc, GameState: ptr game_state, GameInput: ptr game_input, Assets: ptr game_asset, 
	GameTransform: ptr render_transform, ScreenTransform: ptr render_transform, Level: ptr ptr game_level, 
	WindowWidth: s32, WindowHeight: s32
	
	;
	;Update Code
	;
	
	
	invoke IsDown, GameInput, Button_Up
	test eax, eax
	jz UP_NOT_DOWN
	invoke AddCameraP, GameTransform, f0_, f_05
UP_NOT_DOWN:

	invoke IsDown, GameInput, Button_Down
	test eax, eax
	jz DOWN_NOT_DOWN
	mov edx, GameState
	movss xmm0, (game_state ptr[edx]).GameTransform.CameraY
	subss xmm0, f_05
	movss (game_state ptr[edx]).GameTransform.CameraY, xmm0
DOWN_NOT_DOWN:
	
	ret
SokobanUpdate endp

SokobanRender proc, GameState: ptr game_state, WindowWidth: s32, WindowHeight: s32, 
	Assets: ptr game_asset, GameTransform: ptr render_transform, ScreenTransform: ptr render_transform, 
	Level: ptr ptr game_level
	
	local MinX: f32
	local MinY: f32
	local MaxX: f32
	local MaxY: f32
	
	invoke StartTransformByHeight, GameTransform, f8_, WindowWidth, WindowHeight
	;
	;Render Code
	;
	
	
	
	mov ecx, 8
START_Y:
	cmp ecx, 0
	jle END_Y
		mov ebx, 9
	START_X:
		cmp ebx, 0
		jle END_X
			mov eax, ebx
			cvtsi2ss xmm0, eax
			movss MinX, xmm0
			mov eax, ecx
			cvtsi2ss xmm0, eax
			movss MinY, xmm0
			mov eax, ebx
			add eax, 1
			cvtsi2ss xmm0, eax
			movss MaxX, xmm0
			mov eax, ecx
			add eax, 1
			cvtsi2ss xmm0, eax
			movss MaxY, xmm0
			invoke DrawBitmap, GameTransform, Assets, Bitmap_Box, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
		dec ebx
		jmp START_X
	END_X:
	dec ecx
	jmp START_Y
END_Y:
	invoke DrawBitmap, GameTransform, Assets, Bitmap_Key, f0_, f0_, f1_, f1_, f0_, f1_, f0_, f_5
	invoke DrawString, GameTransform, Assets, 
		offset TestStr, Font_Debug, f0_, f0_, f1_, AlignX_ToLeft, AlignY_ToBottom, f1_, f1_, f1_, f1_
	invoke DrawString, GameTransform, Assets, 
		offset TestStr, Font_Debug, f0_, f0_, f1_, AlignX_ToLeft, AlignY_ToTop, f1_, f1_, f1_, f1_
	invoke DrawString, ScreenTransform, Assets, 
		offset TestStr, Font_Debug, f100_, f0_, f100_, AlignX_ToMiddle, AlignY_ToBottom, f1_, f1_, f1_, f1_
	
	
	ret
SokobanRender endp