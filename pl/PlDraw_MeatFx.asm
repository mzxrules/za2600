;==============================================================================
; mzxrules 2024
;==============================================================================

PlDraw_MeatFx: SUBROUTINE
    lda plItem2Time
    cmp #$F0
    bcc .drawNormal
    and #$4
    bne .drawNormal
    jmp PlDraw_None
.drawNormal
    lda #$20
    sta wNUSIZ0_T
    lda #2
    sta wM0H
    lda plm1X
    sta m0X
    lda plm1Y
    sta m0Y
    rts