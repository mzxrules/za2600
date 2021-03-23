zelda.bin: vars.asm main.asm spr_world_pf1.asm spr_world_pf2.asm spr_dung_pf1.asm spr_dung_pf2.asm audio.asm 
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1