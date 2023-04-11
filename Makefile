.PHONY: all clean

output_bin := zelda.bin zelda_PAL60.bin audio.bin

zelda_dep := main.asm \
  $(wildcard include/*.asm) \
  $(wildcard b/*.asm) \
  $(wildcard c/*.asm) \
  $(wildcard en/*.asm) \
  $(wildcard rs/*.asm) \
  $(wildcard spr/*.asm) \
  kworld.asm \
  gen/atan2.asm \
  gen/world/b1world.asm \
  gen/RoomScript.asm \
  gen/mesg_data_0A.asm \
  gen/ms_header.asm \
  gen/bitcount.asm \
  gen/spr_tri.asm \

all: $(output_bin)

init:
	mkdir -p gen/world
	python3 py/color.py

deptest:
	echo $(zelda_dep)

clean:
	echo $(output_bin)
	$(RM) -r $(output_bin) gen
	mkdir -p gen/world

audio.bin: gen/ms_header.asm audio.asm
	dasm audio.asm -f3 -oaudio.bin -saudio.sym -T1 -Iinclude

proto.bin: proto.asm
	dasm proto.asm -f3 -oproto.bin -sproto.sym -T1 -Iinclude

zelda.bin: $(zelda_dep)
	dasm main.asm -f3 -ozelda_PAL60.bin -DPAL60 -Iinclude $(flags)
	dasm main.asm -f3 -ozelda.bin -szelda.sym -T1 -Iinclude $(flags)

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

gen/bitcount.asm: py/bitcount.py
	python3 py/bitcount.py

gen/spr_tri.asm: py/spr_tri.py
	python3 py/spr_tri.py