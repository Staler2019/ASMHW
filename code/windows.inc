HANDLE		textequ <DWORD>
COLORREF	textequ <DWORD>

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
WM_KEYDOWN		equ 0100h
WM_KEYUP		equ 0101h
WM_SYSKEYDOWN	equ 0104h
WM_SYSKEYUP		equ 0105h
WM_MOUSEMOVE	equ 0200h

VK_LBUTTON	equ 01h
VK_RBUTTON	equ 02h
VK_MBUTTON	equ 03h
VK_ESCAPE	equ 1bh
VK_SPACE	equ 20h
VK_LEFT		equ 25h
VK_UP		equ 26h
VK_RIGHT	equ 27h
VK_DOWN		equ 28h
VK_OEM_3	equ 0c0h

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

CREATE_ALWAYS	equ 2
OPEN_EXISTING	equ 3

MEM_COMMIT		equ 00001000h
MEM_RELEASE		equ 00008000h

PAGE_READWRITE	equ 04h

DIB_RGB_COLORS	equ 0
BI_RGB			equ 0

FW_DONTCARE			equ 0
ANSI_CHARSET		equ 0
OUT_DEFAULT_PRECIS	equ 0
CLIP_DEFAULT_PRECIS	equ 0
DEFAULT_QUALITY		equ 0
ANTIALIASED_QUALITY	equ 4
DEFAULT_PITCH		equ 0
FF_DONTCARE			equ 0
LOGPIXELSY			equ 90
FR_PRIVATE			equ 10h

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
LARGE_INTEGER union
	struct
		LowPart		DWORD ?
		HighPart	SDWORD ?
	ends
	QuadPart SQWORD ?
LARGE_INTEGER ends
POINT struct
	x SDWORD ?
	y SDWORD ?
POINT ends
RECT struct
	left	SDWORD ?
	top		SDWORD ?
	right	SDWORD ?
	bottom	SDWORD ?
RECT ends
SIZE_ struct
	cx_	SDWORD ?
	cy_	SDWORD ?
SIZE_ ends
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
BITMAPINFOHEADER struct
	biSize			DWORD ?
	biWidth			SDWORD ?
	biHeight		SDWORD ?
	biPlanes		WORD ?
	biBitCount		WORD ?
	biCompression	DWORD ?
	biSizeImage		DWORD ?
	biXPelsPerMeter	SDWORD ?
	biYPelsPerMeter	SDWORD ?
	biClrUsed		DWORD ?
	biClrImportant	DWORD ?
BITMAPINFOHEADER ends
BITMAPINFO struct
	bmiHeader BITMAPINFOHEADER <>
BITMAPINFO ends
TEXTMETRICA struct
	tmHeight			SDWORD ?
	tmAscent			SDWORD ?
	tmDescent			SDWORD ?
	tmInternalLeading	SDWORD ?
	tmExternalLeading	SDWORD ?
	tmAveCharWidth		SDWORD ?
	tmMaxCharWidth		SDWORD ?
	tmWeight			SDWORD ?
	tmOverhang			SDWORD ?
	tmDigitizedAspectX	SDWORD ?
	tmDigitizedAspectY	SDWORD ?
	tmFirstChar			BYTE ?
	tmLastChar			BYTE ?
	tmDefaultChar		BYTE ?
	tmBreakChar			BYTE ?
	tmItalic			BYTE ?
	tmUnderlined		BYTE ?
	tmStruckOut			BYTE ?
	tmPitchAndFamily	BYTE ?
	tmCharSet			BYTE ?
TEXTMETRICA ends

AddFontResourceExA proto, name_: DWORD, fl: DWORD, res: DWORD
ChoosePixelFormat proto, hdc: HANDLE, ppfd: ptr PIXELFORMATDESCRIPTOR
CloseHandle proto, hObject: HANDLE
CreateCompatibleDC proto, hdc: HANDLE
CreateDIBSection proto, hdc: HANDLE, pbmi: ptr BITMAPINFO, usage: DWORD, ppvBits: DWORD, hSection: HANDLE, offset_: DWORD
CreateFileA proto, lpFileName: DWORD, dwDesiredAcess: DWORD, dwShareMode: DWORD, lpSecurityAttributes: DWORD, dwCreationDisposition: DWORD, dwFlagsAndAttributes: DWORD, hTemplateFile: HANDLE
CreateFontA proto, cHeight: SDWORD, cWidth: SDWORD, cEscapement: SDWORD, cOrientation: SDWORD, cWeight:SDWORD, bItalic: DWORD, bUnderline: DWORD, bStrikeOut: DWORD, iCharSet: DWORD, iOutPrecision: DWORD, iClipPrecision: DWORD, iQuality: DWORD, iPitchAndFamily: DWORD, pszFaceName: DWORD
CreateWindowExA proto, dwExStyle: DWORD, lpClassName: DWORD, lpWindowName: DWORD, dwStyle: DWORD, X: SDWORD, Y: SDWORD, nWidth: SDWORD, nHeight: SDWORD, hWndParent: HANDLE, hMenu: HANDLE, hInstance: HANDLE, lpParam: DWORD
DefWindowProcA proto, hWnd: HANDLE, Msg: DWORD, WParam: DWORD, LParam: DWORD
DeleteDC proto, hdc: HANDLE
DeleteObject proto, ho: HANDLE
DescribePixelFormat proto, hdc: HANDLE, iPixelFormat: SDWORD, nBytes: DWORD, ppfd: ptr PIXELFORMATDESCRIPTOR
DispatchMessageA proto, lpMsg: ptr MSG
ExitProcess proto, uExitCode: DWORD
GetClientRect proto, hWnd: HANDLE, lpRect: ptr RECT
GetCursorPos proto, lpPoint: ptr POINT
GetDC proto, hwnd: HANDLE
GetDeviceCaps proto, hdc: HANDLE, index: SDWORD
GetFileSize proto, hFile: HANDLE, lpFileSizeHigh: ptr DWORD
GetKeyState proto, nVirtKey: SDWORD
GetModuleHandleA proto, lpModuleName: DWORD
GetTextExtentPointA proto, hdc: HANDLE, lpString: DWORD, c_: SDWORD, lpsz: ptr SIZE_
GetTextMetricsA proto, hdc: HANDLE, lptm: ptr TEXTMETRICA
MulDiv proto, nNumber: SDWORD, nNumerator: SDWORD, nDenominator: SDWORD
PeekMessageA proto, lpMsg: ptr MSG, hWnd: HANDLE, wMsgFilterMin: DWORD, wMsgFilterMax: DWORD, wRemoveMsg: DWORD
QueryPerformanceCounter proto, lpPerformanceCount: ptr LARGE_INTEGER
QueryPerformanceFrequency proto, lpFrequency: ptr LARGE_INTEGER
ReadFile proto, hFile: HANDLE, lpBuffer: DWORD, nNumberOfBytesToRead: DWORD, lpNumberOfBytesRead: ptr DWORD, lpOverlapped: DWORD
RegisterClassA proto, lpWndClass: ptr WNDCLASSA
RemoveFontResourceExA proto, name_: DWORD, fl: DWORD, pdv: DWORD
ScreenToClient proto, hWnd: HANDLE, lpPoint: ptr POINT
SelectObject proto, hdc: HANDLE, h: HANDLE
SetBkColor proto, hdc: HANDLE, color: COLORREF
SetPixelFormat proto, hdc: HANDLE, format: SDWORD, ppfd: ptr PIXELFORMATDESCRIPTOR
SetTextColor proto, hdc: HANDLE, color: COLORREF
Sleep proto, dwMilliseconds: DWORD
SwapBuffers proto, Arg1: HANDLE
TextOutA proto, hdc: HANDLE, x: SDWORD, y: SDWORD, lpString: DWORD, c_: SDWORD
TranslateMessage proto, lpMsg: ptr MSG
VirtualAlloc proto, lpAddress: DWORD, dwSize: DWORD, flAllocationType: DWORD, flProtect: DWORD
VirtualFree proto, lpAddress: DWORD, dwSize: DWORD, dwFreeType: DWORD
WriteFile proto, hFile: HANDLE, lpBuffer: DWORD, nNumberOfBytesToWrite: DWORD, lpNumberOfBytesWritten: ptr DWORD, lpOverlapped: DWORD
wglCreateContext proto, Arg1: HANDLE
wglMakeCurrent proto, arg1: HANDLE, arg2: HANDLE
wglGetProcAddress proto, Arg1: DWORD
