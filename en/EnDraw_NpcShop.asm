;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_NpcShop: SUBROUTINE
    ldy #$F0
    bit enState
    bvs .noDraw
EnDraw_NpcGame:
    lda enType,x
    sec
    sbc #EN_NPC_SHOP
    and #3
    tay
    lda NpcRupeeX,y
    sta enX
    lda NpcRupeeNUSIZ,y
    sta wNUSIZ1_T

    ldy #GI_RUPEE
    jsr EnDraw_Item
    jsr NpcUpdateShopMesg

    ldy #$28
.noDraw
    sty enY
    rts

NpcRupeeX:
    .byte $20 ; draw 3
    .byte $20 ; draw 3
    .byte $20 ; draw 2
    .byte $40 ; draw 1

NpcRupeeNUSIZ:
    .byte #%00110 ; draw 3
    .byte #%00110 ; draw 3
    .byte #%00100 ; draw 2
    .byte #%00000 ; draw 1

; Update shop price display digits
NpcUpdateShopMesg: SUBROUTINE
    ldx #2 ; loop iterator
    lda Frame
    ror
    bcs .tensDigit
.onesDigit
    lda shopPrice,x
    and #$0F
    tay
    lda MesgDigits,y
    sta mesgChar,x
    dex
    bpl .onesDigit
    rts

.tensDigit
    lda shopPrice,x
    lsr
    lsr
    lsr
    lsr
    tay
    lda MesgDigits,y
    sta mesgChar,x
    dex
    bpl .tensDigit
    rts
    LOG_SIZE "EnDraw_NpcShop", EnDraw_NpcShop