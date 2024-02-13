; MIT License

; Copyright (c) 2023 Arlet Ottens

; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; to be clear, this license only applies to this file

; From https://github.com/Arlet/pseudo-random-number-generator

Rng2:
    clc
    lda #$41
    adc Rng2State+0
    sta Rng2State+0
    adc Rng2State+1
    sta Rng2State+1
    adc Rng2State+2
    sta Rng2State+2
    adc Rng2State+3
    sta Rng2State+3
    adc Rng2State+4
    asl
    adc Rng2State+3
    sta Rng2State+4
    eor Rng2State+2
    rts