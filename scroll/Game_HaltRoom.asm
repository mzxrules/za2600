;==============================================================================
; mzxrules 2024
;==============================================================================

ROOMSCROLL_TIMER_EW = 64+1

;TOP_FRAME ;3 37 192 30
ROOMSCROLL_VERTICAL_SYNC: ; 3 SCANLINES
    jsr VERTICAL_SYNC

ROOMSCROLL_VERTICAL_BLANK: SUBROUTINE
    jsr HtTask_Run

    lda #SLOT_F4_AU1
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_F0_ENDRAW
    sta BANK_SLOT
    jsr EnDraw_Del

    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    lda <#KERNEL_SCROLL1
    sta wHaltKernelDraw
    lda >#KERNEL_SCROLL1
    sta wHaltKernelDraw+1

    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    jsr POSITION_SPRITES


ROOMSCROLL_OVERSCAN: SUBROUTINE
    sta WSYNC
    lda #2
    sta VBLANK
    lda #36
    sta TIM64T ; 30 scanline timer
    sta wHaltVState

    jsr HtTask_Run

ROOMSCROLL_OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne ROOMSCROLL_OVERSCAN_WAIT

    jmp ROOMSCROLL_VERTICAL_SYNC


ROOMSCROLL_HALT_START: SUBROUTINE
    ldx #$FF
    txs

    ldy rHaltType
    lda #0
    sta wHaltType

    lda HtTaskScriptIndex,y
    sta wHaltTask

    lda RoomScroll_Timer,y
    ldx RoomScroll_RoomDY,y
    sta roomTimer
    stx roomScrollDY
    jmp ROOMSCROLL_VERTICAL_BLANK


RoomScroll_Timer
    .byte -1
    .byte #ROOMSCROLL_TIMER_EW, #ROOMSCROLL_TIMER_EW, #ROOM_PX_HEIGHT, #ROOM_PX_HEIGHT

RoomScroll_RoomDY
    .byte #ROOM_PX_HEIGHT-1
    .byte #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT*2-1


HtTask_RoomScrollEnd:
    lda rHaltVState
    bmi .continue
    rts
.continue
    lda #%00110001
    sta CTRLPF
    lda #ROOM_PX_HEIGHT-1
    sta roomDY
    lda roomIdNext
    sta roomId

    lda #-18
    sta roomTimer
    ldx #$FF
    txs
    jmp MAIN_ROOMSCROLL


HtTask_LoadRoom: SUBROUTINE
    lda rHaltVState
    bpl .continue ; not #HALT_VSTATE_TOP
    rts
.continue
    lda #SLOT_F0_ROOM
    sta BANK_SLOT
    jsr LoadRoom
    lda #SLOT_F0_RS_INIT
    sta BANK_SLOT
    lda #SLOT_F4_RS_DEST
    sta BANK_SLOT
    jsr RsInit_Del

    lda worldId
    beq .skipRoomChecks
    lda #SLOT_F0_ROOM
    sta BANK_SLOT
    jsr UpdateDoors
.skipRoomChecks

    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT

    ldx #0
    bit rRoomColorFlags
    bvs .dark
    lda rRoomColorFlags
    and #$3F
    tax
.dark
    lda WorldColorsFg,x
    sta wFgColor
    lda WorldColorsBg,x
    sta wBgColor
    jmp Halt_IncTask
    ;rts

Halt_IncTask: SUBROUTINE
    ldx rHaltTask
    inx
    stx wHaltTask
    rts