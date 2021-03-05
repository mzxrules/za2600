zelda.bin: main.asm sprite.asm
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1