.386
.model flat, stdcall
.stack 4096
.xmm

char 	textequ <BYTE>
s8		textequ <SBYTE>
u8		textequ <BYTE>
s16		textequ <SWORD>
u16		textequ <WORD>
s32		textequ <SDWORD>
u32		textequ <DWORD>
s64		textequ <SQWORD>
u64		textequ <QWORD>
f32		textequ <REAL4>
f64		textequ <REAL8>
b32		textequ <DWORD>
voidptr	textequ <DWORD>

Kilobyte equ 1024
Megabyte equ Kilobyte*1024
Gigabyte equ Megabyte*1024

Assert macro Condition
	local OK, lbl
	mov ebx, Condition
	test ebx, ebx
	jnz OK
	mov [ebx], ebx
OK:
endm

AssertZ macro Condition
	local OK, lbl
	mov ebx, Condition
	test ebx, ebx
	jz OK
	mov ebx, 0
	mov [ebx], ebx
OK:
endm

mov_mem macro Des, Src, reg
	mov reg, Src
	mov Des, reg
endm

lea_mem macro Des, Src, reg
	lea reg, Src
	mov Des, reg
endm

loaded_file struct
	FileSize u32 ?
	Buffer voidptr ?
loaded_file ends

include float_table.inc
include windows.inc
include sokoban_opengl.inc
include sokoban_opengl.asm
include sokoban.asm
include Game.asm

.data
WindowClassName char "SokobanWindowClass", 0
WindowTitle char "Sokoban", 0
GlobalRunning b32 0
WindowWidth s32 0
WindowHeight s32 0

.code
Win32InitOpengl proc, DeviceContext: HANDLE
	local RequestedPixelFormat: PIXELFORMATDESCRIPTOR
	local BestPixelFormatIndex: s32
	local BestPixelFormat: PIXELFORMATDESCRIPTOR
	
	mov RequestedPixelFormat.nSize, sizeof RequestedPixelFormat
	mov RequestedPixelFormat.nVersion, 1
	mov RequestedPixelFormat.dwFlags, PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER
	mov RequestedPixelFormat.iPixelType, PFD_TYPE_RGBA
	mov RequestedPixelFormat.cColorBits, 32
	mov RequestedPixelFormat.cAlphaBits, 8
	mov RequestedPixelFormat.cAccumBits, 0
	mov RequestedPixelFormat.cDepthBits, 0
	mov RequestedPixelFormat.cStencilBits, 0
	mov RequestedPixelFormat.cAuxBuffers, 0
	mov RequestedPixelFormat.iLayerType, PFD_MAIN_PLANE
	invoke ChoosePixelFormat, DeviceContext, addr RequestedPixelFormat
	mov BestPixelFormatIndex, eax
	invoke DescribePixelFormat, DeviceContext, BestPixelFormatIndex, sizeof BestPixelFormat, addr BestPixelFormat
	invoke SetPixelFormat, DeviceContext, BestPixelFormatIndex, addr BestPixelFormat
	invoke wglCreateContext, DeviceContext
	invoke wglMakeCurrent, DeviceContext, eax
	ret
Win32InitOpengl endp

;Being a bad person
Win32FreeVirtualMemory proc, Memory: voidptr
	invoke VirtualFree, Memory, 0, MEM_RELEASE
	ret
Win32FreeVirtualMemory endp

Win32LoadFile proc, Path: ptr char, Result: ptr loaded_file
	local FileHandle: HANDLE
	local FileSize32: u32
	local FileSizeHigh: u32
	local Memory: voidptr
	local ByteRead: u32
	invoke CreateFileA, Path, GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0
	cmp eax, INVALID_HANDLE_VALUE
	je CREATE_FILE_FAILED
	mov FileHandle, eax
	invoke GetFileSize, FileHandle, addr FileSizeHigh
	AssertZ(FileSizeHigh)
	test eax, eax
	jz MEMORY_ALLOC_FAILED
	;File size is considered u32.
	mov FileSize32, eax
	invoke VirtualAlloc, 0, FileSize32, MEM_COMMIT, PAGE_READWRITE
	test eax, eax
	jz MEMORY_ALLOC_FAILED
	mov Memory, eax
	invoke ReadFile, FileHandle, Memory, FileSize32, addr ByteRead, 0
	test eax, eax
	jz READ_FILE_FAILED
	mov eax, Result
	mov_mem (loaded_file ptr[eax]).FileSize, FileSize32, ebx
	mov_mem (loaded_file ptr[eax]).Buffer, Memory, ebx
	invoke CloseHandle, FileHandle
	ret
	
READ_FILE_FAILED:
	invoke VirtualFree, Memory, 0, MEM_RELEASE
MEMORY_ALLOC_FAILED:
	invoke CloseHandle, FileHandle
	ret
CREATE_FILE_FAILED:
	ret
Win32LoadFile endp

Win32WriteFile proc, Path: ptr char, BufferSize: u32, Buffer: voidptr
	local FileHandle: HANDLE
	local ByteWritten: u32
	invoke CreateFileA, Path, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, 0, 0
	cmp eax, INVALID_HANDLE_VALUE
	je CREATE_FILE_FAILED
	mov FileHandle, eax
	invoke WriteFile, FileHandle, Buffer, BufferSize, addr ByteWritten, 0
	test eax, eax
	jz WRITE_FILE_FAILED
	
WRITE_FILE_FAILED:
	invoke CloseHandle, FileHandle
CREATE_FILE_FAILED:
	ret
Win32WriteFile endp

Win32LoadFont proc, DeviceContext: HANDLE, Path: ptr char, FaceName: ptr char, Result: ptr loaded_font
	local GlyphDeviceContext: HANDLE
	local GlyphBitmapHandle: HANDLE
	local GlyphBitmapInfo: BITMAPINFO
	local BitmapWidth: s32
	local BitmapHeight: s32
	local DesBuffer: voidptr
	local SrcBuffer: voidptr
	local FontHandle: HANDLE
	local Codepoint: u32
	local CodepointDim: SIZE_
	local TextMetrics: TEXTMETRICA
	
	mov BitmapWidth, 1024
	mov BitmapHeight, 1024
	invoke CreateCompatibleDC, DeviceContext
	mov GlyphDeviceContext, eax
	mov GlyphBitmapInfo.bmiHeader.biSize, sizeof BITMAPINFOHEADER
	mov_mem GlyphBitmapInfo.bmiHeader.biWidth, BitmapWidth, ebx
	mov_mem GlyphBitmapInfo.bmiHeader.biHeight, BitmapHeight, ebx
	mov GlyphBitmapInfo.bmiHeader.biPlanes, 1
	mov GlyphBitmapInfo.bmiHeader.biBitCount, 32
	mov GlyphBitmapInfo.bmiHeader.biCompression, BI_RGB
	mov GlyphBitmapInfo.bmiHeader.biSizeImage, 0
	mov GlyphBitmapInfo.bmiHeader.biXPelsPerMeter, 0
	mov GlyphBitmapInfo.bmiHeader.biYPelsPerMeter, 0
	mov GlyphBitmapInfo.bmiHeader.biClrUsed, 0
	mov GlyphBitmapInfo.bmiHeader.biClrImportant, 0
	invoke CreateDIBSection, GlyphDeviceContext, addr GlyphBitmapInfo, DIB_RGB_COLORS, addr SrcBuffer, 0, 0
	mov GlyphBitmapHandle, eax
	invoke SelectObject, GlyphDeviceContext, GlyphBitmapHandle
	invoke DeleteObject, eax
	
	invoke AddFontResourceExA, Path, FR_PRIVATE, 0
	;invoke GetDeviceCaps, GlyphDeviceContext, LOGPIXELSY
	;invoke MulDiv, 64, eax, 72
	;neg eax
	invoke CreateFontA, 64, 0, 0, 0, FW_DONTCARE, 
		0, 0, 0, ANSI_CHARSET, 
		OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, DEFAULT_PITCH or FF_DONTCARE, FaceName
	mov FontHandle, eax
	invoke SelectObject, GlyphDeviceContext, FontHandle
	invoke GetTextMetricsA, GlyphDeviceContext, addr TextMetrics
	mov eax, Result
	mov_mem (loaded_font ptr[eax]).Ascent, TextMetrics.tmAscent, ebx
	mov_mem (loaded_font ptr[eax]).Descent, TextMetrics.tmDescent, ebx
	mov Codepoint, 255
START_GLYPH:
	cmp Codepoint, 0
	jle END_GLYPH
	invoke GetTextExtentPointA, GlyphDeviceContext, addr Codepoint, 1, addr CodepointDim
	invoke SetTextColor, GlyphDeviceContext, 00ffffffh
	invoke SetBkColor, GlyphDeviceContext, 00000000h
	invoke TextOutA, GlyphDeviceContext, 0, 0, addr Codepoint, 1
	
	mov eax, sizeof u32
	imul eax, CodepointDim.cx_
	imul eax, CodepointDim.cy_
	invoke VirtualAlloc, 0, eax, MEM_COMMIT, PAGE_READWRITE
	mov DesBuffer, eax
	;Pitch
	mov edx, sizeof u32
	imul edx, BitmapWidth
	;SrcBitmap = SrcBitmap + (BitmapHeight - CodepointHeight) * Pitch
	mov esi, BitmapHeight
	sub esi, CodepointDim.cy_
	imul esi, edx
	add esi, SrcBuffer
	;DesBitmap
	mov edi, DesBuffer
	mov ecx, CodepointDim.cy_
	START_GLYPH_Y:
		cmp ecx, 0
		jle END_GLYPH_Y
		push esi
		push ecx
		mov ecx, CodepointDim.cx_
		START_GLYPH_X:
			cmp ecx, 0
			jle END_GLYPH_X
			
			mov eax, u32 ptr[esi]
			shl eax, 24
			or eax, 00ffffffh
			mov u32 ptr[edi], eax
			
			add edi, sizeof u32
			add esi, sizeof u32
			dec ecx
			jmp START_GLYPH_X
		END_GLYPH_X:
		pop ecx
		pop esi
		add esi, edx
		dec ecx
		jmp START_GLYPH_Y
	END_GLYPH_Y:
	
	mov eax, Result
	lea eax, [(loaded_font ptr[eax]).Glyphs]
	mov ebx, Codepoint
	imul ebx, (sizeof loaded_bitmap)
	add eax, ebx
	mov_mem (loaded_bitmap ptr[eax]).BitmapWidth, CodepointDim.cx_, ebx
	mov_mem (loaded_bitmap ptr[eax]).BitmapHeight, CodepointDim.cy_, ebx
	mov_mem (loaded_bitmap ptr[eax]).Buffer, DesBuffer, ebx
	mov ecx, Codepoint
	dec ecx
	mov Codepoint, ecx
	jmp START_GLYPH
END_GLYPH:
	invoke DeleteObject, GlyphBitmapHandle
	invoke DeleteObject, FontHandle
	invoke DeleteDC, DeviceContext
	invoke RemoveFontResourceExA, offset FontPath, FR_PRIVATE, 0
	ret
Win32LoadFont endp

Win32RotateInput proc, Input: ptr game_input
	mov edi, Input
	lea esi, (game_input ptr[edi]).LastButtons
	lea edi, (game_input ptr[edi]).Buttons
	mov ecx, Button_Count
	START_ROTATE:
	cmp ecx, 0
	jle END_ROTATE
		mov_mem [edi], [esi], eax
		mov b32 ptr[esi], 0
		add edi, sizeof b32
		add esi, sizeof b32
	dec ecx
	jmp START_ROTATE
	END_ROTATE:
	ret
Win32RotateInput endp

Win32ProcessInputMessage proc, Message: ptr MSG, Input: ptr game_input
	mov ebx, Message
	mov ebx, (MSG ptr[ebx]).message
	cmp ebx, WM_KEYDOWN
	jz MESSAGE_KEYDOWN
	cmp ebx, WM_KEYUP
	jz MESSAGE_KEYUP
	cmp ebx, WM_SYSKEYDOWN
	jz MESSAGE_SYSKEYDOWN
	cmp ebx, WM_SYSKEYUP
	jz MESSAGE_SYSKEYUP
	ret
MESSAGE_KEYDOWN:
MESSAGE_SYSKEYDOWN:
MESSAGE_KEYUP:
MESSAGE_SYSKEYUP:
	mov eax, Message
	mov edx, Message
	mov ecx, (MSG ptr[eax]).lParam
	not ecx
	shr ecx, 31
	mov edx, (MSG ptr[eax]).lParam
	and edx, 04000000h
	shr edx, 30
	mov eax, (MSG ptr[eax]).wParam
	cmp ecx, edx
	je RETURN
	mov edi, Input
	lea edi, (game_input ptr[edi]).Buttons
		cmp eax, VK_UP
		jz KEY_UP
		cmp eax, VK_DOWN
		jz KEY_DOWN
		cmp eax, VK_LEFT
		jz KEY_LEFT
		cmp eax, VK_RIGHT
		jz KEY_RIGHT
		cmp eax, VK_SPACE
		jz KEY_SPACE
		cmp eax, VK_ESCAPE
		jz KEY_ESCAPE
		cmp eax, VK_OEM_3
		jz KEY_OEM3
		ret
	KEY_UP:
		mov [edi + (sizeof b32)*Button_Up], ecx
		ret
	KEY_DOWN:
		mov [edi + (sizeof b32)*Button_Down], ecx
		ret
	KEY_LEFT:
		mov [edi + (sizeof b32)*Button_Left], ecx
		ret
	KEY_RIGHT:
		mov [edi + (sizeof b32)*Button_Right], ecx
		ret
	KEY_SPACE:
		mov [edi + (sizeof b32)*Button_Space], ecx
		ret
	KEY_ESCAPE:
		mov [edi + (sizeof b32)*Button_Escape], ecx
		ret
	KEY_OEM3:
		mov [edi + (sizeof b32)*Button_DevMode], ecx
		ret
RETURN:
	ret
Win32ProcessInputMessage endp

WindowProc proc, Window: HANDLE, Message: u32, WParam: u32, LParam: u32
	local ClientRect: RECT
	
	mov ebx, Message
	cmp ebx, WM_QUIT
	jz MESSAGE_QUIT
	cmp ebx, WM_DESTROY
	jz MESSAGE_DESTROY
	cmp ebx, WM_SIZE
	jz MESSAGE_SIZE
	invoke DefWindowProcA, Window, Message, WParam, LParam
	ret
MESSAGE_QUIT:
MESSAGE_DESTROY:
	mov GlobalRunning, 0
	ret
MESSAGE_SIZE:
	invoke GetClientRect, Window, addr ClientRect
	mov eax, ClientRect.right
	sub eax, ClientRect.left
	mov WindowWidth, eax
	mov eax, ClientRect.bottom
	sub eax, ClientRect.top
	mov WindowHeight, eax
	ret
WindowProc endp

WinMain proc 
	local WindowClass: WNDCLASSA
	local MainWindow: HANDLE
	local Message: MSG
	local DeviceContext: HANDLE
	local Platform: platform_state
	local PerfCounterFreq: LARGE_INTEGER
	local FrameStart: LARGE_INTEGER
	local FrameEnd: LARGE_INTEGER
	local GameInput: game_input
	local GameState: game_state
	local CursorPos: POINT
	
	lea edi, GameState
	mov ecx, sizeof game_state
START_CLEAR_GAME_STATE:
	cmp ecx, 0
	jle END_CLEAR_GAME_STATE
		mov u8 ptr[edi], 0
		inc edi
		dec ecx
	jmp START_CLEAR_GAME_STATE
END_CLEAR_GAME_STATE:
	
	mov WindowClass.style, CS_OWNDC or CS_HREDRAW or CS_VREDRAW
	mov WindowClass.lpfnWndProc, WindowProc
	mov WindowClass.cbClsExtra, 0
	mov WindowClass.cbWndExtra, 0
	invoke GetModuleHandleA, 0
	mov WindowClass.hInstance, eax
	mov WindowClass.hIcon, 0
	mov WindowClass.hCursor, 0
	mov WindowClass.hbrBackground, 0
	mov WindowClass.lpszMenuName, 0
	mov WindowClass.lpszClassName, offset WindowClassName
	
	invoke RegisterClassA, addr WindowClass
	test eax, eax
	jz EXIT_PROGRAM
	
	invoke CreateWindowExA, 0, offset WindowClassName, offset WindowTitle, WS_OVERLAPPEDWINDOW or WS_VISIBLE, 
							CW_USEDEFAULT, CW_USEDEFAULT, 1280, 720, 
							0, 0, WindowClass.hInstance, 0
	mov MainWindow, eax
	test eax, eax
	jz EXIT_PROGRAM
	mov GlobalRunning, 1
	invoke GetDC, MainWindow
	mov DeviceContext, eax
	invoke Win32InitOpengl, DeviceContext
	invoke OpenglInit
	mov_mem Platform.RenderContext, DeviceContext, ebx
	mov Platform.FreeMemory, Win32FreeVirtualMemory
	mov Platform.LoadFile, Win32LoadFile
	mov Platform.WriteFile, Win32WriteFile
	mov Platform.LoadFont, Win32LoadFont
	
	invoke VirtualAlloc, 0, sizeof game_level, MEM_COMMIT, PAGE_READWRITE
	mov GameState.Level, eax
	
	invoke GameInit, addr GameState, addr Platform
	invoke QueryPerformanceFrequency, addr PerfCounterFreq
	GAME_LOOP:
		invoke QueryPerformanceCounter, addr FrameStart
		invoke Win32RotateInput, addr GameInput
		MESSAGE_LOOP:
			invoke PeekMessageA, addr Message, MainWindow, 0, 0, PM_REMOVE
			test eax, eax
			jz END_MESSAGE_LOOP
			invoke Win32ProcessInputMessage, addr Message, addr GameInput
			invoke TranslateMessage, addr Message
			invoke DispatchMessageA, addr Message
			jmp MESSAGE_LOOP
		END_MESSAGE_LOOP:
		invoke GetCursorPos, addr CursorPos
		invoke ScreenToClient, MainWindow, addr CursorPos
		mov eax, CursorPos.x
		mov GameInput.MouseX, eax
		mov eax, WindowHeight
		sub eax, CursorPos.y
		mov GameInput.MouseY, eax
		invoke GetKeyState, VK_LBUTTON
		and eax, 8000h
		shr eax, 15
		mov GameInput.Buttons[Mouse_Left], eax
		invoke GetKeyState, VK_MBUTTON
		and eax, 8000h
		shr eax, 15
		mov GameInput.Buttons[Mouse_Middle], eax
		invoke GetKeyState, VK_RBUTTON
		and eax, 8000h
		shr eax, 15
		mov GameInput.Buttons[Mouse_Right], eax
		
		invoke GameUpdate, addr GameState, addr GameInput, WindowWidth, WindowHeight
		invoke IsDown, addr GameInput, Button_Up
		test eax, eax
		jz NOPRESS
		mov eax, 0
	NOPRESS:
		invoke GameRender, addr GameState, WindowWidth, WindowHeight
		invoke SwapBuffers, DeviceContext
		
		invoke QueryPerformanceCounter, addr FrameEnd
		mov eax, FrameEnd.HighPart
		sub eax, FrameStart.HighPart
		mov ebx, FrameEnd.LowPart
		sub ebx, FrameStart.LowPart
		cvtsi2ss xmm0, eax
		mulss xmm0, fU32
		cvtsi2ss xmm1, ebx
		addss xmm0, xmm1
		mov eax, PerfCounterFreq.HighPart
		mov ebx, PerfCounterFreq.LowPart
		cvtsi2ss xmm1, eax
		mulss xmm1, fU32
		cvtsi2ss xmm2, ebx
		addss xmm1, xmm2
		divss xmm0, xmm1
		comiss xmm0, f1_over_30
		jae FRAME_TIME_EXCEED
		movss xmm1, f1_over_30
		subss xmm1, xmm0
		mulss xmm1, f1000_
		cvtss2si eax, xmm1
		invoke Sleep, eax
		WORK_UNTIL_FRAME_TIME:
			invoke QueryPerformanceCounter, addr FrameEnd
			mov eax, FrameEnd.HighPart
			sub eax, FrameStart.HighPart
			mov ebx, FrameEnd.LowPart
			sub ebx, FrameStart.LowPart
			cvtsi2ss xmm0, eax
			mulss xmm0, fU32
			cvtsi2ss xmm1, ebx
			addss xmm0, xmm1
			mov eax, PerfCounterFreq.HighPart
			mov ebx, PerfCounterFreq.LowPart
			cvtsi2ss xmm1, eax
			mulss xmm1, fU32
			cvtsi2ss xmm2, ebx
			addss xmm1, xmm2
			divss xmm0, xmm1
			comiss xmm0, f1_over_30
			jb WORK_UNTIL_FRAME_TIME
	FRAME_TIME_EXCEED:
		mov ecx, GlobalRunning
		test ecx, ecx
		jnz GAME_LOOP
		
EXIT_PROGRAM:
	invoke ExitProcess, 0
WinMain endp
end WinMain