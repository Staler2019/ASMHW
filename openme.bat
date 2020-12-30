@echo off
set CommadStr=Commands: 
set BuildStr=    build - Build the game
set GameStr=    win_sokoban - Start the game

set CurrentDir="%~dp0"
start cmd /k "cd /d %CurrentDir%/build & echo %CommadStr% & echo %BuildStr% & echo %GameStr%"