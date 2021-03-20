zelda.bin: vars.asm main.asm audio.asm spr_world_pf1.asm spr_world_pf2.asm
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1