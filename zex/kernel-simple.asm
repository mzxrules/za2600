
KERNEL_SIMPLE: SUBROUTINE
; y = boardHeight
; Player
    lda #7 ;player height
    dcp plDY
    bcs .DrawP0
    lda #0
    .byte $2C ; BIT compare hack to skip 2 byte op

.DrawP0:
    lda (plSpr),y
    sta GRP0
    sta WSYNC
; Playfield
    tya
    lsr
    lsr
    tax

    lda PF1Room0,x
    sta PF1
    lda PF2Room0,x
    sta PF2

    dey
    sta WSYNC
    bne KERNEL_SIMPLE
