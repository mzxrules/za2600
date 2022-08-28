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
    for note, dur in seq:
        if dur > 2:
            test.append((note, 2))
            test.append(("_", dur-2))
        else:
            test.append((note,dur))
    return test

seqs = {
    "dung" : Seq("ms_dung", 90, 4, dungeon_baseline, dungeon_highline),
    "gi"   : Seq("ms_gi", 90, 4, get_item_highline, get_item_baseline),
    "over" : Seq("ms_over", 90, 4, game_over_highline, empty_channel),
    "intro": Seq("ms_intro", 150, 1, overworld_intro_highline, overworld_intro_baseline),
    "world": Seq("ms_world", 150, 1, overworld_highline, overworld_baseline),
    "final": Seq("ms_final", 150, 1, dung_final_highline, dung_final_baseline),
    #"tri"  : Seq("ms_tri", 90, 1, ice_baseline, empty_channel),
    "tri"  : Seq("ms_tri", 150, 1, tri_highline2, tri_baseline2), # tri_baseline
    #"lost" : Seq("ms_tri", 75, 1, lost_highline, lost_baseline)
    "myst" : Seq("ms_myst", 150, 1/4, empty_channel, myst_baseline),
}

for k, seq in seqs.items():
    seq.Flatten()
    
#FindBestSeq(seqs["tri"].ch0)
#FindBestSeq(seqs["tri"].ch1)
#quit()

seqs["final"].ch0 = seqs["final"].GetShiftChannel(0,9) + seqs["final"].GetShiftChannel(0,15)
seqs["final"].ch1 = seqs["final"].GetShiftChannel(1,21) + seqs["final"].GetShiftChannel(1,15)
seqs["dung"].AdjustChannel(0, AdjustDungeonBaseline) 
seqs["over"].ShiftChannel(0,-10)
seqs["world"].ShiftChannel(0,-11)
seqs["world"].ShiftChannel(1,-11)
seqs["intro"].ShiftChannel(0,-11)
seqs["intro"].ShiftChannel(1,-11)
seqs["myst"].ShiftChannel(1,12)
seqs["tri"].ShiftChannel(0,5) #-8 5
seqs["tri"].ShiftChannel(1,5)
seqs["tri"].RepeatLastValidNote(0)
seqs["tri"].RepeatLastValidNote(1)
#seqs["lost"].ShiftChannel(0,0)
#seqs["lost"].ShiftChannel(1,0)

sequences = []

for k, seq in seqs.items():
    print(k)
    sequences.append(seq.DumpSong())

for c0, c1 in sequences:
    if c0.name == "ms_intro0":
        c0.totalNotes += 1
        c1.totalNotes += 1
    if c0.name == "ms_final0":
        c1.notes = c1.notes[::8] # return every 8th note 

fl = [
    ("{}_note",2, "notes"),
    ("{}_dur", 3, "durs")
]

MAX_SEQ = 16

header = [0] * MAX_SEQ * 2
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
        headerCur += MAX_SEQ
        headerCur %= MAX_SEQ * 2
    headerCur += 1
            
str = "ms_header:\n" + ToAsm(header)
with open("gen/ms_header.asm", "w") as file:
    file.write(str)
