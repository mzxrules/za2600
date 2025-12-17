;==============================================================================
; mzxrules 2025
;==============================================================================

Pause_Menu_Input: SUBROUTINE
; Update Fire button state flag
    lda plState
    cmp #INPT_FIRE_PREV
    ora #INPT_FIRE_PREV
    bit INPT4
    bmi .FireNotHit
    eor #$80
    sta plState
    jmp .endPause
.FireNotHit
    sta plState

    bit INPT1
    bmi .skipEndPause
.endPause
    lda #HALT_KERNEL_GAMEVIEW
    sta wHaltKernelId
    jmp Halt_TaskNext

.skipEndPause
    lda PAnim
    cmp #1
    adc #0
    sta PAnim
    beq .selectItem
    rts
.selectItem
    lda plState2
    and #PS_ACTIVE_ITEM
    sta PCursorLast

; Y = PCursor
    tay

    lda SWCHA
    and #$F0

.ContRight
    asl
    bcs .ContLeft
    bcc .pickRight ; jmp
.ContLeft
    asl
    bcs .ContDown
    bcc .pickLeft ; jmp
.ContDown
    asl
    bcs .ContUp
    jmp .pickRight
.ContUp
    asl
    bcs .rts
    jmp .pickLeft
    rts

.pickRight
    lda Pause_Menu_Item_Next+1,y
    jsr PickItemDel
    beq .pickRight
    bne .selectedItem

.pickLeft
    lda Pause_Menu_Item_Next-1,y
    jsr PickItemDel
    beq .pickLeft

.selectedItem
    sty PCursor
    lda plState2
    and #$F8
    ora PCursor
    sta plState2

    cpy PCursorLast
    beq .skipSfx
    lda #SFX_STAB
    sta SfxFlags
.skipSfx
    lda #-12
    sta PAnim
.rts
    rts


PickSword: SUBROUTINE
    lda ITEMV_SWORD3
    and #[ITEMF_SWORD3 | ITEMF_SWORD2 | ITEMF_SWORD1]
    rts

PickBomb: SUBROUTINE
    lda itemBombs
    and #$1F
    rts

PickBow: SUBROUTINE
    lda ITEMV_BOW
    ror ; #ITEMF_BOW
    bcc .skip
    and #[[ITEMF_ARROW | ITEMF_ARROW_SILVER]>>1]
    beq .skip
    lda itemRupees
    rts
.skip
    lda #0
    rts

PickCandle: SUBROUTINE
    lda ITEMV_CANDLE_RED
    and #[ITEMF_CANDLE_BLUE | ITEMF_CANDLE_RED]
    rts

PickFlute: SUBROUTINE
    lda ITEMV_FLUTE
    and #ITEMF_FLUTE
    rts

PickWand: SUBROUTINE
    lda ITEMV_WAND
    and #ITEMF_WAND
    rts

PickMeat: SUBROUTINE
    lda ITEMV_MEAT
    and #ITEMF_MEAT
    rts

PickRang: SUBROUTINE
    lda ITEMV_RANG
    and #ITEMF_RANG
    rts

PickItemDel:
    tay
    cpy PCursorLast
    beq .stopSearch
    lda PlItemPickH,y
    pha
    lda PlItemPickL,y
    pha
    rts
.stopSearch
    lda #1
    rts


    .byte 7
Pause_Menu_Item_Next:
    .byte 0, 1, 2, 3, 4, 5, 6, 7
    .byte 0