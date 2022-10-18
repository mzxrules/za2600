;==============================================================================
; Atan2
;----------
; X = Delta X
; Y = Delta Y
; Returns bitpacked value:
; & $80 = Delta X Sign
; & $40 = Delta Y Sign
; & $3F = index to Atan2 tables
;==============================================================================
Atan2: SUBROUTINE
    lda #0
    sta atan2Temp
    txa
    bpl .testYSign
    eor #$FF
    sec
    adc #0
    tax
    lda #$80
    sta atan2Temp
.testYSign
    tya
    bpl .reduceTest
    eor #$FF
    sec
    adc #0
    tay
    lda atan2Temp
    ora #$40
    sta atan2Temp
.reduceTest
    cpx #8
    bpl .reduce
    cpy #8
    bmi .result
.reduce
    txa
    lsr
    tax
    tya
    lsr
    tay
    bpl .reduceTest ;always branch
.result
    lda Mul8,y
    clc
    adc atan2Temp
    sta atan2Temp
    txa
    adc atan2Temp
    rts