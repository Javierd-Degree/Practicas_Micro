all: p4a.com p4b.exe

p4a.com: p4a.obj
 tlink /v /t p4a
p4a.obj: p4a.asm 
 tasm /zi p4a.asm,,p4a.lst
 
p4b.exe: p4b.obj
 tlink /v p4b
p4b.obj: p4b.asm 
 tasm /zi p4b.asm,,p4b.lst
 
 
clean:
	del *.obj
	del *.lst
	del *.map
	del *.exe
	del *.com