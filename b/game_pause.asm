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
    jsr VERTICAL_SYNC

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

; Restore Frame, correcting audio timers
    lda PFrame
    tax
    sec
    sbc Frame
    sta Frame

    lda SeqTFrame
    clc
    adc Frame
    sta SeqTFrame

    lda SeqTFrame+1
    clc
    adc Frame
    sta SeqTFrame+1
    stx Frame

    lda #SLOT_F0_PL
    sta BANK_SLOT
    jmp MAIN_UNPAUSE

.runPauseMenu

; blink dungeon map position
    lda Frame
    clc
    adc #$3
    and #7
    sta PMapY
    lda roomId
    lsr
    lsr
    lsr
    lsr
    cmp PMapY
    bne .skipBlink
    ldy worldId
    lda roomId
    and #$F
    sec
    sbc WorldMapXOff,y
    cmp #8
    bcs .skipBlink
    tax
    ldy PMapY
    lda MapCurRoomOff,x
    clc
    adc Pause_InvertMul5,y
    tay

    lda #SLOT_RW_F0_DUNG_MAP
    sta BANK_SLOT_RAM
    lda rMAP_0,y
    eor MapCurRoomEor,x
    sta wMAP_0,y
.skipBlink

.runPauseUpdate
    lda #SLOT_F4_AU1
    sta BANK_SLOT
    jsr UpdateAudio

PAUSE_MAP_MEM_RESET:
    lda PAnim
    cmp #10
    bmi .endMapMemReset

; erase map for next cycle; do it here to avoid running out of cycles
; invert y cursor and setup for memory wipe

    lda #SLOT_RW_F0_DUNG_MAP
    sta BANK_SLOT_RAM

    lda Frame
    and #7
    tax
    ldy Pause_InvertMul5,x
    lda #0

; reset memory for row
ITER   SET 0
    REPEAT 5
    sta wMAP_0+ITER,y
    sta wMAP_1+ITER,y
    sta wMAP_2+ITER,y
    sta wMAP_3+ITER,y
    sta wMAP_4+ITER,y
    sta wMAP_5+ITER,y
ITER    SET ITER+1
    REPEND
.endMapMemReset

    bit PauseState
    bvs .skip_draw_en

    lda #SLOT_F0_ENDRAW
    sta BANK_SLOT
    jsr EnDraw_Del

.skip_draw_en
    lda #SLOT_F4_PAUSE_DRAW_WORLD
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

    lda #SLOT_F0_PAUSE_MENU_MAP
    sta BANK_SLOT
    jsr Pause_Menu_Map


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


    INCLUDE "gen/PlItemPick_DelLUT.asm"
    .byte 7
Pause_Menu_Item_Next:
    .byte 0, 1, 2, 3, 4, 5, 6, 7
    .byte 0


Pause_Invert:
    .byte 7, 6, 5, 4, 3, 2, 1, 0

Pause_InvertMul5:
    .byte 35, 30, 25, 20
    .byte 15, 10,  5,  0

WorldMapXOff:
    .byte 0, 0, 8, 8, 0, 0, 8, 0, 0, 8

MapCurRoomOff:
    .byte 0 * #PAUSE_MAP_HEIGHT + 2
    .byte 1 * #PAUSE_MAP_HEIGHT + 2
    .byte 2 * #PAUSE_MAP_HEIGHT + 2
    .byte 2 * #PAUSE_MAP_HEIGHT + 2

    .byte 3 * #PAUSE_MAP_HEIGHT + 2
    .byte 3 * #PAUSE_MAP_HEIGHT + 2
    .byte 4 * #PAUSE_MAP_HEIGHT + 2
    .byte 5 * #PAUSE_MAP_HEIGHT + 2

MapCurRoomEor:
    .byte $02, $10, $80, $04
    .byte $20, $01, $08, $40