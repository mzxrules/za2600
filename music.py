#!/usr/bin/env python3
from sound_common import *
from gensound import Sine, Triangle, Pan

#gensound_minute_ticks = 60000
#atari_minute_ticks = 3600
#a/g ratio = 0.06
atari_minute_ticks = 3600 # updates per minute
gensound_minute_ticks = 60000.0
ag_ratio = atari_minute_ticks / gensound_minute_ticks
target_bpm = 150 # beats per minute
quarter_bf = 1   # beats per quarter note

def GetBeat(bpm):
    # 0.5e3 = 120 bpm
    return gensound_minute_ticks / bpm 

def SeqToGenSound(seq, bpm, qbf = 1):
    gSeqStr = ""
    gRestDur = (1/ag_ratio)
    for note, dur in seq:
        n = note
        if n == "_":
            n = "r"
        gDur = (dur*(atari_minute_ticks/bpm/qbf)-1)/ag_ratio
        gSeqStr += f"{n}={gDur} r={gRestDur} "
    return Sine(gSeqStr, duration = 1.0)
    
# 400 = 150 bpm gensound
#  24 = 150 bpm atari

#3600 / bpm = beat dur
#500 * 120 / (120) = beat dur

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



empty_channel = [
    [ "_", 1 ]
]

sumTest = []
for measure in overworld_highline:
    sum = 0
    for i in range(1, len(measure), 2) :
        sum += measure[i]
    sumTest.append(sum)
print(sumTest)

a0, a1 = ConvertMusic(dungeon_highline, dungeon_baseline)
wo0, wo1 = ConvertMusic(overworld_highline, overworld_baseline)

#s = SeqToGenSound(wo0, target_bpm,1)
#s.play()

dl = SeqToGenSound(wo0, target_bpm, 1)
dr = SeqToGenSound(wo1, target_bpm, 1)
mix = dl * Pan(50) + dr * Pan(-50)
mix.play()