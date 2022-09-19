#!/usr/bin/env python3

#linear feedback shift register
#xor 0xB4 results in 0xD8 looping to itself

a_C = False # carry flag
a_N = False # negative
a_O = False # overflow

def RESET_FLAGS():
    a_C = False # carry flag
    a_N = False # negative
    a_O = False # overflow

def ADC(acc):
    if a_C:
        acc = acc + 1
    

def lfsr_rand(val):
    carry = (val & 1) == 1
    val = val >> 1
    if not carry:
        return val ^ 0xB4
    return val

def lcg_rand(val):
    val = 5 * val + 179
    return val & 0xFF

def getnext(l):
    for i in range(256):
        if not l[i][2]:
            return l[i]
    return None
    
def main():
    test = []
    result = []
    for i in range(256):
        test.append([i, lcg_rand(i), False])
        #print(f"{i:02X} -> {test[i][0]:02X}")
        
    next = getnext(test)
    while next != None:
        print(next)
        curChain = []
        result.append(curChain)
        while not next[2]:
            curChain.append(next[0])
            next[2] = True
            next = test[next[1]]
        next = getnext(test)
    print(result)

main()