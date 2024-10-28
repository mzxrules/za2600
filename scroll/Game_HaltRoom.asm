;==============================================================================
; mzxrules 2024
;==============================================================================

ROOMSCROLL_TIMER_EW = 32

;TOP_FRAME ;3 37 192 30
ROOMSCROLL_VERTICAL_SYNC: ; 3 SCANLINES
    jsr VERTICAL_SYNC

ROOMSCROLL_VERTICAL_BLANK: SUBROUTINE
    jsr RoomScroll_Update

    lda #SLOT_F4_AU1
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    lda <#KERNEL_SCROLL1
    sta wHaltDrawKernel
    lda >#KERNEL_SCROLL1
    sta wHaltDrawKernel+1

    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    jsr POSITION_SPRITES


ROOMSCROLL_OVERSCAN: SUBROUTINE
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer

    jsr RoomScrollTask2

ROOMSCROLL_OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne ROOMSCROLL_OVERSCAN_WAIT

    jmp ROOMSCROLL_VERTICAL_SYNC


RoomScrollTask2: SUBROUTINE
    lda roomScrollTask2
    cmp #ROOMSCROLL_TASK__EAST
    beq .east
    cmp #ROOMSCROLL_TASK__WEST
    beq .west
    cmp #ROOMSCROLL_TASK__LOAD
    beq .load
    rts
.east
    jmp RoomScrollTask_AnimE2
.west
    jmp RoomScrollTask_AnimW2
.load
    jmp RoomScrollTask_Load2

ROOMSCROLL_HALT_START: SUBROUTINE
    ldx #$FF
    txs

    ldy rHaltType
    lda #0
    sta wHaltType
    dey
    bpl .select_scroll_dir


    tya ; -1
    ldx #ROOM_PX_HEIGHT-1
    bpl .set_scroll_vars ; jmp
.select_scroll_dir
    lda RoomScroll_Timer,y
    ldx RoomScroll_RoomDY,y

.set_scroll_vars
    sta roomTimer
    stx roomScrollDY
    sty roomScrollDir
    lda #0
    sta roomScrollTask
    sta roomScrollTask2
    jmp ROOMSCROLL_VERTICAL_BLANK


RoomScroll_Timer
    .byte #ROOMSCROLL_TIMER_EW, #ROOMSCROLL_TIMER_EW, #ROOM_PX_HEIGHT, #ROOM_PX_HEIGHT

RoomScroll_RoomDY
    .byte #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT*2-1


RoomScrollTask_Invalid: SUBROUTINE
    ldy roomScrollTask
    lda RoomScroll_TaskInvalid,y
    tay
    jmp RoomScroll_RunTask

RoomScrollTask_End:
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

RoomScroll_Update: SUBROUTINE
    lda roomScrollDir
    bmi RoomScrollTask_Invalid
    lda roomScrollTask
    asl
    asl
    ora roomScrollDir
    tax
    ldy RoomScroll_TaskMatrix,x

RoomScroll_RunTask:
    sty roomScrollTask2
    lda RoomScrollTaskBank,y
    sta BANK_SLOT
    lda RoomScrollTaskH,y
    pha
    lda RoomScrollTaskL,y
    pha
    rts

RoomScrollTask_Load2: SUBROUTINE
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
    inc roomScrollTask
RoomScrollTask_LoadRoom: SUBROUTINE
    rts

RoomScrollTask_AnimN: SUBROUTINE
; room travels down
    inc roomScrollDY
    dec roomTimer
    bne .rts
    inc roomScrollTask
.rts
    rts

RoomScrollTask_AnimS: SUBROUTINE
    dec roomScrollDY
    dec roomTimer
    bne .rts
    inc roomScrollTask
.rts
    rts

RoomScrollTask_AnimE2: SUBROUTINE
    lda #SLOT_F4_ROOMSCROLL_WE
    sta BANK_SLOT
    ldy #ROOM_PX_HEIGHT-1
.loop
    jsr RoomScroll_Left
    dey
    cpy #[#ROOM_PX_HEIGHT/2]-1
    bne .loop
.rts
    rts

RoomScrollTask_AnimE: SUBROUTINE
    lda #ROOMSCROLL_TIMER_EW
    cmp roomTimer
    beq .skip

    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    ldy #[#ROOM_PX_HEIGHT/2]-1
.loop
    jsr RoomScroll_Left
    dey
    bpl .loop
.skip
    dec roomTimer
    bne .rts
    inc roomScrollTask
.rts
    rts
RoomScrollTask_None:
    rts


RoomScrollTask_AnimW2: SUBROUTINE
    lda #SLOT_F4_ROOMSCROLL_WE
    sta BANK_SLOT
    ldy #ROOM_PX_HEIGHT-1
.loop
    jsr RoomScroll_Right
    dey
    cpy #[#ROOM_PX_HEIGHT/2]-1
    bne .loop
.rts
    rts


RoomScrollTask_AnimW: SUBROUTINE
    lda #ROOMSCROLL_TIMER_EW
    cmp roomTimer
    beq .skip

    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    ldy #[#ROOM_PX_HEIGHT/2]-1
.loop
    jsr RoomScroll_Right
    dey
    bpl .loop
.skip
    dec roomTimer
    bne .rts
    inc roomScrollTask
.rts
    rts
