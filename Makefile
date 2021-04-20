zelda.bin: world/b1world.asm ptr.asm vars.asm main.asm spr_room_pf1.asm spr_room_pf2.asm audio.asm gen/s0_dung.asm
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1
    
ptr.asm: ptr.py
	python3 ptr.py
    
gen/s0_dung.asm: sound.py
	python3 sound.py

world/b1world.asm: world/w0.bin
	python3 world.py