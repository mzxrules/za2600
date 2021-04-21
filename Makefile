.PHONY: all
all: zelda.bin audio.bin

audio.bin: audio.asm gen/s0_dung.asm
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1

zelda.bin: gen/world/b1world.asm gen/ptr.asm vars.asm main.asm spr/spr_room_pf1.asm spr/spr_room_pf2.asm
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1
    
gen/ptr.asm: ptr.py
	python3 ptr.py
    
gen/s0_dung.asm: sound.py
	python3 sound.py

gen/world/b1world.asm: world/w0.bin world.py
	python3 world.py