;==============================================================================
; mzxrules 2023
;==============================================================================
EnDraw_Appear: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY

    lda #COLOR_EN_WHITE
    sta wEnColor

    lda #>SprRock0
    sta enSpr+1
    lda #<SprRock0
    sta enSpr
    lda enType,x
    cmp #EN_APPEAR
    bne .rts

    lda enSysTimer,x
    and #%0010

    asl
    asl
    sta wREFP1_T

    lda enSysType,x
    cmp #EN_KEESE
    bne .rts
    lda #%10011
    sta wNUSIZ1_T
.rts
    rts