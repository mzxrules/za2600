#!/usr/bin/env python3
from collections import defaultdict
import itertools
import random
from mesg import mesg_data
from asmgen import ToAsm, ToAsm2

sprdic = {
    "A" : [

    0b0010, 
    0b0101,
    0b0111,
    0b0101,
    0b0101,
],
    "B" : [

    0b0110,
    0b0101,
    0b0110,
    0b0101,
    0b0110,
],
    "C" : [

    0b0011,
    0b0100,
    0b0100,
    0b0100,
    0b0011,
],
    "D" : [

    0b0110,
    0b0101,
    0b0101,
    0b0101,
    0b0110,
],
    "E" : [

    0b0111,
    0b0100,
    0b0110,
    0b0100,
    0b0111,
],
    "F" : [

    0b0111,
    0b0100,
    0b0110,
    0b0100,
    0b0100,
],
    "G" : [

    0b0011,
    0b0100,
    0b0101,
    0b0101,
    0b0010,
],
    "H" : [

    0b0101,
    0b0101,
    0b0111,
    0b0101,
    0b0101,
],
    "I" : [

    0b0111,
    0b0010,
    0b0010,
    0b0010,
    0b0111,
],
    "J" : [

    0b0001,
    0b0001,
    0b0001,
    0b0101,
    0b0010,
],
    "K" : [

    0b0101,
    0b0101,
    0b0110,
    0b0101,
    0b0101,
],
    "L" : [

    0b0100,
    0b0100,
    0b0100,
    0b0100,
    0b0111,
],
    "M" : [

    0b0101,
    0b0111,
    0b0111,
    0b0101,
    0b0101,
],
    "N" : [

    0b0110,
    0b0101,
    0b0101,
    0b0101,
    0b0101,
],
    "O" : [

    0b0111,
    0b0101,
    0b0101,
    0b0101,
    0b0111,
],
    "P" : [

    0b0110,
    0b0101,
    0b0110,
    0b0100,
    0b0100,
],
    "Q" : [

    0b0010,
    0b0101,
    0b0101,
    0b0101,
    0b0011,
],
    "R" : [

    0b0110,
    0b0101,
    0b0110,
    0b0101,
    0b0101,
],
    "S" : [

    0b0011,
    0b0100,
    0b0010,
    0b0001,
    0b0110,
],
    "T" : [

    0b0111,
    0b0010,
    0b0010,
    0b0010,
    0b0010,
],
    "U" : [

    0b0101,
    0b0101,
    0b0101,
    0b0101,
    0b0111,
],
    "V" : [

    0b0101,
    0b0101,
    0b0101,
    0b0101,
    0b0010,
],
    "W" : [

    0b0101,
    0b0101,
    0b0111,
    0b0111,
    0b0101,
],
    "X" : [

    0b0101,
    0b0101,
    0b0010,
    0b0101,
    0b0101,
],
    "Y" : [

    0b0101,
    0b0101,
    0b0010,
    0b0010,
    0b0010,
],
    "Z" : [

    0b0111,
    0b0001,
    0b0010,
    0b0100,
    0b0111,
],
    " " : [

    0b0000,
    0b0000,
    0b0000,
    0b0000,
    0b0000,
],
    "." : [

    0b0000,
    0b0000,
    0b0000,
    0b0000,
    0b0010,
],
    "?" : [

    0b0110,
    0b0001,
    0b0010,
    0b0000,
    0b0010,
],
    "!" : [

    0b0010,
    0b0010,
    0b0010,
    0b0000,
    0b0010,
],
    "," : [

    0b0000,
    0b0000,
    0b0000,
    0b0010,
    0b0100,
],
    "-" : [

    0b0000,
    0b0000,
    0b0111,
    0b0000,
    0b0000,
],
    "+" : [

    0b0010,
    0b0010,
    0b0111,
    0b0010,
    0b0010,
],
    "'" : [

    0b0010,
    0b0100,
    0b0000,
    0b0000,
    0b0000,
],
    "(" : [

    0b0010,
    0b0100,
    0b0100,
    0b0100,
    0b0010,
],
    ")" : [

    0b0100,
    0b0010,
    0b0010,
    0b0010,
    0b0100,
],
    "<" : [

    0b0001,
    0b0010,
    0b0100,
    0b0010,
    0b0001,
],
    ">" : [

    0b0100,
    0b0010,
    0b0001,
    0b0010,
    0b0100,
],
    ":" : [

    0b0000,
    0b0100,
    0b0000,
    0b0100,
    0b0000,
],
    "/" : [

    0b0001,
    0b0001,
    0b0010,
    0b0100,
    0b0100,
],
    "=" : [

    0b0000,
    0b0111,
    0b0000,
    0b0111,
    0b0000,
],
    '"' : [

    0b0101,
    0b0101,
    0b0000,
    0b0000,
    0b0000,
],
    "▸" : [

    0b0000,
    0b0010,
    0b0011,
    0b0010,
    0b0000,
],
    "0" : [

    0b0010,
    0b0101,
    0b0101,
    0b0101,
    0b0010,
],
    "1" : [

    0b0010,
    0b0110,
    0b0010,
    0b0010,
    0b0111,
],
    "2" : [

    0b0110,
    0b0001,
    0b0010,
    0b0100,
    0b0111,
],
    "3" : [

    0b0110,
    0b0001,
    0b0010,
    0b0001,
    0b0110,
],
    "4" : [

    0b0101,
    0b0101,
    0b0111,
    0b0001,
    0b0001,
],
    "5" : [

    0b0111,
    0b0100,
    0b0110,
    0b0001,
    0b0110,
],
    "6" : [

    0b0011,
    0b0100,
    0b0110,
    0b0101,
    0b0010,
],
    "7" : [

    0b0111,
    0b0001,
    0b0010,
    0b0100,
    0b0100,
],
    "8" : [

    0b0010,
    0b0101,
    0b0010,
    0b0101,
    0b0010,
],
    "9" : [

    0b0010,
    0b0101,
    0b0011,
    0b0001,
    0b0110,
]}

def overlap(a, b, min_length=1):
    start = 0
    while True:
        start = a.find(b[:min_length], start)
        if start == -1:
            return 0
        if b.startswith(a[start:]):
            return len(a)-start
        start += 1
        
def pick_maximal_overlap(reads, k=1):
    reada, readb = None, None
    best_olen = 0
    for a, b in itertools.permutations(reads, 2):
        olen = overlap(a, b, min_length=k)
        if olen > best_olen:
            reada, readb = a, b
            best_olen = olen
    return reada, readb, best_olen
    
def greedy_scs(reads, k=1):
    read_a, read_b, olen = pick_maximal_overlap(reads, k)
    while olen > 0:
        reads.remove(read_a)
        reads.remove(read_b)
        reads.append(read_a + read_b[olen:])
        read_a, read_b, olen = pick_maximal_overlap(reads, k)
    return ''.join(reads)

def UsedChars(mesg_data):
    strSet = set()
    for mesg in mesg_data:
        strSet |= set(mesg)
    return strSet
    
def greedy_quickrand(seq):
    copy = seq.copy()
    result = greedy_scs(copy,1)
    for i in range(100):
        copy = seq.copy()
        random.shuffle(copy)
        r = greedy_scs(copy, 1)
        if len(r) < len(result):
            result = r
    return result

# format messages such that they are fixed width
for i in range(len(mesg_data)):
    mesg_data[i] = '{:<24}'.format(mesg_data[i])

usedChars = UsedChars(mesg_data)
usedChars |= set("0123456789 ")

sprSeqs = []
charSprRef = { }

for chr in usedChars:
    seqStr = "".join([str(int) for int in sprdic[chr]])
    sprSeqs.append(seqStr)
    charSprRef[chr] = [-1, seqStr]
    
sprScs = greedy_quickrand(sprSeqs)

# get chr offsets for message data
for chr in usedChars:
    charSprRef[chr][0] = sprScs.find(charSprRef[chr][1])

mesgRaw = []

for mesg in mesg_data:
    raw = []
    for chr in mesg:
        raw.append(charSprRef[chr][0])
    rawPairs = [raw[i:i+2] for i in range(0, len(raw), 2)]
    rawA = [rawPairs[i] for i in range(0, len(rawPairs), 2)]
    rawA = [item for sublist in rawA for item in sublist]
    rawB = [rawPairs[i] for i in range(1, len(rawPairs), 2)]
    rawB = [item for sublist in rawB for item in sublist]
    mesgRaw.append(rawB)
    mesgRaw.append(rawA)

helpme = {
    "0" : 0,
    "1" : 1,
    "2" : 2,
    "3" : 3,
    "4" : 4,
    "5" : 5,
    "6" : 6,
    "7" : 7
}

left_chr = []
right_chr = []
for chr in sprScs:
    right_chr.append(helpme[chr])
    
for chr in right_chr:
    left_chr.append(chr<<4)

with open("gen/text_left.asm", "w") as file:
    file.write(ToAsm(left_chr, 16))
    
with open("gen/text_right.asm", "w") as file:
    file.write(ToAsm(right_chr, 16))
    
strOut = ""
msgTbl = [[], [], [], []]
for i in range(len(mesgRaw) // 2):
    dA = mesgRaw[i*2+0]
    dB = mesgRaw[i*2+1]
    strOut += f"Mesg{i}A:\n"
    strOut += ToAsm(dA)
    strOut += f"Mesg{i}B:\n"
    strOut += ToAsm(dB)
for i in range(len(mesgRaw) // 4):
    msgTbl[0].append(f"<(Mesg{i*2}A)")
    msgTbl[0].append(f"<(Mesg{i*2}B)")
    msgTbl[0].append(f"<(Mesg{i*2+1}A)")
    msgTbl[0].append(f"<(Mesg{i*2+1}B)")
    msgTbl[1].append(f">(Mesg{i*2}A)")
    msgTbl[1].append(f">(Mesg{i*2}B)")
    msgTbl[1].append(f">(Mesg{i*2+1}A)")
    msgTbl[1].append(f">(Mesg{i*2+1}B)")
    
strOut += "MesgAL:\n" + ToAsm2(msgTbl[0],8)
strOut += "MesgAH:\n" + ToAsm2(msgTbl[1],8)

with open("gen/mesg_data.asm", "w") as file:
    file.write(strOut)
    
# generate digit lookup table
raw = []
for chr in "0123456789 ":
    raw.append(charSprRef[chr][0])
    
strOut = "MesgDigits:\n" + ToAsm(raw)

with open("gen/mesg_digits.asm", "w") as file:
    file.write(strOut)

print(sorted(usedChars)) 
print(sprScs)
print(len(sprScs))