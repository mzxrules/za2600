;==============================================================================
; mzxrules 2024
;==============================================================================

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
