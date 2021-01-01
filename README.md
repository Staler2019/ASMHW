# Sokoban Game(推箱子/倉庫番)

This our homework of NCUCSIE in assembly class.

## Warning

1. The rules of this project are written in "/code/Game.asm"

2. Changes of data type names are defined in "/code/win_sokoban.asm"

3. Assets of *.bmp should be implemented by an "alpha channel" in white color in PS.

## Outline

### Defines(version 2020.12.29)

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

