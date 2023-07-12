;==============================================================================
; mzxrules 2022
;==============================================================================

PAUSE_ENTRY: SUBROUTINE
    ldx #$FF
    txs
    lda Frame
    sta PFrame
    lda #0
    sta PauseState
    lda #20
    sta PAnim
    jmp PAUSE_FROM_GAME

PAUSE_VERTICAL_SYNC:
    lda #2
    ldx #49
    sta WSYNC
    sta VSYNC
    stx TIM64T ; 41 scanline timer
    inc Frame
    sta WSYNC
    sta WSYNC
    lda #0      ; LoaD Accumulator with 0 so D1=0
    ; disable VDEL for HUD drawing
    sta VDELP0
    sta VDELP1
    ;sta PF0     ; blank the playfield
    ;sta PF1
    ;sta PF2
    ;sta GRP0    ; blanks player0 if VDELP0 was off
    ;sta GRP1    ; blanks player0 if VDELP0 was on, player1 if VDELP1 was off
    ;sta GRP0    ; blanks                           player1 if VDELP1 was on
    sta WSYNC
    sta VSYNC

PAUSE_FROM_GAME:
    ; Check game pause status
    bit PauseState
    bvs .runPauseMenu
    bpl .pauseAnimScrollDown
    bmi .pauseAnimScrollUp

.pauseAnimScrollDown
    dec PAnim
    bne .runPauseUpdate
    lda PauseState
    ora #$40
    sta PauseState
    jmp .runPauseMenu

.pauseAnimScrollUp
    inc PAnim
    lda PAnim
    cmp #20
    bne .runPauseUpdate
    lda #0
    sta PauseState
    lda #SLOT_PL
    sta BANK_SLOT
    jmp MAIN_UNPAUSE

.runPauseMenu

.runPauseUpdate
    lda #SLOT_AU_B
    sta BANK_SLOT
    jsr UpdateAudio

    bit PauseState
    bvs .skip_draw_en

    lda #SLOT_EN_D
    sta BANK_SLOT
    jsr EnDraw_Del

.skip_draw_en
    lda #SLOT_DRAW_PAUSE_WORLD
    sta BANK_SLOT
    bit PauseState
    bvs .draw_menu
    jsr DRAW_PAUSE_WORLD
    jmp PAUSE_OVERSCAN
.draw_menu
    jsr Pause_Menu_Input
    jsr DRAW_PAUSE_MENU


PAUSE_OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer
; reset world kernel vars
    lda #7
    sta wENH
    lda #0
    sta wNUSIZ1_T
    sta wREFP1_T


PAUSE_OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne PAUSE_OVERSCAN_WAIT

    jmp PAUSE_VERTICAL_SYNC

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
    lda #$80
    sta PauseState
    lda #0
    sta PAnim
    rts
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
    rts

PickBow: SUBROUTINE
    lda ITEMV_BOW
    and #ITEMF_BOW
    beq .rts
    lda ITEMV_ARROW
    and #[ITEMF_ARROW | ITEMF_ARROW_SILVER]
    beq .rts
    lda itemRupees
.rts
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
    lda ITEMV_FIRE_MAGIC
    and #ITEMF_FIRE_MAGIC
    rts

PickMeat: SUBROUTINE
    lda ITEMV_MEAT
    and #ITEMF_MEAT
    rts

PickPotion: SUBROUTINE
    lda ITEMV_POTION_RED
    and #[ITEMF_POTION_RED | ITEMF_POTION_BLUE | ITEMF_NOTE]
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


    INCLUDE "gen/PlItemPick.asm"
    .byte 7
Pause_Menu_Item_Next:
    .byte 0, 1, 2, 3, 4, 5, 6, 7
    .byte 0