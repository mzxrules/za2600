;==============================================================================
; mzxrules 2023
;==============================================================================
EnDraw_RollingRock: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY

    ldy enRollingRockSize,x
    lda EnDraw_RollingRockPattern,y
    sta wNUSIZ1_T
    lda #>SprRock0
    sta enSpr+1
    lda #<SprRock0
    sta enSpr
    lda #COLOR_WHITE
    sta wEnColor
    rts

EnDraw_RollingRockPattern:
    .byte #%10000 ; 1
    .byte #%10001 ; 2 close
    .byte #%10010 ; 2 far
    .byte #%10011 ; 3