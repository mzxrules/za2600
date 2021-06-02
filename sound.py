#!/usr/bin/env python3
from asmgen import *
from sound_common import *
from seq import *

# Dungeon Theme
# 90 BPM 4/4 time signature, so quarter gets beat
# 1 = sixteenth note, so divide by 4

# Overworld Theme
# 90 BPM 4/4 time signature

def AdjustDungeonBaseline(seq):
    test = []
    for note, dir in seq:
        if dir > 2:
            test.append((note, 2))
            test.append(("_", dir-2))
        else:
            test.append((note,dir))
    return test

seqs = {
    "dung" : Seq("ms_dung", 90, 4, dungeon_baseline, dungeon_highline),
    "gi"   : Seq("ms_gi", 90, 4, get_item_highline, get_item_baseline),
    "over" : Seq("ms_over", 90, 4, game_over_highline, empty_channel),
    "intro": Seq("ms_intro", 150, 1, overworld_intro_highline, overworld_intro_baseline),
    "world": Seq("ms_world", 150, 1, overworld_highline, overworld_baseline),
}

for k, seq in seqs.items():
    seq.Flatten()

seqs["dung"].AdjustChannel(0, AdjustDungeonBaseline) 
seqs["over"].ShiftChannel(0,-10)
seqs["world"].ShiftChannel(0,-11)
seqs["world"].ShiftChannel(1,-11)
seqs["intro"].ShiftChannel(0,-11)
seqs["intro"].ShiftChannel(1,-11)

sequences = []

for k, seq in seqs.items():
    print(k)
    sequences.append(seq.DumpSong())

for c0, c1 in sequences:
    if c0.name == "ms_intro0":
        c0.totalNotes += 1
        c1.totalNotes += 1
        break

fl = [
    ("{}_note",2, "notes"),
    ("{}_dur", 3, "durs")
]

header = [0] * 16
headerCur = 1
for seq in sequences:
    for chan in seq:
        header[headerCur] = chan.totalNotes
        for np, index, type in fl:
            if type == "durs":
                print(f"{chan.name} {chan.GetDuration()}")
            n = np.format(chan.name)
            str = f"{n}:\n" + ToAsm(getattr(chan,type))
            with open(f"gen/{n}.asm", "w") as file:
                file.write(str)
        headerCur += 8
        headerCur %= 16
    headerCur += 1
            
str = "ms_header:\n" + ToAsm(header)
with open("gen/ms_header.asm", "w") as file:
    file.write(str)
