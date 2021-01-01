# Sokoban Game

This our homework of NCUCSIE in assembly class.

## Warning

The rules of this project are written in "/code/Game.asm"

Changes of data type names are defined in "/code/win_sokoban.asm"

## Outline

<!-- "/code/Game.asm"
"/code/sokoban.asm"(include sokoban_input.inc, sokoban_asset.inc, sokoban_struct.inc):

```asm
GetBitmapHandle(Assets: ptr game_asset, BitmapId: u32);
GetGlyphHandle(Assets: ptr game_asset, FontId: u32, Codepoint: u32);
GetBitmapInfo(Assets: ptr game_asset, BitmapId: u32, Result: ptr ptr loaded_bitmap);
GetFontInfo(Assets: ptr game_asset, FontId: u32, Result: ptr ptr loaded_font);
GetGlyphInfo(Assets: ptr game_asset, FontId: u32, Codepoint: u32, Result: ptr ptr loaded_bitmap);
LoadBitmap(Platform: ptr platform_state, Assets: ptr game_asset, BitmapId: u32, Path: ptr char);
LoadFont(Platform: ptr platform_state, Assets: ptr game_asset, FontId: u32, Path: ptr char, FaceName: ptr char);
IsDown(Input: ptr game_input, ButtonIndex: u32);
WasDown(Input: ptr game_input, ButtonIndex: u32);
IsPressed(Input: ptr game_input, ButtonIndex: u32);
WasPressed(Input: ptr game_input, ButtonIndex: u32);

SafeRatio1 macro A, B

DrawBitmap(Transform: ptr render_transform, Assets: ptr game_asset, BitmapId: u32, MinX: f32, MinY: f32, MaxX: f32, MaxY: f32, R: f32, G: f32, B: f32, A: f32);
DrawString(Transform: ptr render_transform, Assets: ptr game_asset, String: ptr char, FontId: u32, X: f32, Y: f32, Height: f32, AlignX: u32, AlignY: u32, R: f32, G: f32, B: f32, A: f32);
StartTransformByHeight(Transform: ptr render_transform, DisplayHeight: f32, WindowWidth: s32, WindowHeight: s32);
FreeLevel(Platform: ptr platform_state, Level: ptr game_level);
SaveLevel(GameState: ptr game_state, Platform: ptr platform_state, Path: ptr char);
LoadLevel(GameState: ptr game_state, Platform: ptr platform_state, Path: ptr char);
SetCameraP(Transform: ptr render_transform, X: f32, Y: f32);
AddCameraP(Transform: ptr render_transform, X: f32, Y: f32);
TransformMouse(Input: ptr game_input, Transform: ptr render_transform, WindowWidth: s32, WindowHeight: s32);
GameInit(GameState: ptr game_state, Platform: ptr platform_state);
GameUpdate(GameState: ptr game_state, GameInput: ptr game_input, WindowWidth: s32, WindowHeight: s32);
GameRender(GameState: ptr game_state, WindowWidth: s32, WindowHeight: s32);
``` -->

<!--others are too much..., let me suck for a while-->
### defines

- data type  :
  - "/code/win_sokoban.asm"    (textequ)
- floats     :
  - "/code/float_table.inc"    (data)
- assets     :
  - "/code/sokoban_asset.inc"  (equ)
- input code :
  - "/code/sokoban_input.inc"  (equ)
- opengl code:
  - "/code/sokoban_opengl.inc" (textequ/equ)
- struct(loaded_bitmap/loaded_font/platform_state/game_input/game_asset/render_transform/game_level/game_state):
  - "/code/sokoban_struct.inc" (equ/struct)


<!-- ### procedures

"code/sokoban_opengl.asm":

```asm
OpenglInit();
OpenglAllocateTexture(_Width: s32, _Height: s32, Buffer: ptr u32, Result: ptr u32);
OpenglQuad(MinX: f32, MinY: f32, MaxX: f32, MaxY: f32, R: f32, G: f32, B: f32, A: f32);
OpenglTexturedQuad(MinX: f32, MinY: f32, MaxX: f32, MaxY: f32, R: f32, G: f32, B: f32, A: f32, TextureHandle: u32);
``` -->
