#!/usr/bin/env python3
from asmgen import *
N4dic = {
    "B4"  : 31,
    "C5"  : 29,
    "C#5" : 27,
    "D5"  : 26,
    "D#5" : 24,
    "E5"  : 22, #23
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
    "D#6" : 11, #bad
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

def ListToND(list, dim):
    r = []
    for i in range(0,len(list),dim):
        v = []
        for j in range(dim):
            v.append(list[i+j])
        r.append(v)
        
    return r

# BPM to frames:
# frames = 1 beat * (1 min/BPM) * (60 seconds /1 min) * (60 fps)

# Dungeon Theme
# 90 BPM 4/4 time signature

dungeon_beat = 3600/90 

dungeon_baseline = [
    "G4", 8,
    "A#4", 4,
    "D5", 4,
    
    "C#5", 4,
    "F#4", 12,
    
    "F4", 10,
    "G#4", 4,
    "C#5", 2,
    
    "C5", 4,
    "E4", 12,
    
    "D#4", 1,
    "D4", 1,
    "D#4", 6,
    "G4", 3,
    "D#5", 3,
    "D5", 2,
    
    "D4", 1,
    "C#4", 1,
    "D4", 6,
    "G4", 3,
    "D5", 3,
    "C#4", 2
]

dungeon_baseline = ListToND(dungeon_baseline, 2)

def DumpSong(name, channelNotes, beat):
    time = 0
    header = []
    notes = []
    durs = []
    tones = []
    for keyStr, dur in channelNotes:
        note = 31
        if keyStr in N4dic:
            tone = 4
            note = N4dic[keyStr]
        elif keyStr in NBdic:
            tone = 12
            note = NBdic[keyStr]
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
    outstr = "SO_note:\n"
    outstr += ToAsm(notes)
    outstr += "SO_dur:\n"
    outstr += ToAsm(durs)
    outstr += "SO_tone:\n"
    outstr += ToAsm(tones)
    outstr += "SO_head:\n"
    outstr += ToAsm(header)
    print(header)
    return outstr
    

with open("gen/dung_song.asm", "w") as file:
    file.write(DumpSong("dang", dungeon_baseline, dungeon_beat))