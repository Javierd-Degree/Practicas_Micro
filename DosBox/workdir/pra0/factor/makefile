all: factor.exe m_factor.exe
factor.exe: factor.obj
	tlink /v factor
factor.obj: factor.asm 
	tasm /zi factor.asm,,factor.lst
	
m_factor.exe: m_factor.obj
	tlink /v m_factor
m_factor.obj: m_factor.asm 
	tasm /zi m_factor.asm,,m_factor.lst