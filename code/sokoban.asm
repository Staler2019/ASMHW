
bmp_header struct
	MagicValue		u32 ?
	FileSize		u32 ?
	Reserved		u32 ?
	BitmapOffset	u32 ?
	biSize			u32 ?
	biWidth			s32 ?
	biHeight		s32 ?
	biPlanes		u16 ?
	biBitCount		u16 ?
	biCompression	u32 ?
	biSizeImage		u32 ?
	biXPelsPerMeter	s32 ?
	biYPelsPerMeter	s32 ?
	biClrUsed		u32 ?
	biClrImportant	u32 ?
bmp_header ends

loaded_bitmap struct
	BitmapWidth		s32 ?
	BitmapHeight	s32 ?
	Bitmap			voidptr ?
loaded_bitmap ends

memory_arena struct
	UsedSize	u32 ?
	MaxSize		u32 ?
	Memory		voidptr ?
memory_arena ends

.code

LoadBitmap proc, Path: ptr char, Result: loaded_bitmap
LoadBitmap endp

GameUpdate proc
	ret
GameUpdate endp

GameRender proc, WindowWidth: s32, WindowHeight: s32
	invoke glViewport, 0, 0, WindowWidth, WindowHeight
	invoke glClear, GL_COLOR_BUFFER_BIT
	invoke OpenglQuad, f0_, f0_, f_5, f_5, f0_, f0_, f0_, f1_
	invoke OpenglTexturedQuad, f0_, f0_, f_5, f_5, f1_, f1_, f1_, f1_, GLOBALTextureHandle
	ret
GameRender endp