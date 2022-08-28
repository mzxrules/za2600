#!/usr/bin/env python3
from sound_common import *
from seq import *
from gensound import Sine, Triangle, Pan

#gensound_minute_ticks = 60000
#atari_minute_ticks = 3600
#a/g ratio = 0.06
atari_minute_ticks = 3600 # updates per minute
gensound_minute_ticks = 60000.0
ag_ratio = atari_minute_ticks / gensound_minute_ticks
target_bpm = 150 # beats per minute
quarter_bf = 1   # beats per quarter note

# 400 = 150 bpm gensound
#  24 = 150 bpm atari

#3600 / bpm = beat dur
#500 * 120 / (120) = beat dur

def GetBeat(bpm):
    # 0.5e3 = 120 bpm
    return gensound_minute_ticks / bpm 

def SeqToGenSound(seq):    
    dl = SeqChannelToGenSound(seq.ch0, seq.bpm, seq.qbeat)
    dr = SeqChannelToGenSound(seq.ch1, seq.bpm, seq.qbeat)
    return dl * Pan(50) + dr * Pan(-50)
    
def SeqChannelToGenSound(seq, bpm, qbf = 1):
    gSeqStr = ""
    gRestDur = (1/ag_ratio)
    for note, dur in seq:
        n = note
        if n == "_":
            n = "r"
        gDur = (dur*(atari_minute_ticks/bpm/qbf)-1)/ag_ratio
        gSeqStr += f"{n}={gDur} r={gRestDur} "
    return Sine(gSeqStr, duration = 1.0)

def MeasureTest(ch):
    sumTest = []
    for measure in ch:
        sum = 0
        for i in range(1, len(measure), 2) :
            sum += measure[i]
        sumTest.append(sum)
    print(sumTest)

seqs = {
    "dung" : Seq("ms_dung", 90, 4, dungeon_baseline, dungeon_highline),
    "gi"   : Seq("ms_gi", 90, 4, get_item_highline, get_item_baseline),
    "over" : Seq("ms_over", 90, 4, game_over_highline, empty_channel),
    "world": Seq("ms_world", 150, 1, overworld_highline, overworld_baseline),
    "intro": Seq("ms_intro", 150, 1, overworld_intro_highline, overworld_intro_baseline),
    "final": Seq("ms_final", 150, 1, dung_final_highline, dung_final_baseline),
    "tri"  : Seq("ms_tri", 150, 1, tri_highline, tri_baseline),
    "ice"  : Seq("ms_ice", 90, 1, ice_baseline, empty_channel),
    "lost" : Seq("ms_lost", 75, 1, lost_highline, lost_baseline)
}

songKey = "ice"

print("ch0")
MeasureTest(seqs[songKey].ch0)
print("ch1")
MeasureTest(seqs[songKey].ch1)

for k, seq in seqs.items():
    seq.Flatten()

seqs["final"].ch0 = seqs["final"].GetShiftChannel(0,6) + seqs["final"].GetShiftChannel(0,12)
seqs["final"].ch1 += seqs["final"].GetShiftChannel(1,6)

s = SeqToGenSound(seqs[songKey])
s.play()