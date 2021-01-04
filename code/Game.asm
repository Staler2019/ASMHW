
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

;SetLevelVar proc, Level: ptr ptr game_level, Index: s32, Value: s32
;Set current level's variable at Index as Value.

;GetLevelVar proc, Level: ptr ptr game_level, Index: s32, Value: ptr s32
;Get current level's variable at Index, returns in {*Value}.

.data
WallPath char "asset/wall.bmp", 0
BlankPath char "asset/blank.bmp", 0
RoadPath char "asset/road.bmp", 0
DoorAPath char "asset/doorA.bmp", 0
DoorBPath char "asset/doorB.bmp", 0
DoorCPath char "asset/doorC.bmp", 0
DoorDPath char "asset/doorD.bmp", 0
DoorEPath char "asset/doorE.bmp", 0
DoorFPath char "asset/doorF.bmp", 0
DoorGPath char "asset/doorG.bmp", 0
DoorHPath char "asset/doorH.bmp", 0
EndPointPath char "asset/endPoint.bmp", 0
FinishPath char "asset/finish.bmp", 0
HolePath char "asset/hole.bmp", 0
FilledHolePath char "asset/boxOnHole.bmp", 0
	
.code

Level_Width		equ 0
Level_Height	equ 1
Level_PlayerX	equ 2
Level_PlayerY	equ 3
Level_KeyCount	equ 4
Level_num       equ 5
Level_End		equ 6
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


SetLevelDim proc, Level: ptr ptr game_level, LevelWidth: s32, LevelHeight: s32
	invoke SetLevelVar, Level, Level_Width, LevelWidth
	invoke SetLevelVar, Level, Level_Height, LevelHeight
	ret
SetLevelDim endp

SetPlayerP proc, Level: ptr ptr game_level, PlayerX: s32, PlayerY: s32
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
;0(Road), 1(Wall), 2(Box), 3(Key), 4(Hole), 5(FilledHole), 6(boxOnFilledHole), 7~14(DoorClose), 15~22(DoorOpen), 23(EndPoint)

GetLevelDim proc, Level: ptr ptr game_level, LevelWidth: ptr s32, LevelHeight: ptr s32
	invoke GetLevelVar, Level, Level_Width, LevelWidth
	invoke GetLevelVar, Level, Level_Height, LevelHeight
	ret
GetLevelDim endp

GetPlayerP proc, Level: ptr ptr game_level, PlayerX: ptr s32, PlayerY: ptr s32
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

SokobanRestart proc uses eax edx ebx, Level: ptr ptr game_level, GameTransform: ptr render_transform
	local PresentLevel:s32
	invoke GetLevelVar, Level, Level_num, addr PresentLevel
	cmp PresentLevel, 1
	je Level1
	cmp PresentLevel, 2
	je Level2
	jmp Level3
Level1:
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
	invoke SetLevelTile, Level, 9, 1, 23
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
	invoke SetLevelTile, Level, 5, 4, 7
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
	invoke SetCameraP, GameTransform, f2_, f0_
	jmp RE_END
Level2:
	invoke SetLevelDim, Level, 11, 10
	invoke SetPlayerP, Level, 2, 1
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
	invoke SetLevelTile, Level, 10, 0, 1
	invoke SetLevelTile, Level, 0, 1, 1
	invoke SetLevelTile, Level, 1, 1, 1
	invoke SetLevelTile, Level, 2, 1, 0
	invoke SetLevelTile, Level, 3, 1, 0
	invoke SetLevelTile, Level, 4, 1, 2
	invoke SetLevelTile, Level, 5, 1, 0
	invoke SetLevelTile, Level, 6, 1, 0
	invoke SetLevelTile, Level, 7, 1, 2
	invoke SetLevelTile, Level, 8, 1, 0
	invoke SetLevelTile, Level, 9, 1, 1
	invoke SetLevelTile, Level, 10, 1, 1
	invoke SetLevelTile, Level, 0, 2, 1
	invoke SetLevelTile, Level, 1, 2, 1
	invoke SetLevelTile, Level, 2, 2, 2
	invoke SetLevelTile, Level, 3, 2, 2
	invoke SetLevelTile, Level, 4, 2, 2
	invoke SetLevelTile, Level, 5, 2, 0
	invoke SetLevelTile, Level, 6, 2, 0
	invoke SetLevelTile, Level, 7, 2, 2
	invoke SetLevelTile, Level, 8, 2, 2
	invoke SetLevelTile, Level, 9, 2, 0
	invoke SetLevelTile, Level, 10, 2, 1
	invoke SetLevelTile, Level, 0, 3, 1
	invoke SetLevelTile, Level, 1, 3, 0
	invoke SetLevelTile, Level, 2, 3, 3
	invoke SetLevelTile, Level, 3, 3, 0
	invoke SetLevelTile, Level, 4, 3, 2
	invoke SetLevelTile, Level, 5, 3, 2
	invoke SetLevelTile, Level, 6, 3, 2
	invoke SetLevelTile, Level, 7, 3, 0
	invoke SetLevelTile, Level, 8, 3, 0
	invoke SetLevelTile, Level, 9, 3, 3
	invoke SetLevelTile, Level, 10, 3, 1
	invoke SetLevelTile, Level, 0, 4, 1
	invoke SetLevelTile, Level, 1, 4, 4
	invoke SetLevelTile, Level, 2, 4, 0
	invoke SetLevelTile, Level, 3, 4, 1
	invoke SetLevelTile, Level, 4, 4, 2
	invoke SetLevelTile, Level, 5, 4, 0
	invoke SetLevelTile, Level, 6, 4, 0
	invoke SetLevelTile, Level, 7, 4, 1
	invoke SetLevelTile, Level, 8, 4, 0
	invoke SetLevelTile, Level, 9, 4, 1
	invoke SetLevelTile, Level, 10, 4, 1
	invoke SetLevelTile, Level, 0, 5, 1
	invoke SetLevelTile, Level, 1, 5, 0
	invoke SetLevelTile, Level, 2, 5, 4
	invoke SetLevelTile, Level, 3, 5, 0
	invoke SetLevelTile, Level, 4, 5, 0
	invoke SetLevelTile, Level, 5, 5, 1
	invoke SetLevelTile, Level, 6, 5, 12
	invoke SetLevelTile, Level, 7, 5, 0
	invoke SetLevelTile, Level, 8, 5, 1
	invoke SetLevelTile, Level, 9, 5, 4
	invoke SetLevelTile, Level, 10, 5, 23
	invoke SetLevelTile, Level, 0, 6, 1
	invoke SetLevelTile, Level, 1, 6, 0
	invoke SetLevelTile, Level, 2, 6, 0
	invoke SetLevelTile, Level, 3, 6, 2
	invoke SetLevelTile, Level, 4, 6, 1
	invoke SetLevelTile, Level, 5, 6, 0
	invoke SetLevelTile, Level, 6, 6, 0
	invoke SetLevelTile, Level, 7, 6, 0
	invoke SetLevelTile, Level, 8, 6, 1
	invoke SetLevelTile, Level, 9, 6, 2
	invoke SetLevelTile, Level, 10, 6, 1
	invoke SetLevelTile, Level, 0, 7, 1
	invoke SetLevelTile, Level, 1, 7, 0
	invoke SetLevelTile, Level, 2, 7, 2
	invoke SetLevelTile, Level, 3, 7, 0
	invoke SetLevelTile, Level, 4, 7, 4
	invoke SetLevelTile, Level, 5, 7, 0
	invoke SetLevelTile, Level, 6, 7, 2
	invoke SetLevelTile, Level, 7, 7, 0
	invoke SetLevelTile, Level, 8, 7, 1
	invoke SetLevelTile, Level, 9, 7, 8
	invoke SetLevelTile, Level, 10, 7, 1
	invoke SetLevelTile, Level, 0, 8, 1
	invoke SetLevelTile, Level, 1, 8, 4
	invoke SetLevelTile, Level, 2, 8, 0
	invoke SetLevelTile, Level, 3, 8, 0
	invoke SetLevelTile, Level, 4, 8, 1
	invoke SetLevelTile, Level, 5, 8, 0
	invoke SetLevelTile, Level, 6, 8, 0
	invoke SetLevelTile, Level, 7, 8, 0
	invoke SetLevelTile, Level, 8, 8, 4
	invoke SetLevelTile, Level, 9, 8, 0
	invoke SetLevelTile, Level, 10, 8, 1
	invoke SetLevelTile, Level, 0, 9, 1
	invoke SetLevelTile, Level, 1, 9, 1
	invoke SetLevelTile, Level, 2, 9, 1
	invoke SetLevelTile, Level, 3, 9, 1
	invoke SetLevelTile, Level, 4, 9, 1
	invoke SetLevelTile, Level, 5, 9, 1
	invoke SetLevelTile, Level, 6, 9, 1
	invoke SetLevelTile, Level, 7, 9, 1
	invoke SetLevelTile, Level, 8, 9, 1
	invoke SetLevelTile, Level, 9, 9, 1
	invoke SetLevelTile, Level, 10, 9, 1
	invoke SetCameraP, GameTransform, f3_, f2_
	jmp RE_END
Level3:
	invoke SetLevelDim, Level, 17, 14
	invoke SetPlayerP, Level, 8, 7
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
	invoke SetLevelTile, Level, 10, 0, 1
	invoke SetLevelTile, Level, 11, 0, 1
	invoke SetLevelTile, Level, 12, 0, 1
	invoke SetLevelTile, Level, 13, 0, 1
	invoke SetLevelTile, Level, 14, 0, 1
	invoke SetLevelTile, Level, 15, 0, 1
	invoke SetLevelTile, Level, 16, 0, 1
	invoke SetLevelTile, Level, 0, 1, 1
	invoke SetLevelTile, Level, 1, 1, 4
	invoke SetLevelTile, Level, 2, 1, 2
	invoke SetLevelTile, Level, 3, 1, 0
	invoke SetLevelTile, Level, 4, 1, 2
	invoke SetLevelTile, Level, 5, 1, 4
	invoke SetLevelTile, Level, 6, 1, 1
	invoke SetLevelTile, Level, 7, 1, 2
	invoke SetLevelTile, Level, 8, 1, 0
	invoke SetLevelTile, Level, 9, 1, 2
	invoke SetLevelTile, Level, 10, 1, 1
	invoke SetLevelTile, Level, 11, 1, 0
	invoke SetLevelTile, Level, 12, 1, 0
	invoke SetLevelTile, Level, 13, 1, 0
	invoke SetLevelTile, Level, 14, 1, 0
	invoke SetLevelTile, Level, 15, 1, 3
	invoke SetLevelTile, Level, 16, 1, 1
	invoke SetLevelTile, Level, 0, 2, 1
	invoke SetLevelTile, Level, 1, 2, 2
	invoke SetLevelTile, Level, 2, 2, 0
	invoke SetLevelTile, Level, 3, 2, 2
	invoke SetLevelTile, Level, 4, 2, 0
	invoke SetLevelTile, Level, 5, 2, 9
	invoke SetLevelTile, Level, 6, 2, 4
	invoke SetLevelTile, Level, 7, 2, 0
	invoke SetLevelTile, Level, 8, 2, 0
	invoke SetLevelTile, Level, 9, 2, 0
	invoke SetLevelTile, Level, 10, 2, 4
	invoke SetLevelTile, Level, 11, 2, 4
	invoke SetLevelTile, Level, 12, 2, 0
	invoke SetLevelTile, Level, 13, 2, 0
	invoke SetLevelTile, Level, 14, 2, 2
	invoke SetLevelTile, Level, 15, 2, 0
	invoke SetLevelTile, Level, 16, 2, 1
	invoke SetLevelTile, Level, 0, 3, 1
	invoke SetLevelTile, Level, 1, 3, 0
	invoke SetLevelTile, Level, 2, 3, 2
	invoke SetLevelTile, Level, 3, 3, 4
	invoke SetLevelTile, Level, 4, 3, 2
	invoke SetLevelTile, Level, 5, 3, 1
	invoke SetLevelTile, Level, 6, 3, 0
	invoke SetLevelTile, Level, 7, 3, 0
	invoke SetLevelTile, Level, 8, 3, 2
	invoke SetLevelTile, Level, 9, 3, 0
	invoke SetLevelTile, Level, 10, 3, 1
	invoke SetLevelTile, Level, 11, 3, 1
	invoke SetLevelTile, Level, 12, 3, 1
	invoke SetLevelTile, Level, 13, 3, 2
	invoke SetLevelTile, Level, 14, 3, 0
	invoke SetLevelTile, Level, 15, 3, 2
	invoke SetLevelTile, Level, 16, 3, 1
	invoke SetLevelTile, Level, 0, 4, 1
	invoke SetLevelTile, Level, 1, 4, 2
	invoke SetLevelTile, Level, 2, 4, 0
	invoke SetLevelTile, Level, 3, 4, 2
	invoke SetLevelTile, Level, 4, 4, 4
	invoke SetLevelTile, Level, 5, 4, 2
	invoke SetLevelTile, Level, 6, 4, 0
	invoke SetLevelTile, Level, 7, 4, 0
	invoke SetLevelTile, Level, 8, 4, 0
	invoke SetLevelTile, Level, 9, 4, 0
	invoke SetLevelTile, Level, 10, 4, 2
	invoke SetLevelTile, Level, 11, 4, 0
	invoke SetLevelTile, Level, 12, 4, 2
	invoke SetLevelTile, Level, 13, 4, 0
	invoke SetLevelTile, Level, 14, 4, 0
	invoke SetLevelTile, Level, 15, 4, 2
	invoke SetLevelTile, Level, 16, 4, 1
	invoke SetLevelTile, Level, 0, 5, 1
	invoke SetLevelTile, Level, 1, 5, 0
	invoke SetLevelTile, Level, 2, 5, 2
	invoke SetLevelTile, Level, 3, 5, 1
	invoke SetLevelTile, Level, 4, 5, 0
	invoke SetLevelTile, Level, 5, 5, 2
	invoke SetLevelTile, Level, 6, 5, 0
	invoke SetLevelTile, Level, 7, 5, 0
	invoke SetLevelTile, Level, 8, 5, 2
	invoke SetLevelTile, Level, 9, 5, 0
	invoke SetLevelTile, Level, 10, 5, 1
	invoke SetLevelTile, Level, 11, 5, 8
	invoke SetLevelTile, Level, 12, 5, 2
	invoke SetLevelTile, Level, 13, 5, 0
	invoke SetLevelTile, Level, 14, 5, 2
	invoke SetLevelTile, Level, 15, 5, 0
	invoke SetLevelTile, Level, 16, 5, 1
	invoke SetLevelTile, Level, 0, 6, 1
	invoke SetLevelTile, Level, 1, 6, 12
	invoke SetLevelTile, Level, 2, 6, 4
	invoke SetLevelTile, Level, 3, 6, 1
	invoke SetLevelTile, Level, 4, 6, 2
	invoke SetLevelTile, Level, 5, 6, 2
	invoke SetLevelTile, Level, 6, 6, 1
	invoke SetLevelTile, Level, 7, 6, 1
	invoke SetLevelTile, Level, 8, 6, 2
	invoke SetLevelTile, Level, 9, 6, 1
	invoke SetLevelTile, Level, 10, 6, 0
	invoke SetLevelTile, Level, 11, 6, 2
	invoke SetLevelTile, Level, 12, 6, 0
	invoke SetLevelTile, Level, 13, 6, 0
	invoke SetLevelTile, Level, 14, 6, 2
	invoke SetLevelTile, Level, 15, 6, 0
	invoke SetLevelTile, Level, 16, 6, 1
	invoke SetLevelTile, Level, 0, 7, 23
	invoke SetLevelTile, Level, 1, 7, 2
	invoke SetLevelTile, Level, 2, 7, 0
	invoke SetLevelTile, Level, 3, 7, 0
	invoke SetLevelTile, Level, 4, 7, 1
	invoke SetLevelTile, Level, 5, 7, 0
	invoke SetLevelTile, Level, 6, 7, 0
	invoke SetLevelTile, Level, 7, 7, 2
	invoke SetLevelTile, Level, 8, 7, 0
	invoke SetLevelTile, Level, 9, 7, 2
	invoke SetLevelTile, Level, 10, 7, 0
	invoke SetLevelTile, Level, 11, 7, 0
	invoke SetLevelTile, Level, 12, 7, 0
	invoke SetLevelTile, Level, 13, 7, 2
	invoke SetLevelTile, Level, 14, 7, 1
	invoke SetLevelTile, Level, 15, 7, 0
	invoke SetLevelTile, Level, 16, 7, 1
	invoke SetLevelTile, Level, 0, 8, 1
	invoke SetLevelTile, Level, 1, 8, 0
	invoke SetLevelTile, Level, 2, 8, 2
	invoke SetLevelTile, Level, 3, 8, 0
	invoke SetLevelTile, Level, 4, 8, 2
	invoke SetLevelTile, Level, 5, 8, 0
	invoke SetLevelTile, Level, 6, 8, 2
	invoke SetLevelTile, Level, 7, 8, 1
	invoke SetLevelTile, Level, 8, 8, 2
	invoke SetLevelTile, Level, 9, 8, 1
	invoke SetLevelTile, Level, 10, 8, 0
	invoke SetLevelTile, Level, 11, 8, 2
	invoke SetLevelTile, Level, 12, 8, 0
	invoke SetLevelTile, Level, 13, 8, 0
	invoke SetLevelTile, Level, 14, 8, 2
	invoke SetLevelTile, Level, 15, 8, 0
	invoke SetLevelTile, Level, 16, 8, 1
	invoke SetLevelTile, Level, 0, 9, 1
	invoke SetLevelTile, Level, 1, 9, 2
	invoke SetLevelTile, Level, 2, 9, 0
	invoke SetLevelTile, Level, 3, 9, 2
	invoke SetLevelTile, Level, 4, 9, 0
	invoke SetLevelTile, Level, 5, 9, 2
	invoke SetLevelTile, Level, 6, 9, 0
	invoke SetLevelTile, Level, 7, 9, 0
	invoke SetLevelTile, Level, 8, 9, 2
	invoke SetLevelTile, Level, 9, 9, 4
	invoke SetLevelTile, Level, 10, 9, 1
	invoke SetLevelTile, Level, 11, 9, 2
	invoke SetLevelTile, Level, 12, 9, 2
	invoke SetLevelTile, Level, 13, 9, 2
	invoke SetLevelTile, Level, 14, 9, 1
	invoke SetLevelTile, Level, 15, 9, 0
	invoke SetLevelTile, Level, 16, 9, 1
	invoke SetLevelTile, Level, 0, 10, 1
	invoke SetLevelTile, Level, 1, 10, 0
	invoke SetLevelTile, Level, 2, 10, 2
	invoke SetLevelTile, Level, 3, 10, 0
	invoke SetLevelTile, Level, 4, 10, 2
	invoke SetLevelTile, Level, 5, 10, 0
	invoke SetLevelTile, Level, 6, 10, 2
	invoke SetLevelTile, Level, 7, 10, 0
	invoke SetLevelTile, Level, 8, 10, 1
	invoke SetLevelTile, Level, 9, 10, 0
	invoke SetLevelTile, Level, 10, 10, 0
	invoke SetLevelTile, Level, 11, 10, 0
	invoke SetLevelTile, Level, 12, 10, 0
	invoke SetLevelTile, Level, 13, 10, 0
	invoke SetLevelTile, Level, 14, 10, 0
	invoke SetLevelTile, Level, 15, 10, 0
	invoke SetLevelTile, Level, 16, 10, 1
	invoke SetLevelTile, Level, 0, 11, 1
	invoke SetLevelTile, Level, 1, 11, 2
	invoke SetLevelTile, Level, 2, 11, 0
	invoke SetLevelTile, Level, 3, 11, 2
	invoke SetLevelTile, Level, 4, 11, 3
	invoke SetLevelTile, Level, 5, 11, 2
	invoke SetLevelTile, Level, 6, 11, 0
	invoke SetLevelTile, Level, 7, 11, 2
	invoke SetLevelTile, Level, 8, 11, 1
	invoke SetLevelTile, Level, 9, 11, 4
	invoke SetLevelTile, Level, 10, 11, 2
	invoke SetLevelTile, Level, 11, 11, 2
	invoke SetLevelTile, Level, 12, 11, 2
	invoke SetLevelTile, Level, 13, 11, 2
	invoke SetLevelTile, Level, 14, 11, 2
	invoke SetLevelTile, Level, 15, 11, 2
	invoke SetLevelTile, Level, 16, 11, 1
	invoke SetLevelTile, Level, 0, 12, 1
	invoke SetLevelTile, Level, 1, 12, 0
	invoke SetLevelTile, Level, 2, 12, 2
	invoke SetLevelTile, Level, 3, 12, 0
	invoke SetLevelTile, Level, 4, 12, 2
	invoke SetLevelTile, Level, 5, 12, 0
	invoke SetLevelTile, Level, 6, 12, 2
	invoke SetLevelTile, Level, 7, 12, 0
	invoke SetLevelTile, Level, 8, 12, 1
	invoke SetLevelTile, Level, 9, 12, 0
	invoke SetLevelTile, Level, 10, 12, 0
	invoke SetLevelTile, Level, 11, 12, 0
	invoke SetLevelTile, Level, 12, 12, 0
	invoke SetLevelTile, Level, 13, 12, 0
	invoke SetLevelTile, Level, 14, 12, 0
	invoke SetLevelTile, Level, 15, 12, 3
	invoke SetLevelTile, Level, 16, 12, 1
	invoke SetLevelTile, Level, 0, 13, 1
	invoke SetLevelTile, Level, 1, 13, 1
	invoke SetLevelTile, Level, 2, 13, 1
	invoke SetLevelTile, Level, 3, 13, 1
	invoke SetLevelTile, Level, 4, 13, 1
	invoke SetLevelTile, Level, 5, 13, 1
	invoke SetLevelTile, Level, 6, 13, 1
	invoke SetLevelTile, Level, 7, 13, 1
	invoke SetLevelTile, Level, 8, 13, 1
	invoke SetLevelTile, Level, 9, 13, 1
	invoke SetLevelTile, Level, 10, 13, 1
	invoke SetLevelTile, Level, 11, 13, 1
	invoke SetLevelTile, Level, 12, 13, 1
	invoke SetLevelTile, Level, 13, 13, 1
	invoke SetLevelTile, Level, 14, 13, 1
	invoke SetLevelTile, Level, 15, 13, 1
	invoke SetLevelTile, Level, 16, 13, 1
	invoke SetCameraP, GameTransform, f5_, f4_

RE_END:
	

	ret
SokobanRestart endp

SokobanInit proc, GameState: ptr game_state, Platform: ptr platform_state, 
	Assets: ptr game_asset, GameTransform: ptr render_transform, ScreenTransform: ptr render_transform, 
	Level: ptr ptr game_level
	
	;
	;Init Code
	;
	
	invoke LoadBitmap, Platform, Assets, Bitmap_Box, offset BoxPath
	invoke LoadBitmap, Platform, Assets, Bitmap_Player, offset PlayerPath
	invoke LoadBitmap, Platform, Assets, Bitmap_Key, offset KeyPath
	invoke LoadBitmap, Platform, Assets, Bitmap_Wall, offset WallPath
	invoke LoadBitmap, Platform, Assets, Bitmap_Road, offset RoadPath
	invoke LoadBitmap, Platform, Assets, Bitmap_Blank, offset BlankPath
	invoke LoadBitmap, Platform, Assets, Bitmap_DoorA, offset DoorAPath
	invoke LoadBitmap, Platform, Assets, Bitmap_DoorB, offset DoorBPath
	invoke LoadBitmap, Platform, Assets, Bitmap_DoorC, offset DoorCPath
	invoke LoadBitmap, Platform, Assets, Bitmap_DoorD, offset DoorDPath
	invoke LoadBitmap, Platform, Assets, Bitmap_DoorE, offset DoorEPath
	invoke LoadBitmap, Platform, Assets, Bitmap_DoorF, offset DoorFPath
	invoke LoadBitmap, Platform, Assets, Bitmap_DoorG, offset DoorGPath
	invoke LoadBitmap, Platform, Assets, Bitmap_DoorH, offset DoorHPath
	invoke LoadBitmap, Platform, Assets, Bitmap_EndPoint, offset EndPointPath 
	invoke LoadBitmap, Platform, Assets, Bitmap_Hole, offset HolePath
	invoke LoadBitmap, Platform, Assets, Bitmap_FilledHole, offset FilledHolePath 
	invoke LoadBitmap, Platform, Assets, Bitmap_Finish, offset FinishPath
	invoke LoadFont, Platform, Assets, Font_Debug, offset FontPath, offset FontFace
	;invoke LoadLevel, GameState, Platform, offset LevelPath
	invoke SetLevelVar, level, Level_End, 0
	invoke SetLevelVar, Level, Level_num, 1
	invoke SokobanRestart, Level, GameTransform
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
	local PresentLevel: s32
	
	;
	;Update Code
	;
	
	mov dPlayerX, 0
	mov dPlayerY, 0
	invoke IsDown, GameInput, Button_Space
	test eax, eax
	jz SPACE_NOT_DOWN
	invoke SokobanRestart, Level, GameTransform
SPACE_NOT_DOWN:

	invoke IsDown, GameInput, Button_Up
	test eax, eax
	jz UP_NOT_DOWN
	mov dPlayerX, 0
	mov dPlayerY, 1
UP_NOT_DOWN:

	invoke IsDown, GameInput, Button_Down
	test eax, eax
	jz DOWN_NOT_DOWN
	mov dPlayerX, 0
	mov dPlayerY, -1
DOWN_NOT_DOWN:

	invoke IsDown, GameInput, Button_Left
	test eax, eax
	jz LEFT_NOT_DOWN
	mov dPlayerX, -1
	mov dPlayerY, 0
LEFT_NOT_DOWN:

	invoke IsDown, GameInput, Button_Right
	test eax, eax
	jz RIGHT_NOT_DOWN
	mov dPlayerX, 1
	mov dPlayerY, 0
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
	je UD_WALL;HOLE
	cmp Tile, 5
	je UD_PASSWAY;FILLEDHOLE
	cmp Tile, 6
	je UD_BOX_ON_FILLEDHOLE
	cmp Tile,14
	jle UD_DOOR
	cmp Tile, 22
	jle UD_PASSWAY;DOORCLOSE
	cmp Tile, 23
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
	jz UD_PUSH_BOX_TO_PASSWAY
	cmp edx, 5
	je UD_PUSH_BOX_TO_FILLEDHOLE
	cmp edx, 4
	jne UD_END
	UD_PUSH_BOX_TO_HOLE:
		invoke SetLevelTile, level, ebx, ecx, 5
		invoke SetLevelTile, level, TryX, TryY, 0
		invoke SetPlayerP, Level, TryX, TryY
		jmp UD_END
	UD_PUSH_BOX_TO_PASSWAY:
		invoke SetLevelTile, level, ebx, ecx, 2
		invoke SetLevelTile, level, TryX, TryY, 0
		invoke SetPlayerP, Level, TryX, TryY
		jmp UD_END
	UD_PUSH_BOX_TO_FILLEDHOLE:
		invoke SetLevelTile, level, ebx, ecx, 6
		invoke SetLevelTile, level, TryX, TryY, 0
		invoke SetPlayerP, Level, TryX, TryY
		jmp UD_END
UD_BOX_ON_FILLEDHOLE:
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
	jz UD_PUSH_BOX_ON_FILLEDHOLE_TO_PASSWAY
	cmp edx, 8
	je UD_PUSH_BOX_ON_FILLEDHOLE_TO_FILLEDHOLE
	cmp edx, 7
	jne UD_END
	UD_PUSH_BOX_ON_FILLEDHOLE_TO_HOLE:
		invoke SetLevelTile, level, ebx, ecx, 5
		invoke SetLevelTile, level, TryX, TryY, 5
		invoke SetPlayerP, Level, TryX, TryY
		jmp UD_END
	UD_PUSH_BOX_ON_FILLEDHOLE_TO_PASSWAY:
		invoke SetLevelTile, level, ebx, ecx, 2
		invoke SetLevelTile, level, TryX, TryY, 5
		invoke SetPlayerP, Level, TryX, TryY
		jmp UD_END
	UD_PUSH_BOX_ON_FILLEDHOLE_TO_FILLEDHOLE:
		invoke SetLevelTile, level, ebx, ecx, 6
		invoke SetLevelTile, level, TryX, TryY, 5
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
	mov edx, Tile
	add edx, 8
	invoke SetLevelTile, level, TryX, TryY, edx
	invoke SetPlayerP, Level, TryX, TryY
	jmp UD_END
UD_ENDPOINT:;NEXTLEVE
	invoke GetLevelVar, Level, Level_num, addr PresentLevel
	mov edx, PresentLevel
	cmp edx, 3
	je Finish
	inc edx
	invoke SetLevelVar, Level, Level_num, edx
	invoke SokobanRestart, Level ,GameTransform
	jmp UD_END
Finish:
	invoke SetLevelVar, Level, Level_End, 1




UD_END:
	
	ret
SokobanUpdate endp

SokobanRender proc uses eax ebx ecx, GameState: ptr game_state, WindowWidth: s32, WindowHeight: s32, 
	Assets: ptr game_asset, GameTransform: ptr render_transform, ScreenTransform: ptr render_transform, 
	Level: ptr ptr game_level
	
	local MinX: f32
	local MinY: f32
	local MaxX: f32
	local MaxY: f32
	local Plx: s32
	local Ply: s32
	local Tile: s32
	local LevelH: s32
	local LevelW: s32
	
	invoke StartTransformByHeight, GameTransform, f16_, WindowWidth, WindowHeight
	;invoke DrawBitmap, GameTransform, Assets, Bitmap_NULL, f0_, f0_, f16_, f16_, f1_, f1_, f1_, f1_
	invoke GetPlayerP, Level, addr Plx, addr Ply
	;
	;Render Code
	;
	invoke GetLevelVar, Level, Level_Width, addr LevelW
	invoke GetLevelVar, Level, Level_Height, addr LevelH
	dec LevelW
	dec LevelH
	
	mov ecx, LevelH
START_Y:
		mov ebx, LevelW
	START_X:
			push ebx
			push ecx

			mov eax, ebx
			add eax, -3
			cvtsi2ss xmm0, eax
			movss MinX, xmm0

			mov eax, ecx
			add eax, -3
			cvtsi2ss xmm0, eax
			movss MinY, xmm0

			mov eax, ebx
			add eax, -2
			cvtsi2ss xmm0, eax
			movss MaxX, xmm0

			mov eax, ecx
			add eax, -2
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
			je RD_HOLE
			cmp Tile, 5
			je RD_FILLEDHOLE
			cmp Tile, 6
			je RD_BOXONFB
			cmp Tile, 7
			je RD_DOORA
			cmp Tile, 8
			je RD_DOORB
			cmp Tile, 9
			je RD_DOORC
			cmp Tile, 10
			je RD_DOORD
			cmp Tile, 11
			je RD_DOORE
			cmp Tile, 12
			je RD_DOORF
			cmp Tile, 13
			je RD_DOORG
			cmp Tile, 14
			je RD_DOORH
			cmp Tile, 15
			je RD_DOORB
			cmp Tile, 16
			je RD_DOORA
			cmp Tile, 17
			je RD_DOORD
			cmp Tile, 18
			je RD_DOORC
			cmp Tile, 19
			je RD_DOORF
			cmp Tile, 20
			je RD_DOORE
			cmp Tile, 21
			je RD_DOORH
			cmp Tile, 22
			je RD_DOORG
			cmp Tile, 23
			je RD_ENDPOINT
			jmp RD_END_Tile
			RD_PASSWAY:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_WALL:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Wall, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_BOX:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Box, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_KEY:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Key, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_DOORA:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				invoke DrawBitmap, GameTransform, Assets, Bitmap_DoorA, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_DOORB:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				invoke DrawBitmap, GameTransform, Assets, Bitmap_DoorB, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_DOORC:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				invoke DrawBitmap, GameTransform, Assets, Bitmap_DoorC, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_DOORD:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				invoke DrawBitmap, GameTransform, Assets, Bitmap_DoorD, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_DOORE:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				invoke DrawBitmap, GameTransform, Assets, Bitmap_DoorE, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_DOORF:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				invoke DrawBitmap, GameTransform, Assets, Bitmap_DoorF, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_DOORG:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				invoke DrawBitmap, GameTransform, Assets, Bitmap_DoorG, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_DOORH:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				invoke DrawBitmap, GameTransform, Assets, Bitmap_DoorH, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_ENDPOINT:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Road, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				invoke DrawBitmap, GameTransform, Assets, Bitmap_EndPoint, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_HOLE:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Hole, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_FILLEDHOLE:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_FilledHole, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
				jmp RD_END_Tile
			RD_BOXONFB:
				invoke DrawBitmap, GameTransform, Assets, Bitmap_Box, MinX, MinY, MaxX, MaxY, f1_, f1_, f1_, f1_
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
	invoke GetLevelVar, Level, Level_End, addr Tile
	mov eax, Tile
	test eax, eax
	jz RD_End
	invoke DrawBitmap, GameTransform, Assets, Bitmap_Finish, f_4_, f3_, f15_, f5_, f1_, f1_, f1_, f1_
RD_End:
	ret
SokobanRender endp