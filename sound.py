#!/usr/bin/env python3
from asmgen import *

N1dic = { #Buzzy
    "C3" : 31,
    "A#3" : 8
}

N4dic = {
    "B4"  : 31,
    "C5"  : 29,
    "C#5" : 27,
    "D5"  : 26,
    "D#5" : 24,
    "E5"  : 23, #23
    "F5"  : 21,
    "F#5" : 20,
    "G5"  : 19,
    "G#5" : 18,
    "A5"  : 17,
    "A#5" : 16,
    "B5"  : 15,
    "C6"  : 14,
    "C#6" : 13,
    "D6"  : 12, #bad
    #"D#6" : 11, #bad
    "E6"  : 11,
    "G6"  : 9,
    "A6"  : 8,
    "B6"  : 7,
    "C#7" : 6,
    "E7"  : 5,
    "G7"  : 4,
    "B7"  : 3,
}
NBdic = {
    "E3"  : 31,
    "F3"  : 29,
    "F#3" : 27,
    "G3"  : 26,
    "G#3" : 24,
    "A3"  : 23,
    "B3"  : 20,
    "C4"  : 19,
    "C#4" : 18,
    "D4"  : 17,
    "D#4" : 16,
    "E#4" : 15,
    "F4"  : 14,
    "F#4" : 13,
    "A4"  : 11,
    "C5"  : 9,
    "D5"  : 8,
    "E5"  : 7,
    "F#5" : 6,
    "A5"  : 5,
    "C6"  : 4,
    "E6"  : 3,
    "A6"  : 2,
    "E7"  : 1
}

def DumpSong(name, channelNotes, beat):
    time = 0
    header = []
    notes = []
    durs = []
    tones = []
    for keyStr, dur in channelNotes:
        note = 31
        if keyStr == "_":
            tone = 0
            note = 0
        elif keyStr in N4dic:
            tone = 4
            note = N4dic[keyStr]
        elif keyStr in NBdic:
            tone = 12
            note = NBdic[keyStr]
        elif keyStr in N1dic:
            tone = 1
            note = N1dic[keyStr]
            print("Tone 1 {} {}".format(keyStr, dur))
        else:
            print("Error {} {}".format(keyStr, dur))
            tone = 1
            note = 31
            
        d = beat*dur
        while d > 256:
            d -= 256
            notes.append(note)
            durs.append(0)
            tones.append(tone)
            
        notes.append(note)
        durs.append((d//1)%256)
        tones.append(tone)
        
    header.append(len(notes))
    outstr = f"{name}_note:\n"
    outstr += ToAsm(notes)
    outstr += "    align 256\n"
    outstr += f"{name}_dur:\n"
    outstr += ToAsm(durs)
    outstr += "    align 256\n"
    outstr += f"{name}_tone:\n"
    outstr += ToAsm(tones)
    outstr += f"{name}_head:\n"
    outstr += ToAsm(header)
    print(header)
    return outstr

def ListToND(list, dim):
    r = []
    for i in range(0,len(list),dim):
        v = []
        for j in range(dim):
            v.append(list[i+j])
        r.append(v)
    return r

def ConvertMusic(a0, a1, bars=None):
    if bars is not None:
        a0 = a0[0:bars] 
        a1 = a1[0:bars]
    a0 = [item for sublist in a0 for item in sublist]
    a1 = [item for sublist in a1 for item in sublist]
    return (ListToND(a0, 2), ListToND(a1,2))

# BPM to frames:
# frames = 1 beat * (1 min/BPM) * (60 seconds /1 min) * (60 fps)

# Dungeon Theme
# 90 BPM 4/4 time signature

dungeon_beat = 3600/90 

dungeon_baseline = [
    #G4, everything is shifted up an octave
    [
    "G5", 8,
    "A#5", 4,
    "D6", 4,],
    [
    "C#6", 4,
    "F#5", 12,],
    [
    "F5", 10,
    "G#5", 4,
    "C#6", 2,],
    [
    "C6", 4,
    "E5", 12,],
    [
    "D#5", 1,
    "D5", 1,
    "D#5", 6,
    "G5", 3,
    "D#6", 3,
    "D6", 2,],
    [
    "D5", 1,
    "C#5", 1,
    "D5", 6,
    "G5", 3,
    "D6", 3,
    "C#5", 2,],
    
    # 5/4 time signature
    [
    "D5", 1,
    "F#4", 1,
    "A5", 1,
    "F#4", 1,
    "A5", 1,],
    [
    "C6", 1,
    "A5", 1,
    "C6", 1,
    "D#6", 1,
    "C6", 1,],
    [
    "D#6", 1,
    "F#6", 1,
    "A6", 1,
    "F#6", 1,
    "D#6", 1,],
    [
    "C6", 1,
    "D#6", 1,
    "C6", 1,
    "A5", 1,
    "F#5", 1],
]

dungeon_highline = [
    [
    "G3", 1,
    "A#3", 1,
    "D4", 1,
    "D#4", 1,] * 4,
    [ 
    "F#3", 1,
    "A3", 1,
    "D4", 1,
    "D#4", 1, ] * 4,
    [
    "F3", 1,
    "G#3", 1,
    "D4", 1,
    "D#4", 1 ] * 4,
    [
    "E3", 1,
    "G3", 1,
    "D4", 1,
    "D#4", 1 ] * 4,
    [
    "D#3", 1,
    "G3", 1,
    "C4", 1,
    "D4", 1 ] * 4,
    [
    "D3", 1,
    "G3", 1,
    "C4", 1,
    "D4", 1 
    ] * 4,
    
    # 5/4 time signature
    [
    "C4", 1,
    "F#4", 1,
    "A4", 1,
    "C5", 1,
    "F#4", 1,
    ],
    [
    "A4", 1,
    "C5", 1,
    "D#5", 1,
    "A4", 1,
    "C5", 1,
    ],
    [
    "D#5", 1,
    "C5", 1,
    "D#5", 1,
    "F#5", 1,
    "D#5", 1,
    ],
    [
    "F#5", 1,
    "A5", 1,
    "F#5", 1,
    "A5", 1,
    "C6",1
    ]
]
    
a0, a1 = ConvertMusic(dungeon_baseline, dungeon_highline,10)

test = []
for note, dir in a0:
    if dir > 2:
        test.append((note, 2))
        test.append(("_", dir-2))
    else:
        test.append((note,dir))
a0 = test

with open("gen/s0_dung.asm", "w") as file:
    file.write(DumpSong("s0_dung", a0, dungeon_beat))
    
with open("gen/s1_dung.asm", "w") as file:
    file.write(DumpSong("s1_dung", a1, dungeon_beat))