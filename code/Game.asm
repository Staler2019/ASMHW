
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
WallPath char "asset/wall.bmp", 0
BlankPath char "asset/blank.bmp", 0
DoorOpenPath char "asset/dooropen.bmp", 0
DoorClosePath char "asset/doorclose.bmp", 0
EndPointPath char "asset/endpoint.bmp", 0
FinishPath char "asset/finish.bmp", 0
	
.code

Level_Width		equ 0
Level_Height	equ 1
Level_PlayerX	equ 2
Level_PlayerY	equ 3
Level_KeyCount	equ 4
;no greater than 1023

GetLevelVar proc uses esi edi ebx, Level: ptr ptr game_level, Index: s32, Value: ptr s32
	mov esi, Level
	mov esi, [esi]
	lea esi, [(game_level ptr[esi]).LevelVars]
	mov ebx, Index
	imul ebx, sizeof s32
	add esi, ebx
	mov edi, Value
	mov_mem [s32 ptr[edi]], [s32 ptr[esi]], ebx
	ret
GetLevelVar endp

SetLevelVar proc uses eax ebx, Level: ptr ptr game_level, Index: s32, Value: s32
	mov eax, Level
	mov eax, [eax]
	lea eax, [(game_level ptr[eax]).LevelVars]
	mov ebx, Index
	imul ebx, sizeof s32
	add eax, ebx
	mov_mem [s32 ptr[eax]], Value, ebx
	ret
SetLevelVar endp


SetLevelDim proc uses eax ebx, Level: ptr ptr game_level, LevelWidth: s32, LevelHeight: s32
	invoke SetLevelVar, Level, Level_Width, LevelWidth
	invoke SetLevelVar, Level, Level_Height, LevelHeight
	ret
SetLevelDim endp

SetPlayerP proc uses eax ebx, Level: ptr ptr game_level, PlayerX: s32, PlayerY: s32
	invoke SetLevelVar, Level, Level_PlayerX, PlayerX
	invoke SetLevelVar, Level, Level_PlayerY, PlayerY
	ret
SetPlayerP endp

SetLevelTile proc uses eax ebx, Level: ptr ptr game_level, X: s32, Y: s32, Value: s32
	local LevelWidth: s32
	invoke GetLevelVar, Level, Level_Width, addr LevelWidth
	mov ebx, LevelWidth
	imul ebx, Y
	add ebx, X
	mov eax, Level
	mov eax, [eax]
	lea eax, [(game_level ptr[eax]).LevelMap]
	add eax, ebx
	lea ebx, Value
	mov bl, [ebx]
	mov [eax], bl
	ret
SetLevelTile endp
;0->' ' 1-># 2->B 3->K 4->DC 5->DO 6->E

GetLevelDim proc uses esi edi ebx, Level: ptr ptr game_level, LevelWidth: ptr s32, LevelHeight: ptr s32
	invoke GetLevelVar, Level, Level_Width, LevelWidth
	invoke GetLevelVar, Level, Level_Height, LevelHeight
	ret
GetLevelDim endp

GetPlayerP proc uses esi edi ebx, Level: ptr ptr game_level, PlayerX: ptr s32, PlayerY: ptr s32
	invoke GetLevelVar, Level, Level_PlayerX, PlayerX
	invoke GetLevelVar, Level, Level_PlayerY, PlayerY
	ret
GetPlayerP endp

GetLevelTile proc uses edi eax ebx, Level: ptr ptr game_level, X: s32, Y: s32, Value: ptr s32
	local LevelWidth: s32
	invoke GetLevelVar, Level, Level_Width, addr LevelWidth
	mov ebx, LevelWidth
	imul ebx, Y
	add ebx, X
	mov eax, Level
	mov eax, [eax]
	lea eax, (game_level ptr[eax]).LevelMap
	add eax, ebx
	mov edi, Value
	movzx ebx, [u8 ptr[eax]]
	mov [s32 ptr[edi]], ebx
	ret
GetLevelTile endp

SokobanRestart proc, Level: ptr ptr game_level
	invoke SetLevelDim, Level, 10, 6
	invoke SetPlayerP, Level, 1, 1
	invoke SetLevelVar, Level, Level_KeyCount, 0
	invoke SetLevelTile, Level, 0, 0, 1
	invoke SetLevelTile, Level, 1, 0, 1
	invoke SetLevelTile, Level, 2, 0, 1
	invoke SetLevelTile, Level, 3, 0, 1
	invoke SetLevelTile, Level, 4, 0, 1
	invoke SetLevelTile, Level, 5, 0, 1
	invoke SetLevelTile, Level, 6, 0, 1
	invoke SetLevelTile, Level, 7, 0, 1
	invoke SetLevelTile, Level, 8, 0, 1
	invoke SetLevelTile, Level, 9, 0, 1
	invoke SetLevelTile, Level, 0, 1, 1
	invoke SetLevelTile, Level, 1, 1, 0
	invoke SetLevelTile, Level, 2, 1, 1
	invoke SetLevelTile, Level, 3, 1, 3
	invoke SetLevelTile, Level, 4, 1, 1
	invoke SetLevelTile, Level, 5, 1, 1
	invoke SetLevelTile, Level, 6, 1, 0
	invoke SetLevelTile, Level, 7, 1, 0
	invoke SetLevelTile, Level, 8, 1, 0
	invoke SetLevelTile, Level, 9, 1, 6
	invoke SetLevelTile, Level, 0, 2, 1
	invoke SetLevelTile, Level, 1, 2, 0
	invoke SetLevelTile, Level, 2, 2, 2
	invoke SetLevelTile, Level, 3, 2, 0
	invoke SetLevelTile, Level, 4, 2, 2
	invoke SetLevelTile, Level, 5, 2, 1
	invoke SetLevelTile, Level, 6, 2, 0
	invoke SetLevelTile, Level, 7, 2, 2
	invoke SetLevelTile, Level, 8, 2, 0
	invoke SetLevelTile, Level, 9, 2, 1
	invoke SetLevelTile, Level, 0, 3, 1
	invoke SetLevelTile, Level, 1, 3, 2
	invoke SetLevelTile, Level, 2, 3, 0
	invoke SetLevelTile, Level, 3, 3, 2
	invoke SetLevelTile, Level, 4, 3, 0
	invoke SetLevelTile, Level, 5, 3, 1
	invoke SetLevelTile, Level, 6, 3, 2
	invoke SetLevelTile, Level, 7, 3, 2
	invoke SetLevelTile, Level, 8, 3, 2
	invoke SetLevelTile, Level, 9, 3, 1
	invoke SetLevelTile, Level, 0, 4, 1
	invoke SetLevelTile, Level, 1, 4, 0
	invoke SetLevelTile, Level, 2, 4, 2
	invoke SetLevelTile, Level, 3, 4, 0
	invoke SetLevelTile, Level, 4, 4, 0
	invoke SetLevelTile, Level, 5, 4, 4
	invoke SetLevelTile, Level, 6, 4, 0
	invoke SetLevelTile, Level, 7, 4, 2
	invoke SetLevelTile, Level, 8, 4, 2
	invoke SetLevelTile, Level, 9, 4, 1
	invoke SetLevelTile, Level, 0, 5, 1
	invoke SetLevelTile, Level, 1, 5, 1
	invoke SetLevelTile, Level, 2, 5, 1
	invoke SetLevelTile, Level, 3, 5, 1
	invoke SetLevelTile, Level, 4, 5, 1
	invoke SetLevelTile, Level, 5, 5, 1
	invoke SetLevelTile, Level, 6, 5, 1
	invoke SetLevelTile, Level, 7, 5, 1
	invoke SetLevelTile, Level, 8, 5, 1
	invoke SetLevelTile, Level, 9, 5, 1
	ret
SokobanRestart endp

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
	invoke LoadBitmap, Platform, Assets, Bitmap_Wall, offset WallPath
	invoke LoadBitmap, Platform, Assets, Bitmap_NULL, offset BlankPath
	;invoke LoadBitmap, Platform, Assets, Bitmap_DoorOpen, offset DoorOpenPath
	;invoke LoadBitmap, Platform, Assets, Bitmap_DoorClose, offset DoorClosePath
	;invoke LoadBitmap, Platform, Assets, Bitmap_EndPoint, offset EndPointPath 
	;invoke LoadBitmap, Platform, Assets, Bitmap_Finish, offset FinishPath
	invoke LoadFont, Platform, Assets, Font_Debug, offset FontPath, offset FontFace
	;invoke LoadLevel, GameState, Platform, offset LevelPath
	invoke SokobanRestart, Level
	;invoke SaveLevel, GameState, Platform, offset LevelPath
	;invoke DrawBitmap, GameTransform, Assets, Bitmap_Key, f_1_, f_1_, f1_, f1_, f0_, f1_, f0_, f1_
	ret
SokobanInit endp



SokobanUpdate proc, GameState: ptr game_state, GameInput: ptr game_input, Assets: ptr game_asset, 
	GameTransform: ptr render_transform, ScreenTransform: ptr render_transform, Level: ptr ptr game_level, 
	WindowWidth: s32, WindowHeight: s32
	local PlayerX: s32
	local PlayerY: s32
	local dPlayerX: s32
	local dPlayerY: s32
	local TryX: s32
	local TryY: s32
	local Tile: s32
	local KeyCount: s32
	
	;
	;Update Code
	;
	
	mov dPlayerX, 0
	mov dPlayerY, 0
	invoke IsDown, GameInput, Button_Escape
	test eax, eax
	jz ESC_NOT_DOWN
	;invoke SokobanRestart, Level
ESC_NOT_DOWN:

	invoke IsDown, GameInput, Button_Up
	test eax, eax
	jz UP_NOT_DOWN
	add dPlayerX, 0
	add dPlayerY, 1
UP_NOT_DOWN:

	invoke IsDown, GameInput, Button_Down
	test eax, eax
	jz DOWN_NOT_DOWN
	add dPlayerX, 0
	add dPlayerY, -1
DOWN_NOT_DOWN:

	invoke IsDown, GameInput, Button_Left
	test eax, eax
	jz LEFT_NOT_DOWN
	add dPlayerX, -1
	add dPlayerY, 0
LEFT_NOT_DOWN:

	invoke IsDown, GameInput, Button_Right
	test eax, eax
	jz RIGHT_NOT_DOWN
	add dPlayerX, 1
	add dPlayerY, 0
RIGHT_NOT_DOWN: 

	invoke GetPlayerP, level, addr PlayerX, addr PlayerY
	mov ebx, PlayerX
	add ebx, dPlayerX
	mov TryX, ebx
	mov ebx, PlayerY
	add ebx, dPlayerY
	mov TryY, ebx
	invoke GetLevelTile, level, TryX, TryY, addr Tile
	cmp Tile, 0
	je UD_PASSWAY
	cmp Tile, 1
	je UD_WALL
	cmp Tile, 2
	je UD_BOX
	cmp Tile, 3
	je UD_KEY
	cmp Tile, 4
	je UD_DOOR
	cmp Tile, 5
	je UD_PASSWAY
	cmp Tile, 6
	je UD_ENDPOINT
	jmp UD_END

UD_PASSWAY:
	invoke SetPlayerP, Level, TryX, TryY
	jmp UD_END
UD_WALL:
	jmp UD_END
UD_BOX:
	mov ebx, TryX
	add ebx, dPlayerX
	mov ecx, TryY
	add ecx, dPlayerY
	push ebx
	push ecx
	invoke GetLevelTile, level, ebx, ecx, addr Tile
	pop ecx
	pop ebx
	mov edx, Tile
	test edx, edx
	jnz UD_END
	invoke SetLevelTile, level, ebx, ecx, 2
	invoke SetLevelTile, level, TryX, TryY, 0
	invoke SetPlayerP, Level, TryX, TryY
	jmp UD_END
UD_KEY:
	invoke SetLevelTile, level, TryX, TryY, 0
	invoke SetPlayerP, Level, TryX, TryY
	invoke GetLevelVar, level, Level_KeyCount, addr KeyCount
	inc KeyCount
	invoke SetLevelVar, Level, Level_KeyCount, KeyCount
	jmp UD_END
UD_DOOR:
	invoke GetLevelVar, level, Level_KeyCount, addr KeyCount
	mov edx, KeyCount
	test edx, edx
	jz UD_END
	dec KeyCount
	invoke SetLevelVar, Level, Level_KeyCount, KeyCount
	invoke SetLevelTile, level, TryX, TryY, 5
	invoke SetPlayerP, Level, TryX, TryY
	jmp UD_END
UD_ENDPOINT:
	invoke SetLevelTile, level, 0, 0, 0;NEXTLEVEL


UD_END:
	
	ret
SokobanUpdate endp

SokobanRender proc, GameState: ptr game_state, WindowWidth: s32, WindowHeight: s32, 
	Assets: ptr game_asset, GameTransform: ptr render_transform, ScreenTransform: ptr render_transform, 
	Level: ptr ptr game_level
	
	local MinX: f32
	local MinY: f32
	local MaxX: f32
	local MaxY: f32
	local Plx: s32
	local Ply: s32
	local Tile: s32
	
	invoke StartTransformByHeight, GameTransform, f8_, WindowWidth, WindowHeight
	;invoke DrawBitmap, GameTransform, Assets, Bitmap_Box, f0_, f0_, WindowWidth, WindowHeight, f0_, f0_, f0_, f1_
	invoke GetPlayerP, Level, addr Plx, addr Ply
	;
	;Render Code
	;
	
	
	
	mov ecx, 5
START_Y:
		mov ebx, 9
	START_X:
			push ebx
			push ecx

			mov eax, ebx
			cvtsi2ss xmm0, eax
			movss MinX, xmm0

			mov eax, ecx
			add eax, 1
			cvtsi2ss xmm0, eax
			movss MinY, xmm0

			mov eax, ebx
			add eax, 1
			cvtsi2ss xmm0, eax
			movss MaxX, xmm0

			mov eax, ecx
			add eax, 2
			cvtsi2ss xmm0, eax
			movss MaxY, xmm0

			invoke GetLevelTile, Level, ebx, ecx, addr Tile
			cmp Tile, 0
			je RD_PASSWAY
			cmp Tile, 1
			je RD_WALL
			cmp Tile, 2
			je RD_BOX
			cmp Tile, 3
			je RD_KEY
			cmp Tile, 4
			je RD_DOOROPEN
			cmp Tile, 5
			je RD_DOORCLOSE
			cmp Tile, 6
			je RD_ENDPOINT
			RD_PASSWAY:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_NULL, MinX, MinY, MaxX, MaxY, f1_, f0_, f1_, f_05
				jmp RD_END_Tile
			RD_WALL:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Key, MinX, MinY, MaxX, MaxY, f1_, f1_, f0_, f_5
				jmp RD_END_Tile
			RD_BOX:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Key, MinX, MinY, MaxX, MaxY, f0_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_KEY:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Key, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_DOOROPEN:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Key, MinX, MinY, MaxX, MaxY, f0_, f0_, f1_, f1_
				jmp RD_END_Tile
			RD_DOORCLOSE:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Key, MinX, MinY, MaxX, MaxY, f1_, f0_, f0_, f1_
				jmp RD_END_Tile
			RD_ENDPOINT:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Key, MinX, MinY, MaxX, MaxY, f0_, f0_, f0_, f1_
				jmp RD_END_Tile
			RD_END_Tile:
				pop ecx
				pop ebx
				cmp ebx, Plx
				jne RD_END_Player
				cmp ecx, Ply
				jne RD_END_Player
				push ebx
				push ecx
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Player, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				pop ecx
				pop ebx
			RD_END_Player:
		cmp ebx, 0
		jle END_X
		dec ebx
		jmp START_X
	END_X:
	cmp ecx, 0
	jle END_Y
	dec ecx
	jmp START_Y
END_Y:
	;invoke DrawBitmap, GameTransform, Assets, Bitmap_Key, f0_, f0_, f1_, f1_, f0_, f1_, f0_, f_5
	;invoke DrawString, GameTransform, Assets, 
		;offset TestStr, Font_Debug, f0_, f0_, f1_, AlignX_ToLeft, AlignY_ToBottom, f1_, f1_, f1_, f1_
	;invoke DrawString, GameTransform, Assets, 
		;offset TestStr, Font_Debug, f0_, f0_, f1_, AlignX_ToLeft, AlignY_ToTop, f1_, f1_, f1_, f1_
	;invoke DrawString, ScreenTransform, Assets, 
		;offset TestStr, Font_Debug, f100_, f0_, f100_, AlignX_ToMiddle, AlignY_ToBottom, f1_, f1_, f1_, f1_
	
	
	ret
SokobanRender endp