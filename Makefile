.PHONY: all clean

output_bin := zelda.bin zelda_PAL60.bin audio.bin

zelda_dep := \
  include/zmacros.asm \
  include/vars.asm \
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
  b/game_entry.asm \
  b/game_main.asm \
  b/game_pause.asm \
  c/always.asm \
  c/mi_system.asm \
  c/player_input.asm \
  b/draw.asm \
  b/tx.asm \
  b/sh.asm \
  b/en.asm \
  b/au.asm \
  b/rs.asm \
  b/room.asm \
  main.asm

all: $(output_bin)

init: 
	mkdir -p gen/world
	python3 py/color.py

clean:
	echo $(output_bin)
	$(RM) -r $(output_bin) gen
	mkdir -p gen/world

audio.bin: gen/ms_header.asm audio.asm
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1 -Iinclude

zelda.bin: $(zelda_dep)
	dasm main.asm -f3 -ozelda_PAL60.bin -DPAL60  -Iinclude
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1  -Iinclude
    
gen/RoomScript.asm: py/mesg.py py/ptr.py
	python3 py/ptr.py
    
gen/ms_header.asm: py/sound_common.py py/seq.py py/sound.py
	python3 py/sound.py
    
gen/mesg_data_0A.asm: py/mesg.py py/text.py
	python3 py/text.py

gen/world/b1world.asm: world/w0.bin world/w1.bin py/world.py
	python3 py/world.py

gen/atan2.asm: py/atan2.py
	python3 py/atan2.py

gen/editor_color.txt: py/color.py
	python3 py/color.py