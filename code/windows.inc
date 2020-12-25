HANDLE		textequ <DWORD>

SW_SHOWDEFAULT	equ 10

CS_OWNDC		equ 0020h
CS_HREDRAW		equ 0002h
CS_VREDRAW		equ 0001h

PFD_TYPE_RGBA		equ 0
PFD_MAIN_PLANE		equ 0
PFD_DOUBLEBUFFER	equ 00000001h
PFD_DRAW_TO_WINDOW	equ 00000004h
PFD_SUPPORT_OPENGL	equ 00000020h

PM_REMOVE		equ 0001h

CW_USEDEFAULT	equ 80000000h

WM_QUIT			equ 0012h
WM_DESTROY		equ 0002h
WM_SIZE			equ 0005h

WS_OVERLAPPED	equ 00000000h
WS_CAPTION		equ 00c00000h
WS_SYSMENU		equ 00080000h
WS_THICKFRAME	equ 00040000h
WS_MINIMIZEBOX	equ 00020000h
WS_MAXIMIZEBOX	equ 00010000h
WS_VISIBLE		equ 10000000h
WS_OVERLAPPEDWINDOW	equ WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX

INVALID_HANDLE_VALUE	equ -1

GENERIC_READ	equ 80000000h
GENERIC_WRITE	equ 40000000h

OPEN_EXISTING	equ 3

MEM_COMMIT		equ 00001000h

MEM_RELEASE		equ 00008000h

PAGE_READWRITE	equ 04h

WNDCLASSA struct
	style 			DWORD ?
	lpfnWndProc		DWORD ?
	cbClsExtra		DWORD ?
	cbWndExtra		DWORD ?
	hInstance		DWORD ?
	hIcon			DWORD ?
	hCursor			DWORD ?
	hbrBackground	DWORD ?
	lpszMenuName	DWORD ?
	lpszClassName	DWORD ?
WNDCLASSA ends
POINT struct
	x SWORD ?
	y SWORD ?
POINT ends
RECT struct
	left	SDWORD ?
	top		SDWORD ?
	right	SDWORD ?
	bottom	SDWORD ?
RECT ends
MSG struct
	hwnd		HANDLE ?
	message		DWORD ?
	wParam		DWORD ?
	lParam		DWORD ?
	time		DWORD ?
	pt			POINT <>
	lPrivate	DWORD ?
MSG ends
PIXELFORMATDESCRIPTOR struct
	nSize			WORD ?
	nVersion		WORD ?
	dwFlags			DWORD ?
	iPixelType		BYTE ?
	cColorBits		BYTE ?
	cRedBits		BYTE ?
	cRedShift		BYTE ?
	cGreenBits		BYTE ?
	cGreenShift		BYTE ?
	cBlueBits		BYTE ?
	cBlueShift		BYTE ?
	cAlphaBits		BYTE ?
	cAlphaShift		BYTE ?
	cAccumBits		BYTE ?
	cAccumRedBits	BYTE ?
	cAccumGreenBits	BYTE ?
	cAccumBlueBits	BYTE ?
	cAccumAlphaBits	BYTE ?
	cDepthBits		BYTE ?
	cStencilBits	BYTE ?
	cAuxBuffers		BYTE ?
	iLayerType		BYTE ?
	bReserved		BYTE ?
	dwLayerMask		BYTE ?
	dwVisibleMask	BYTE ?
	dwDamageMask	BYTE ?
PIXELFORMATDESCRIPTOR ends

ChoosePixelFormat proto, hdc: HANDLE, ppfd: ptr PIXELFORMATDESCRIPTOR
CloseHandle proto, hObject: HANDLE
CreateFileA proto, lpFileName: DWORD, dwDesiredAcess: DWORD, dwShareMode: DWORD, lpSecurityAttributes: DWORD, dwCreationDisposition: DWORD, dwFlagsAndAttributes: DWORD, hTemplateFile: HANDLE
CreateWindowExA proto, dwExStyle: DWORD, lpClassName: DWORD, lpWindowName: DWORD, dwStyle: DWORD, X: SDWORD, Y: SDWORD, nWidth: SDWORD, nHeight: SDWORD, hWndParent: HANDLE, hMenu: HANDLE, hInstance: HANDLE, lpParam: DWORD
DefWindowProcA proto, hWnd: HANDLE, Msg: DWORD, WParam: DWORD, LParam: DWORD
DescribePixelFormat proto, hdc: HANDLE, iPixelFormat: SDWORD, nBytes: DWORD, ppfd: ptr PIXELFORMATDESCRIPTOR
DispatchMessageA proto, lpMsg: ptr MSG
ExitProcess proto, uExitCode: DWORD
GetClientRect proto, hWnd: HANDLE, lpRect: ptr RECT
GetDC proto, hwnd: HANDLE
GetFileSize proto, hFile: HANDLE, lpFileSizeHigh: ptr DWORD
GetModuleHandleA proto, lpModuleName: DWORD
PeekMessageA proto, lpMsg: ptr MSG, hWnd: HANDLE, wMsgFilterMin: DWORD, wMsgFilterMax: DWORD, wRemoveMsg: DWORD
ReadFile proto, hFile: HANDLE, lpBuffer: DWORD, nNumberOfBytesToRead: DWORD, lpNumberOfBytesRead: ptr DWORD, lpOverlapped: DWORD
RegisterClassA proto, lpWndClass: ptr WNDCLASSA
SetPixelFormat proto, hdc: HANDLE, format: SDWORD, ppfd: ptr PIXELFORMATDESCRIPTOR
SwapBuffers proto, Arg1: HANDLE
TranslateMessage proto, lpMsg: ptr MSG
VirtualAlloc proto, lpAddress: DWORD, dwSize: DWORD, flAllocationType: DWORD, flProtect: DWORD
VirtualFree proto, lpAddress: DWORD, dwSize: DWORD, dwFreeType: DWORD
wglCreateContext proto, Arg1: HANDLE
wglMakeCurrent proto, arg1: HANDLE, arg2: HANDLE
wglGetProcAddress proto, Arg1: DWORD
