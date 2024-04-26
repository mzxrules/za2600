#!/usr/bin/env python3
from dataclasses import dataclass, field

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
    "D3" : 6,
    "E4" : 2
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

@dataclass
class AtariSeq:
    name: str
    totalNotes: int = 0
    notes: list = field(default_factory=list)
    durs: list = field(default_factory=list)

    def GetDuration(self):
        total = 0
        for dur in self.durs:
            total += dur
        return total

@dataclass
class Seq:
    name: str
    bpm: int # target beats per minute
    qbeat: int # value of a beat
    ch0: list
    ch1: list
    beat: int = 0 # Atari timesteps per beat

    def __post_init__(self):
        # BPM to frames:
        # frames = 1 beat * (1 min/BPM) * (60 seconds /1 min) * (60 fps)
        self.beat = 3600 / self.bpm / self.qbeat

    def Flatten(self, bars=None):
        self.ch0, self.ch1 = FlattenStrSeq(self.ch0, self.ch1, bars)

    def ShiftChannel(self, chan, shift):
        if chan == 0:
            self.ch0 = ShiftStrSeq(self.ch0, shift)
        else:
            self.ch1 = ShiftStrSeq(self.ch1, shift)

    def GetShiftChannel(self, chan, shift):
        if chan == 0:
            return ShiftStrSeq(self.ch0, shift)
        else:
            return ShiftStrSeq(self.ch1, shift)

    def AdjustChannel(self, chan, delegate):
        if chan == 0:
            self.ch0 = delegate(self.ch0)
        else:
            self.ch1 = delegate(self.ch1)

    def MuteInvalidNotes(self, chan):
        self.AdjustChannel(chan, MuteInvalidNotesChannel)

    def RepeatLastValidNote(self, chan):
        self.AdjustChannel(chan, RepeatLastValidNoteChannel)

    def DumpSong(self):
        c0 = DumpSongChannel(f"{self.name}0", self.ch0, self.beat)
        c1 = DumpSongChannel(f"{self.name}1", self.ch1, self.beat)
        return (c0, c1)

def SeqPlayableTest(seq):
    score = 0
    for note, dur in seq:
        if note == "_":
            score += 1
        else:
            for toneVal, dic in toneDics:
                if note in dic:
                    score += 1
                    break
    return score

def SeqNoteExistTest(seq):
    score = 0
    noteSet = set()
    for note, dur in seq:
        if note in noteSet:
            continue
        else:
            for toneVal, dic in toneDics:
                if note in dic:
                    noteSet.add(note)
    return len(noteSet)

def StrSeqToDecSeq(seq):
    newSeq = []
    for note, dur in seq:
        if note == "_":
            newSeq.append((0, dur))
            continue
        for i in range(11, -1, -1):
            if note.find(notes[i]) != -1:
                noteDigit = int(note[len(notes[i]):])
                newSeq.append((noteDigit * 12 + i, dur))
                break
    return newSeq

def DecSeqToStrSeq(seq):
    newSeq = []
    for note, dur in seq:
        if note == 0:
            newSeq.append(("_", dur))
            continue
        i = note % 12
        p = note // 12
        newSeq.append((f"{notes[i]}{p}", dur))
    return newSeq

def ShiftDecSeq(seq, shift):
    newSeq = []
    for note, dur in seq:
        if note == 0:
            newSeq.append((0, dur))
            continue
        newSeq.append((note+shift, dur))
    return newSeq

def ShiftStrSeq(seq, shift):
    d = StrSeqToDecSeq(seq)
    return DecSeqToStrSeq(ShiftDecSeq(d, shift))

def FindBestSeq(seq, scoreDiff = 0):
    dSeq = StrSeqToDecSeq(seq)
    scores = []
    maxScore = 0
    for shift in range(-50, 50):
        s = ShiftDecSeq(dSeq, shift)
        nSeq = DecSeqToStrSeq(s)
        scores.append((SeqNoteExistTest(nSeq),SeqPlayableTest(nSeq),shift))

    scores.sort(reverse=True)
    maxScore = scores[0][0]
    scores = list(filter(lambda x: x[0] >= maxScore-scoreDiff, scores))
    print(scores)

def ListToND(list, dim):
    r = []
    for i in range(0,len(list),dim):
        v = []
        for j in range(dim):
            v.append(list[i+j])
        r.append(v)
    return r

def FlattenStrSeq(a0, a1, bars=None):
    if bars is not None:
        a0 = a0[0:bars]
        a1 = a1[0:bars]
    a0 = [item for sublist in a0 for item in sublist]
    a1 = [item for sublist in a1 for item in sublist]
    return (ListToND(a0, 2), ListToND(a1,2))

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
                    break
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
    return AtariSeq(name, totalNotes, notes, durs)

def RepeatLastValidNoteChannel(chan):
    out = []
    lnote = "_"
    for keyStr, dur in chan:
        if keyStr == "_":
            out.append((keyStr,dur))
            continue
        dicFind = False
        for toneVal, dic in toneDics:
            if keyStr in dic:
                dicFind = True
                lnote = keyStr
                break

        out.append((lnote,dur))
    return out

def MuteInvalidNotesChannel(chan):
    out = []
    lmute = False
    lmuteDir = 0
    for keyStr, dur in chan:
        if keyStr == "_":
            lmute = True
            lmuteDir += dur
            continue
        dicFind = False
        for toneVal, dic in toneDics:
            if keyStr in dic:
                dicFind = True
                break
        if dicFind == True:
            if lmute == True:
                out.append(("_",lmuteDir))
                lmute = False
                lmuteDir = 0
            out.append((keyStr,dur))
        else:
            lmute = True
            lmuteDir += dur
    if lmute == True and lmuteDir != 0:
        out.append(("_",lmuteDir))
    return out

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
                    break
        if not foundNote:
            print(note + " BAD")