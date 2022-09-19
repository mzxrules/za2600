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

    0b0111,
    0b0101,
    0b0101,
    0b0101,
    0b0111,
],
    "1" : [

    0b0010,
    0b0010,
    0b0010,
    0b0010,
    0b0010,
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

def dump_mesg_lut():
    strOut = ""
    msgTbl = [[], []]
    for i in range(64):
        msgTbl[0].append(f"<(MesgData+#${i*12:03X})")
        msgTbl[1].append(f">(MesgData+#${i*12:03X})")
    strOut += "; MesgAL\n" + ToAsm2(msgTbl[0],8) # pointer low
    strOut += "; MesgAH\n" + ToAsm2(msgTbl[1],8) # pointer high
    with open(f"gen/mesg_data_lut.asm", "w") as file:
        file.write(strOut)

def dump_text_bank(mesgList, bank):
    strOut = ""
    for mesg in mesgList:
        strOut += ToAsm(mesg)

    with open(f"gen/mesg_data_{bank}.asm", "w") as file:
        file.write(strOut)

# format messages such that they are fixed width
for i in range(len(mesg_data)):
    mesg_data[i] = '{:<24}'.format(mesg_data[i])

# configure max charset
zeldaSet = set("!',-.0123456789 ?ABCDEFGHIKLMNOPQRSTUVWXYZ") # crucially, no J
usedChars = UsedChars(mesg_data)
if not usedChars <= zeldaSet:
    print("Unexpected char:")
    print(sorted(usedChars - zeldaSet))
usedChars |= zeldaSet

# build superstring spritesheet
sprSeqs = []
charSprRef = { }

for char in usedChars:
    seqStr = "".join([str(int) for int in sprdic[char]])
    sprSeqs.append(seqStr)
    charSprRef[char] = [-1, seqStr]
    
sprScs = greedy_quickrand(sprSeqs)

# get char offsets for message data
for char in usedChars:
    charSprRef[char][0] = sprScs.find(charSprRef[char][1])

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
for char in sprScs:
    right_chr.append(helpme[char])
    
for char in right_chr:
    left_chr.append(char<<4)

with open("gen/text_left.asm", "w") as file:
    file.write(ToAsm(left_chr, 16))
    
with open("gen/text_right.asm", "w") as file:
    file.write(ToAsm(right_chr, 16))

# convert mesg_data to reference sprite offsets
# and split each 24 char line into frame A, frame B pairs 
mesgRawInfo =  [[], [], [], []]
mesgBankInfo = ["0A", "0B", "1A", "1B"]
index = 0
for mesg in mesg_data:
    raw24 = []
    for char in mesg:
        raw24.append(charSprRef[char][0])

    rawPairs = [raw24[i:i+2] for i in range(0, len(raw24), 2)]
    rawA = [rawPairs[i] for i in range(0, len(rawPairs), 2)]
    rawA = [item for sublist in rawA for item in sublist]
    rawB = [rawPairs[i] for i in range(1, len(rawPairs), 2)]
    rawB = [item for sublist in rawB for item in sublist]
    mesgRawInfo[index + 0].append(rawA)
    mesgRawInfo[index + 1].append(rawB)
    index = (index + 2) % 4

for i in range(4):
    dump_text_bank(mesgRawInfo[i], mesgBankInfo[i])

dump_mesg_lut()
    
# generate digit lookup table
raw = []
strOut = ""
for char in "0123456789 ":
    raw.append(charSprRef[char][0])
    
strOut = "MesgDigits:\n" + ToAsm(raw)

with open("gen/mesg_digits.asm", "w") as file:
    file.write(strOut)

print(sorted(usedChars)) 
print(sprScs)
print(len(sprScs))