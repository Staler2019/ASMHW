.data

.code
OpenglInit proc
	invoke glClearColor, f_8, f_8, f_8, f1_
	invoke glEnable, GL_TEXTURE_2D
	invoke glEnable, GL_BLEND
	invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
	invoke glMatrixMode, GL_MODELVIEW
	invoke glLoadIdentity
	invoke glMatrixMode, GL_PROJECTION
	invoke glLoadIdentity
	invoke glMatrixMode, GL_TEXTURE
	invoke glLoadIdentity
	ret
OpenglInit endp

OpenglAllocateTexture proc, _Width: s32, _Height: s32, Buffer: ptr u32, Result: ptr u32
	invoke glGenTextures, 1, Result
	mov eax, Result
	invoke glBindTexture, GL_TEXTURE_2D, [eax]
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR
	invoke glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke glTexImage2D, GL_TEXTURE_2D, 0, GL_RGBA8, _Width, _Height, 0, GL_BGRA, GL_UNSIGNED_BYTE, Buffer
	invoke glBindTexture, GL_TEXTURE_2D, 0
	ret
OpenglAllocateTexture endp

OpenglQuad proc, MinX: f32, MinY: f32, MaxX: f32, MaxY: f32, R: f32, G: f32, B: f32, A: f32
	invoke glBegin, GL_QUADS
	invoke glColor4f, R, G, B, A
	invoke glVertex2f, MinX, MinY
	invoke glColor4f, R, G, B, A
	invoke glVertex2f, MaxX, MinY
	invoke glColor4f, R, G, B, A
	invoke glVertex2f, MaxX, MaxY
	invoke glColor4f, R, G, B, A
	invoke glVertex2f, MinX, MaxY
	invoke glEnd
	ret
OpenglQuad endp

OpenglTexturedQuad proc, MinX: f32, MinY: f32, MaxX: f32, MaxY: f32, R: f32, G: f32, B: f32, A: f32, TextureHandle: u32
	invoke glBindTexture, GL_TEXTURE_2D, TextureHandle
	invoke glBegin, GL_QUADS
	invoke glTexCoord2f, f0_, f0_
	invoke glColor4f, R, G, B, A
	invoke glVertex2f, MinX, MinY
	invoke glTexCoord2f, f1_, f0_
	invoke glColor4f, R, G, B, A
	invoke glVertex2f, MaxX, MinY
	invoke glTexCoord2f, f1_, f1_
	invoke glColor4f, R, G, B, A
	invoke glVertex2f, MaxX, MaxY
	invoke glTexCoord2f, f0_, f1_
	invoke glColor4f, R, G, B, A
	invoke glVertex2f, MinX, MaxY
	invoke glEnd
	ret
OpenglTexturedQuad endp