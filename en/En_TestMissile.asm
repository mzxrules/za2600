;==============================================================================
; mzxrules 2021
;==============================================================================

EnTestMissile: SUBROUTINE
    lda #0
    sta KernelId
    lda #COLOR_EN_RED
    sta enColor
    lda #<SprS0
    sta enSpr
    lda #>SprS0
    sta enSpr+1

    lda #$80
    bit enState
    bne .run
    sta enState
    sta enTestFX
    sta enTestFY
    lda #$60
    sta enTestTimer

    lda #$40
    sta enX
    lda #$30
    sta enY
    rts
.run
    lda #3
    and Frame
    bne .rts
    lda plX
    sec
    sbc enX
    tax

    lda plY
    sec
    sbc enY
    tay

    jsr Atan2
    sta enTestDir
.skipAtan2
    ; UpdateX
    lda enTestDir
    and #$3F
    tax
    lda enTestFX
    bit enTestDir
    bmi .subX
    clc
    adc Atan2X,x
    sta enTestFX
    lda enX
    adc #0
    sta enX
    jmp .updateY
.subX
    sec
    sbc Atan2X,x
    sta enTestFX
    lda enX
    sbc #0
    sta enX

.updateY
    lda enTestFY
    bit enTestDir
    bvs .subY
    clc
    adc Atan2Y,x
    sta enTestFY
    lda enY
    adc #0
    sta enY
    jmp .final
.subY
    sec
    sbc Atan2Y,x
    sta enTestFY
    lda enY
    sbc #0
    sta enY
.final
    ;dec enTestTimer
    ;bne .rts
    ;lda #0
    ;sta enState
.rts
    rts