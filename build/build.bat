@echo off

set CompileFlags=/nologo /Zi
set LinkFlags=/nologo /debug /subsystem:windows /incremental:no
ml %CompileFlags% ..\code\win_sokoban.asm  /link %LinkFlags% kernel32.lib user32.lib gdi32.lib opengl32.lib

del /q *.obj mllink$.lnk