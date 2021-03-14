zelda.bin: vars.asm main.asm sprite.asm audio.asm
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1