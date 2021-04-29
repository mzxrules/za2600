.PHONY: all
all: zelda.bin audio.bin

audio.bin: gen/ms_header.asm audio.asm
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1

zelda.bin: gen/world/b1world.asm gen/RoomScript.asm spr/spr_room_pf1.asm spr/spr_room_pf2.asm gen/mesg_data.asm gen/ms_header.asm vars.asm main.asm 
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1
    
gen/RoomScript.asm: ptr.py
	python3 ptr.py
    
gen/ms_header.asm: sound.py
	python3 sound.py
    
gen/mesg_data.asm: text.py
	python3 text.py

gen/world/b1world.asm: world/w0.bin world.py
	python3 world.py