GLint		textequ <SDWORD>
GLuint		textequ <DWORD>
GLfloat		textequ <REAL4>
GLenum		textequ <DWORD>
GLbitfield	textequ <DWORD>
GLsizei		textequ <SDWORD>
GLboolean	textequ <BYTE>
GLchar		textequ <BYTE>
GLsizeiptr	textequ <QWORD>
GLintptr	textequ <SQWORD>
GLclampf	textequ <REAL4>

GL_BLEND				equ 0be2h
GL_SRC_ALPHA			equ 0302h
GL_ONE_MINUS_SRC_ALPHA	equ 0303h
GL_MODELVIEW			equ 1700h
GL_PROJECTION			equ 1701h
GL_TEXTURE				equ 1702h
GL_QUADS				equ 0007h
GL_COLOR_BUFFER_BIT		equ 00004000h
GL_TEXTURE_2D			equ 0de1h
GL_REPEAT				equ 2901h
GL_CLAMP_TO_EDGE		equ 812fh
GL_LINEAR				equ 2601h
GL_TEXTURE_MAG_FILTER	equ 2800h
GL_TEXTURE_MIN_FILTER	equ 2801h
GL_TEXTURE_WRAP_S		equ 2802h
GL_TEXTURE_WRAP_T		equ 2803h
GL_RGBA8				equ 8058h
GL_BGRA					equ 80e1h
GL_UNSIGNED_BYTE		equ 1401h

glBegin proto, mode: GLenum
glBindTexture proto, target: GLenum, texture: GLuint
glBlendFunc proto, sfactor: GLenum, dfactor: GLenum
glColor4f proto, red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat
glClear proto, mask_: GLbitfield
glClearColor proto, red: GLclampf, green: GLclampf, blue: GLclampf, alpha: GLclampf
glEnable proto, cap: GLenum
glEnd proto
glGenTextures proto, n: GLsizei, textures: ptr GLuint
glMatrixMode proto, mode: GLenum
glLoadIdentity proto
glTexCoord2f proto, s: GLfloat, t: GLfloat
glTexImage2D proto, target: GLenum, level: GLint, internalformat: GLint, width_: GLsizei, height_: GLsizei, border: GLint, format: GLenum, type_: GLenum, data: DWORD
glTexParameteri proto, target: GLenum, pname: GLenum, param: GLint
glVertex2f proto, x: GLfloat, y: GLfloat
glViewport proto, x: GLint, y: GLint, width_: GLint, height_: GLint
