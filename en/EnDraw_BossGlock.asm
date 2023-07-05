;==============================================================================
; mzxrules 2023
;==============================================================================
EnDraw_BossGlock: SUBROUTINE
    ldx en0X
    stx enX
    lda en0Y
    sta enY

    ldy enGlockNeck
    lda BossGlockHead,y
    sta wNUSIZ1_T
    lda #>SprE22
    sta enSpr+1
    lda #<SprE22
    sta enSpr
    lda #COLOR_EN_GREEN
    sta wEnColor


    lda #EN_GLOCK_HOMEY
    sec
    sbc enY
    ;clc
    ;adc #7
    sta wENH

    lda #1
    sta wM1H

    rts

BossGlockHead:
    .byte #%10000 ; 1
    .byte #%10001 ; 2 close
    .byte #%10010 ; 2 far
    .byte #%10011 ; 3