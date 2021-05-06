#!/usr/bin/env python3
from asmgen import *

notes = [
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "F",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B"
]

N1dic = { #Buzzy
    "C2" : 31,
    "A#3" : 8
}

N6dic = { #Buzzy/Pure
    "D2" : 13,
    "D#2" : 12,
    "F#2" : 10, 
    "D3" : 6
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
    "A#3" : 22, #bad
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

toneDics = [
    (4, N4dic),
    (12, NBdic),
    (1, N1dic),
    (6, N6dic)
]

tonePackDic = {
    0 : 0,
    1 : 1,
    4 : 2,
    6 : 3,
    12 : 4,
}

def NoteSpectrumTest():
    testSeq = []
    for i in range(1, 9*12):
        testSeq.append((i,0))
    seq = DecSeqToStrSeq(testSeq)
    for note, dur in seq:
        foundNote = False
        for toneVal, dic in toneDics:
                if note in dic:
                    foundNote = True
                    print(note + " GOOD")
                    break;
        if not foundNote:
            print(note + " BAD")


def DumpSongChannel(name, channelNotes, beat):
    time = 0
    totalNotes = 0
    notes = []
    durs = []
    tones = []
    for keyStr, dur in channelNotes:
        tone = 0
        note = 32
        if keyStr == "_":
            tone = 0
            note = 0
        else:
            for toneVal, dic in toneDics:
                if keyStr in dic:
                    tone = toneVal
                    note = dic[keyStr]
                    break;
        if tone == 0 and note == 32:
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
        
    totalNotes = len(notes)
    for i in range(len(notes)):
        note = notes[i] << 3
        note |= tonePackDic[tones[i]]
        notes[i] = note
    return [name, totalNotes, notes, durs]

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
    
def SeqPlayableTest(seq):
    score = 0
    for note, dur in seq:
        if note == "_":
            score += 1
        else:
            for toneVal, dic in toneDics:
                if note in dic:
                    score += 1
    return score

def StrSeqToDecSeq(seq):
    newSeq = []
    for note, dur in seq:
        for i in range(11, -1, -1):
            if note.find(notes[i]) != -1:
                noteDigit = int(note[len(notes[i]):])
                newSeq.append((noteDigit * 12 + i, dur))
                break
    return newSeq

def DecSeqToStrSeq(seq):
    newSeq = []
    for note, dur in seq:
        i = note % 12
        p = note // 12
        newSeq.append((f"{notes[i]}{p}", dur))
    return newSeq
    
def ShiftDecSeq(seq, shift):
    newSeq = []
    for note, dur in seq:
        newSeq.append((note+shift, dur))
    return newSeq
    
def ShiftStrSeq(seq, shift):
    d = StrSeqToDecSeq(seq)
    return DecSeqToStrSeq(ShiftDecSeq(d, shift))

def FindBestSeq(seq):
    dSeq = StrSeqToDecSeq(seq)
    scores = []
    for shift in range(-36, 16):
        s = ShiftDecSeq(dSeq, shift)
        scores.append((SeqPlayableTest(DecSeqToStrSeq(s)),shift))
        
    scores.sort(reverse=True)
    print(scores)
    quit()

#NoteSpectrumTest()
#quit()

# BPM to frames:
# frames = 1 beat * (1 min/BPM) * (60 seconds /1 min) * (60 fps)

# Dungeon Theme
# 90 BPM 4/4 time signature

dungeon_beat = 3600/90/4

dungeon_baseline = [
    #G4, everything is shifted up an octave
    [
    "G5", 8,
    "A#5", 4,
    "D6", 4,
    ],
    [
    "C#6", 4,
    "F#5", 12,
    ],
    [
    "F5", 10,
    "G#5", 4,
    "C#6", 2,
    ],
    [
    "C6", 4,
    "E5", 12,
    ],
    [
    "D#5", 1,
    "D5", 1,
    "D#5", 6,
    "G5", 3,
    "D#2", 3, # D#6, but I don't have one
    "D6", 2,
    ], 
    [
    "D5", 1,
    "C#5", 1,
    "D5", 6,
    "G5", 3,
    "D2", 3, # D6
    "C#5", 2, # C#6
    ],
    
    # 5/4 time signature
    [
    "D5", 1,
    "F#4", 1,
    "A5", 1,
    "F#4", 1,
    "A5", 1,
    ],
    [
    "C6", 1,
    "A5", 1,
    "C6", 1,
    "C2", 1, # D#6
    "C6", 1,
    ],
    [
    "C2", 2, # D#6
    #"F#2", 1, # F#6
    "A6", 1,
    "C2", 2, # F#6
    #"D#2", 1, # D#6
    ],
    [
    "C6", 1,
    "C2", 1, # D#6
    "C6", 1,
    "A5", 1,
    "F#5", 1],
]

dungeon_highline = [
    [
    "G3", 1,
    "A#3", 1,
    "D4", 1,
    "D#4", 1,
    ] * 4,
    [ 
    "F#3", 1,
    "A3", 1,
    "D4", 1,
    "D#4", 1,
    ] * 4,
    [
    "F3", 1,
    "G#3", 1,
    "D4", 1,
    "D#4", 1 
    ] * 4,
    [
    "E3", 1,
    "G3", 1,
    "D4", 1,
    "D#4", 1
    ] * 4,
    [
    "D#2", 1, #"D#3", 1,
    "G3", 1,
    "C4", 1,
    "D4", 1 
    ] * 4,
    [
    "D2", 1, # "D3", 1,
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

get_item_highline = [
    [
    "A5", 1,
    "A#5", 1,
    "B5", 1,
    "C6", 3,
    "_", 4,
    ]
]

get_item_baseline = [
    [
    "C5", 1,
    "C#5", 1,
    "D5", 1,
    "D#5", 3,
    "_", 4,
    ]
]

game_over_highline = [
    [
    "G6", 2,
    "G5", 2,
    "C6", 2,
    "E6", 2,
    ],
    [
    "D#6", 2,
    "G5", 2,
    "B6", 2,
    "B5", 2,
    ],
    [
    "A6", 2,
    "C6", 2,
    "E6", 2,
    "A6", 2,
    ],
    [
    "G6", 2,
    "C6", 2,
    "D6", 2,
    "E6", 2,
    ],
    [
    "A6", 2,
    "C6", 2,
    "F6", 2,
    "A6", 2,
    ],
    [
    "G#6", 2,
    "C6", 2,
    "D6", 2,
    "F6", 2,
    ],
    [
    "E6", 2,
    "G5", 2,
    "C6", 2,
    "E6", 2,
    ],
    [
    "D6", 2,
    "A5", 2,
    "B5", 2,
    "D6", 2
    ]
]
empty_channel = [
    [ "_", 1 ]
]

def AdjustDungeonBaseline(seq):
    test = []
    for note, dir in seq:
        if dir > 2:
            test.append((note, 2))
            test.append(("_", dir-2))
        else:
            test.append((note,dir))
    return test
    
a0, a1 = ConvertMusic(dungeon_baseline, dungeon_highline,10)
gi0, gi1 = ConvertMusic(get_item_highline, get_item_baseline)
ov0, ov1 = ConvertMusic(game_over_highline, empty_channel)

a0 = AdjustDungeonBaseline(a0)
ov0 = ShiftStrSeq(ov0,-10) #FindBestSeq(ov0)

print("dung")
dungSq = [DumpSongChannel("ms_dung0", a0, dungeon_beat), DumpSongChannel("ms_dung1", a1, dungeon_beat)]
print("gi")
giSq = [DumpSongChannel("ms_gi0", gi0, dungeon_beat), DumpSongChannel("ms_gi1", gi1, dungeon_beat)]
print("over")
overSq = [DumpSongChannel("ms_over0", ov0, dungeon_beat), DumpSongChannel("ms_over1", ov1, dungeon_beat)]

fl = [
    ("{}_note",2),
    ("{}_dur", 3)
]

sequences = [dungSq, giSq, overSq]

header = [0] * 16
headerCur = 1
for seq in sequences:
    for chan in seq:
        header[headerCur] = chan[1]
        for np, index in fl:
            n = np.format(chan[0])
            str = f"{n}:\n" + ToAsm(chan[index])
            with open(f"gen/{n}.asm", "w") as file:
                file.write(str)
        headerCur += 8
        headerCur %= 16
    headerCur += 1
            
str = "ms_header:\n" + ToAsm(header)
with open("gen/ms_header.asm", "w") as file:
    file.write(str)
