.386
.model flat, stdcall
.stack 4096

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
b32		textequ <u32>
voidptr	textequ <DWORD>

Kilobyte equ 1024
Megabyte equ Kilobyte*1024
Gigabyte equ Megabyte*1024

Assert macro Condition
	mov ebx, Condition
	test ebx, ebx
	jnz OK
	mov [ebx], ebx
OK:
	exitm
endm

AssertZ macro Condition
	mov ebx, Condition
	test ebx, ebx
	jz OK
	mov ebx, 0
	mov [ebx], ebx
OK:
	exitm
endm

loaded_file struct
	FileSize u32 ?
	Buffer voidptr ?
loaded_file ends

.data
f0_ f32 0.0
f_5 f32 0.5
f1_ f32 1.0
GLOBALBitmap u32 4096 dup(0ff123456h)
GLOBALTextureHandle u32 0

include windows.inc
include sokoban_opengl.inc
include sokoban_opengl.asm
include sokoban.asm

.data
WindowClassName char "SokobanWindowClass", 0
WindowTitle char "Sokoban", 0
GlobalRunning b32 0
WindowWidth s32 0
WindowHeight s32 0

TestPath char "asset/box.bmp", 0

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

Wind32LoadFile proc, Path: ptr char, Result: ptr loaded_file
	local FileHandle: HANDLE
	local FileSize32: u32
	local FileSizeHigh: u32
	local Memory: voidptr
	local ByteRead: u32
	invoke CreateFileA, Path, GENERIC_READ or GENERIC_WRITE, 0, 0, OPEN_EXISTING, 0, 0
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
	invoke CloseHandle, FileHandle
	
	assume eax: ptr loaded_file
	mov eax, Result
	mov ebx, FileSize32
	mov [eax].FileSize, ebx
	mov ebx, Memory
	mov [eax].Buffer, ebx
	assume eax: nothing
	
	ret
	
MEMORY_ALLOC_FAILED:
	invoke CloseHandle, FileHandle
	ret
READ_FILE_FAILED:
	invoke VirtualFree, Memory, 0, MEM_RELEASE
	ret
CREATE_FILE_FAILED:
	ret
Wind32LoadFile endp

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
	local FileA: loaded_file
	local PersistArena: memory_arena
	
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
	
	invoke VirtualAlloc, 0, Megabyte*16, MEM_COMMIT, PAGE_READWRITE
	mov PersistArena.UsedSize, 0
	mov PersistArena.MaxSize, Megabyte*16
	mov PersistArena.Memory, eax
	
	invoke Wind32LoadFile, offset TestPath, addr FileA
	invoke OpenglAllocateTexture, 64, 64, offset GLOBALBitmap
	mov GLOBALTextureHandle, eax
	GAME_LOOP:
		MESSAGE_LOOP:
			invoke PeekMessageA, addr Message, MainWindow, 0, 0, PM_REMOVE
			test eax, eax
			jz END_MESSAGE_LOOP
			invoke TranslateMessage, addr Message
			invoke DispatchMessageA, addr Message
			jmp MESSAGE_LOOP
		END_MESSAGE_LOOP:
		
		invoke GameUpdate
		invoke GameRender, WindowWidth, WindowHeight
		
		invoke SwapBuffers, DeviceContext
		
		mov ecx, GlobalRunning
		test ecx, ecx
		jnz GAME_LOOP
		
EXIT_PROGRAM:
	invoke ExitProcess, 0
WinMain endp
end WinMain