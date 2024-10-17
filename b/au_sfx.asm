;==============================================================================
; mzxrules 2024
;==============================================================================

SfxPlDamage: SUBROUTINE
    ldx SfxCur
    cpx #7
    bpl SfxStop_l
    lda SfxDamageFreq,x
    sta AUDFT1
    lda #1
    sta AUDCT1
    lda #8
    sta AUDVT1
    rts
SfxDamageFreq:
    .byte  14, 11, 8, 12, 15, 18, 19

SfxEnter: SUBROUTINE
    lda SfxCur
    and #4
    beq .silent
    ldx #8
    stx AUDVT1
    stx AUDCT1
    ldx #5
    stx AUDFT1
.silent
    ldy SfxCur
    cpy #24
    bpl SfxStop_l
    rts

SfxFire: SUBROUTINE
    ldx SfxCur
    cpx #3
    bpl SfxStop_l
    lda #30
    sta AUDFT1
    lda #8
    sta AUDCT1
    lda #4
    sta AUDVT1
    rts

SfxStop_l:
    lda #0
    sta SfxFlags
    rts

SfxEnDamage: SUBROUTINE
    ldx SfxCur
    cpx #3
    bpl SfxStop_l
    lda #6
    sta AUDCT1
    lda #8
    sta AUDVT1
    lda SfxArrowFreq,x
    sta AUDFT1
    rts

SfxEnKill: SUBROUTINE
    ldx SfxCur
    cpx #10
    bpl SfxStop_l
    lda #3
    sta AUDCT1
    lda #8
    sta AUDVT1
    inx
    stx AUDFT1
    rts

SfxBossRoar: SUBROUTINE
    lda SfxCur
    cmp #32
    bpl SfxStop_l
    lsr
    lsr
    tax

    lda #3
    sta AUDCT1
    lda #8
    sta AUDVT1
    lda SfxBossRoarFPattern,x
    sta AUDFT1
    rts

SfxStab2: SUBROUTINE
STAB2_DELAY = #5
    ldy SfxCur
    cpy #STAB2_DELAY
    bmi .rts
    ldx #8
    stx AUDVT1
    stx AUDCT1
    lda SfxStab2Pattern-#STAB2_DELAY,y
    sta AUDFT1
    cpy #STAB2_DELAY + #11-#1
    bpl SfxStop_l
.rts
    rts

SfxStab2Pattern:
STAB2_BASE = 5
    .byte #STAB2_BASE+0, #STAB2_BASE+1, #STAB2_BASE+2, #STAB2_BASE+3
    .byte #STAB2_BASE+4, #STAB2_BASE+5, #STAB2_BASE+6, #STAB2_BASE+7
    .byte #STAB2_BASE+9, #STAB2_BASE+11, #STAB2_BASE+13

SfxBossRoarFPattern:
    .byte #27-#18, #25-#18, #22-#18, #22-#18, #22-#18, #24-#18, #26-#18, #30-#18
