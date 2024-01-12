;==============================================================================
; mzxrules 2023
;==============================================================================
EnDraw_Keese: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY

    ldy enHp,x
    lda EnKeese_Disp-1,y
    sta wNUSIZ1_T

    lda Frame
    and #8
    lsr
    lsr
    lsr
    tay

    lda #>SprE24
    sta enSpr+1
    lda #<SprE24
    adc Mul8,y

    sta enSpr
    lda #COLOR_EN_BLACK
    sta wEnColor
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