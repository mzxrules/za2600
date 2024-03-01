;==============================================================================
; mzxrules 2023
;==============================================================================
EnDraw_Keese: SUBROUTINE
    ldy #CI_EN_BLACK
    jsr EnDraw_PosAndStunColor

    ldy enHp,x
    lda EnKeese_Disp-1,y
    sta wNUSIZ1_T

    lda #>SprE24
    sta enSpr+1
    lda Frame
    and #8
    clc
    adc #<SprE24
    sta enSpr
    rts

EnKeese_Disp:

; 001
; 010
    .byte #%10000 ; 1
    .byte #%10000 ; 1
; 011
    .byte #%10001 ; 2 close
; 100
    .byte #%10000 ; 1
; 101
    .byte #%10010 ; 2 far
; 110
    .byte #%10001 ; 2 close
; 111
    .byte #%10011 ; 3