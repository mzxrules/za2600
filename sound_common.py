#!/usr/bin/env python3

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

def StrSeqToDecSeq(seq):
    newSeq = []
    for note, dur in seq:
        for i in range(11, -1, -1):
            if note.find(notes[i]) != -1:
                noteDigit = int(note[len(notes[i]):])
                newSeq.append((noteDigit * 12 + i, dur))
                break
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
    for shift in range(-36, 26):
        s = ShiftDecSeq(dSeq, shift)
        nSeq = DecSeqToStrSeq(s)
        scores.append((SeqNoteExistTest(nSeq),SeqPlayableTest(nSeq),shift))
        
    scores.sort(reverse=True)
    print(scores)
    quit()
    
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