;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_NpcShop: SUBROUTINE
    ldy #$F0
    bit enState
    bvs .noDraw
EnDraw_NpcGame:
    lda enType,x
    tay
    lda NpcRupeeNUSIZ-#EN_NPC_SHOP,y
    sta wNUSIZ1_T

    ldy #GI_RUPEE
    jsr EnItemDraw
    jsr NpcUpdateShopMesg

    lda #$20
    sta enX
    ldy #$28
.noDraw
    sty enY
    rts
NpcRupeeNUSIZ:
    .byte #%00110 ; draw 3
    .byte #%00110 ; draw 3
    .byte #%00100 ; draw 2

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