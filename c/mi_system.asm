;==============================================================================
; mzxrules 2022
;==============================================================================

;==============================================================================
; MiSysUpdatePos
;----------
; Updates Missile Position
; Y = Missile Index
;==============================================================================
MiSysUpdatePos: SUBROUTINE
    lda mADir,y
    sta MiSysDir
    and #$3F
    tax
    lda Atan2X,x
    sta MiSysDX
    lda Atan2Y,x
    sta MiSysDY

    ldx #1
; Update X
.addDouble
    lda mAxf,y
    bit MiSysDir
    bmi .subX
    clc
    adc MiSysDX
    sta mAxf,y
    lda mAx,y
    adc #0
    sta mAx,y
    jmp .addY
.subX
    sec
    sbc MiSysDX
    sta mAxf,y
    lda mAx,y
    sbc #0
    sta mAx,y

; Update Y
.addY
    lda mAyf,y
    bit MiSysDir
    bvs .subY
    clc
    adc MiSysDY
    sta mAyf,y
    lda mAy,y
    adc #0
    sta mAy,y
    jmp .checkAddY
.subY
    sec
    sbc MiSysDY
    sta mAyf,y
    lda mAy,y
    sbc #0
    sta mAy,y
.checkAddY
    dex
    bpl .addDouble
    rts

MiSystem: SUBROUTINE
    ldy #1
.loop 
    lda mAType,y
    beq .cont
    jsr MiSysUpdatePos
.cont
    dey
    bpl .loop
    
; Select Missile Draw
    ldy #1
    lda mAType
    beq .draw
    dey
    lda mAType+1
    beq .draw
    lda Frame
    and #1
    tay
    
.draw
    lda NUSIZ1_T
    ora #$20
    sta NUSIZ1_T
    lda #3
    sta wM1H

    lda mAx,y
    sta m1X
    tax
    lda mAy,y
    sta m1Y

    cpx #EnBoardXL
    bmi .kill
    cpx #EnBoardXR+1 + 3
    bpl .kill
    cmp #EnBoardYU+1 + 2
    bpl .kill
    cmp #EnBoardYD - 2
    bmi .kill

.rts
    rts
.kill
    lda #0
    sta mAType,y
    lda #$80
    sta m1Y
    rts