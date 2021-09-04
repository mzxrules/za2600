.PHONY: all

zelda_dep := \
  en/bosscucco.asm \
  en/darknut.asm \
  en/likelike.asm \
  en/octorok.asm \
  en/wallmaster.asm \
  gen/world/b1world.asm \
  gen/RoomScript.asm \
  gen/mesg_data.asm \
  gen/ms_header.asm \
  spr/spr_room_pf1.asm \
  spr/spr_room_pf2.asm \
  b3.asm \
  b4.asm \
  b5.asm \
  b6.asm \
  b7.asm \
  b7-2.asm \
  b7-3.asm \
  vars.asm \
  main.asm

all: zelda.bin audio.bin

audio.bin: gen/ms_header.asm audio.asm
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1

zelda.bin: ${zelda_dep}
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1
    
gen/RoomScript.asm: ptr.py
	python3 ptr.py
    
gen/ms_header.asm: sound_common.py seq.py sound.py
	python3 sound.py
    
gen/mesg_data.asm: text.py
	python3 text.py

gen/world/b1world.asm: world/w0.bin world/w1.bin world.py
	python3 world.py