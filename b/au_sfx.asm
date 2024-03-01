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