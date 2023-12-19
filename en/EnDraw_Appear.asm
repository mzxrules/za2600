;==============================================================================
; mzxrules 2023
;==============================================================================
EnDraw_Appear: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY

    lda #COLOR_WHITE
    sta wEnColor

    lda #>SprRock0
    sta enSpr+1

    lda enSysTimer,x
    and #2

    beq .setSpr
    lda #<SprRock0

.setSpr
    sta enSpr

    lda enSysType,x
    cmp #EN_KEESE
    bne .rts
    lda #%10011
    sta wNUSIZ1_T
.rts
    rts