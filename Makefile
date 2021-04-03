zelda.bin: world/w0_w0.asm ptr.asm vars.asm main.asm spr_world_pf1.asm spr_world_pf2.asm spr_dung_pf1.asm spr_dung_pf2.asm audio.asm 
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1
    
ptr.asm: ptr.py
	python3 ptr.py

world/w0_w0.asm: world/w0.bin
	python3 world.py