;==============================================================================
; mzxrules 2024
;==============================================================================

PlDraw_WandFx: SUBROUTINE
    lda #$20
    sta wNUSIZ0_T
    lda #3
    sta wM0H
    lda plm1X
    sta m0X
    lda plm1Y
    sta m0Y
    rts