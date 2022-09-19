.PHONY: all clean

output_bin := zelda.bin zelda_PAL60.bin audio.bin

zelda_dep := \
  zmacros.asm \
  en/bosscucco.asm \
  en/darknut.asm \
  en/likelike.asm \
  en/octorok.asm \
  en/wallmaster.asm \
  gen/atan2.asm \
  gen/world/b1world.asm \
  gen/RoomScript.asm \
  gen/mesg_data_0A.asm \
  gen/ms_header.asm \
  spr/spr_room_pf1.asm \
  spr/spr_room_pf2.asm \
  b/0.asm \
  b/a.asm \
  b/draw.asm \
  b/tx.asm \
  b/sh.asm \
  b/en.asm \
  b/au.asm \
  b/rs.asm \
  b/room.asm \
  vars.asm \
  main.asm

all: $(output_bin)

init: 
	mkdir -p gen/world

clean:
	echo $(output_bin)
	$(RM) -r $(output_bin) gen
	mkdir -p gen/world

audio.bin: gen/ms_header.asm audio.asm
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1

zelda.bin: $(zelda_dep)
	dasm main.asm -f3 -ozelda_PAL60.bin -DPAL60
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1
    
gen/RoomScript.asm: mesg.py ptr.py
	python3 ptr.py
    
gen/ms_header.asm: sound_common.py seq.py sound.py
	python3 sound.py
    
gen/mesg_data_0A.asm: mesg.py text.py
	python3 text.py

gen/world/b1world.asm: world/w0.bin world/w1.bin world.py
	python3 world.py

gen/atan2.asm: project.py
	python3 project.py