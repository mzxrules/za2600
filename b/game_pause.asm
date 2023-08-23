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
    lda #SLOT_PL
    sta BANK_SLOT
    jmp MAIN_UNPAUSE

.runPauseMenu

.runPauseUpdate
    lda #SLOT_AU_B
    sta BANK_SLOT
    jsr UpdateAudio

PAUSE_MAP_MEM_RESET:
    lda PAnim
    cmp #10
    bmi .endMapMemReset

; erase map for next cycle; do it here to avoid running out of cycles
; invert y cursor and setup for memory wipe

    lda #SLOT_RW_MAP
    sta BANK_SLOT_RAM

    lda #7
    sec
    sbc Frame
    and #7
    tax
    lda Pause_Mul5,x
    tax
    lda #0

; reset memory for row
ITER   SET 0
    REPEAT 5
    sta wMAP_0+ITER,x
    sta wMAP_1+ITER,x
    sta wMAP_2+ITER,x
    sta wMAP_3+ITER,x
    sta wMAP_4+ITER,x
    sta wMAP_5+ITER,x
ITER    SET ITER+1
    REPEND
.endMapMemReset

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


Pause_Menu_Map: SUBROUTINE
    lda #SLOT_RW_MAP
    sta BANK_SLOT_RAM
    ldx worldId
    ldy WorldBankOff,x
    lda WorldRom,y
    sta BANK_SLOT

; select line to update
    lda Frame
    and #7

; compute start room
    asl
    asl
    asl
    asl
    clc
    adc WorldMapXOff,x
    sta PMapRoom

; compute visited rooms and room links
    tay
    ldx #7
.visit_room_loop
    lda rRoomFlag,y
    and #RF_SV_VISIT
    clc
    beq .visit_room_false
    sec
.visit_room_false
    rol PMapRoomVisit

.room_link_loop
; NORTH
    clc
    lda rRoomFlag,y
    and #RF_SV_OPEN_N
    bne .path_n_true
    lda WORLD_T_PF1L,y
    and #%00000110
    bne .path_n_false
.path_n_true
    sec
.path_n_false
    rol PMapRoomN
; SOUTH
    clc
    lda rRoomFlag,y
    and #RF_SV_OPEN_S
    bne .path_s_true
    lda WORLD_T_PF1L,y
    and #%1000
    bne .path_s_false
    lda WORLD_T_PF2,y
    and #%0100
    bne .path_s_false
.path_s_true
    sec
.path_s_false
    rol PMapRoomS
; EAST
    clc
    lda rRoomFlag,y
    and #RF_SV_OPEN_E
    bne .path_e_true
    lda WORLD_T_PF2,y
    and #%1000
    bne .path_e_false
    lda WORLD_T_PF1R,y
    and #%0010
    bne .path_e_false
.path_e_true
    sec
.path_e_false
    rol PMapRoomE
; WEST
    clc
    lda rRoomFlag,y
    and #RF_SV_OPEN_W
    bne .path_w_true
    lda WORLD_T_PF1R,y
    and #%1100
    bne .path_w_false
.path_w_true
    sec
.path_w_false
    rol PMapRoomW

    iny
    dex
    bpl .visit_room_loop

; use map texture to only include current dungeon rooms
    lda #SLOT_SPR_HU
    sta BANK_SLOT

; invert y cursor and setup for memory wipe
    lda #7
    sec
    sbc Frame
    and #7
    sta PMapY
    tay

; Y == map y
    ldx worldId
    lda Mul8,x
    clc
    adc PMapY
    tax
    lda PMapRoomVisit
    and MINIMAP,x
    sta PMapRoomVisit

    ldx #3
.set_loop
    lda PMapRoomN,x
    and PMapRoomVisit
    sta PMapRoomN,x
    dex
    bpl .set_loop

.path_up_loop_end

    lda Pause_Mul5,y
    tay

    lda #SLOT_RW_MAP
    sta BANK_SLOT_RAM

    ; y = line * 5

    lda #SLOT_PAUSE_MAP
    sta BANK_SLOT
    jmp Pause_MapPlot


Pause_Mul5:
    .byte  0,  5, 10, 15
    .byte 20, 25, 30, 35, 40

WorldMapXOff:
    .byte 0, 0, 8, 8, 0, 0, 8, 0, 0, 8