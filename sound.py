#!/usr/bin/env python3
from asmgen import *
from sound_common import *

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

# BPM to frames:
# frames = 1 beat * (1 min/BPM) * (60 seconds /1 min) * (60 fps)

# Dungeon Theme
# 90 BPM 4/4 time signature, so quarter gets beat
# 1 = sixteenth note, so divide by 4
dungeon_beat = 3600/90/4

# Overworld Theme
# 90 BPM 4/4 time signature
overworld_beat = 3600/150

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

overworld_highline = [
    # 5
    [
        "A#5", 1,
        
        "F5", (1/3),
        "F5", (1/3),
        "E5", (1/3),
        
        "F5", (3/4),
        
        "A#5", (1/4),
        
        "A#5", (1/4),
        "C6", (1/4),
        "C#6",(1/4),
        "D#6", (1/4)
    ],
    [
        "F6", 2,
        "_", (1/2),
        "F6", (1/2),
        
        "F6", (1/3),
        "F#6", (1/3),
        "G#6", (1/3)
    ],
    [
        "A#6", 2, #(3/4)+1,
        #"_", 1,
        
        "_", (1/3),
        "A#6", (1/3),
        "A#6", (1/3),
        
        "A#6", (1/3),
        "G#6", (1/3),
        "F#6", (1/3)
    ],
    [
        "G#6", (2/3),
        "F#6", (1/3),
        
        "F6", (6/3),
        #"_", (1/3),
        "F6", 1,
    ],
    [
        "D#6", (1/2),
        "D#6", (1/4),
        "F6", (1/4),
        
        "F#6", 2,
        
        "F6", (1/2),
        "D#6", (1/2)
    ],
    [
        "C#6", (1/2),
        "C#6", (1/4),
        "D#6", (1/4),
        
        "F6", 2,
        
        "D#6", (1/2),
        "C#6", (1/2)
    ],
    [
        "C6", (1/2),
        "C6", (1/4),
        "D6", (1/4),
        
        "E6", 2,
        
        "G6", 1
    ],
    [
        "F6", (1/2), #highline
        "F5", (1/4), #basey line
        "F5", (1/4),
        
        "F5", (1/2),
        "F5", (1/4),
        "F5", (1/4),
        
        "F5", (1/2),
        "F5", (1/4),
        "F5", (1/4),
        
        "F5", (1/2),
        "F5", (1/2),
    ],
    [
        "A#5", 1,
        
        "F5", (1/3),
        "F5", (1/3),
        "E5", (1/3),
        
        "F5", (3/4),
        
        "A#5", (1/4),
        
        "A#5", (1/4),
        "C6", (1/4),
        "C#6",(1/4),
        "D#6", (1/4)
    ],
    # 14. F6-> G#5
    [
        "F6", (3/4),
        "A#5", (1/4),
        
        "A#5", (1/4),
        "C6", (1/4),
        "D6", (1/4),
        "D#6", (1/4),
        
        "F6", (1/2),
        "F6", (1/2),
        
        "F6", (1/3),
        "F#6", (1/3),
        "G#6", (1/3),
    ],
    [
        "A#6", 3,
        "C#7", 1,
    ],
    [
        "C7", 1,
        "A6", 2,
        "F6", 1
    ],
    [
        "F#6", 3,
        "A#6", 1,
    ],
    [
        "A6", 1,
        "F6", 2,
        "F6", 1
    ],
    [
        "F#6", 3,
        "A#6", 1,
    ],
    [
        "A6", 1,
        "F6", 2,
        "D6", 1
    ],
    # 21
    [
        "D#6", 3,
        "F#6", 1
    ],
    [
        "F6", 1,
        "C#6", 2,
        "A#5", 1
    ],
    [
        "C6", (1/2),
        "C6", (1/4),
        "D6", (1/4),
        
        "E6", 2,
        "G6", 1
    ],
    [
        "F6", (1/2),
        
        "F5", (1/4),
        "F5", (1/4),
        
        "F5", (2/4),
        "F5", (1/4),
        "F5", (1/4),
        
        "F5", (2/4),
        "F5", (1/4),
        "F5", (1/4),
        
        "F5", (1/2),
        "F5", (1/2)
    ],
    
]

overworld_baseline = [
    [
        "B4", 1,
        
        "C5", (1/3),
        "B4", (1/3),
        "A4", (1/3),
        
        "B4", (3/4),
        "B4", (1/4),
        
        "B4", (1/4),
        "C5", (1/4),
        "C#5", (1/4),
        "D5", (1/4)
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
wo0, wo1 = ConvertMusic(overworld_highline, empty_channel)

a0 = AdjustDungeonBaseline(a0)
#FindBestSeq()
ov0 = ShiftStrSeq(ov0,-10)
wo0 = ShiftStrSeq(wo0,-11)

print("dung")
dungSq = [DumpSongChannel("ms_dung0", a0, dungeon_beat), DumpSongChannel("ms_dung1", a1, dungeon_beat)]
print("gi")
giSq = [DumpSongChannel("ms_gi0", gi0, dungeon_beat), DumpSongChannel("ms_gi1", gi1, dungeon_beat)]
print("over")
overSq = [DumpSongChannel("ms_over0", ov0, dungeon_beat), DumpSongChannel("ms_over1", ov1, dungeon_beat)]
print("world")
worldSq = [DumpSongChannel("ms_world0", wo0, overworld_beat), DumpSongChannel("ms_world1", wo1, overworld_beat)]

fl = [
    ("{}_note",2),
    ("{}_dur", 3)
]

sequences = [dungSq, giSq, overSq, worldSq]

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
