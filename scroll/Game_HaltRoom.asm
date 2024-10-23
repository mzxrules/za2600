;==============================================================================
; mzxrules 2024
;==============================================================================

; always.asm hook
MAIN_ROOMSCROLL: BHA_BANK_JMP #SLOT_FC_MAIN, ROOMSCROLL_RETURN

ROOMSCROLL_TIMER_EW = 32

KERNEL_SCROLL1:  ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_SCROLL1
    sta VBLANK

    lda #%00110000  ; ball size 8, standard playfield
    sta CTRLPF

    ldy #79 ; #192
KERNEL_SCROLL1_LOOP1: SUBROUTINE ;-59
    REPEAT 2
    sta WSYNC
    ldx roomDY
    lda #$FF
    sta PF0
    lda rPF1_0A,x
    sta PF1
    lda rPF2_0A,x
    sta PF2

    sleep 8

    lda rPF0_1A,x
    sta PF0
    nop
    lda rPF1_1A,x
    sta PF1
    lda rPF2_1A,x
    sta PF2
    REPEND

    tya
    and #3
    beq .PFDec  ; 2/3
    .byte $2C   ; 4-5
.PFDec
    dec roomDY  ; 5
    dey
    bpl KERNEL_SCROLL1_LOOP1
    sta WSYNC
    iny
    sty PF0
    sty PF1
    sty PF2

    ldy #192 - 160 - 1
KERNEL_SCROLL1_LOOP2
    sta WSYNC
    dey
    bne KERNEL_SCROLL1_LOOP2
    rts

;TOP_FRAME ;3 37 192 30
ROOMSCROLL_VERTICAL_SYNC: ; 3 SCANLINES
    lda #2
    ldx #49
    sta WSYNC
    sta VSYNC
    stx TIM64T ; 41 scanline timer
    inc Frame
    sta WSYNC
    sta WSYNC
    ;lda #%00110001  ; ball size 8, mirrored playfield
    ;sta CTRLPF
    lda #0      ; LoaD Accumulator with 0 so D1=0
    sta PF0     ; blank the playfield
    sta PF1
    sta PF2
    sta GRP0    ; blanks player0 if VDELP0 was off
    sta GRP1    ; blanks player0 if VDELP0 was on, player1 if VDELP1 was off
    sta GRP0    ; blanks                           player1 if VDELP1 was on
    sta WSYNC
    sta VSYNC


ROOMSCROLL_VERTICAL_BLANK: SUBROUTINE

    jsr RoomScroll_Update
    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM
    jsr KERNEL_SCROLL1


ROOMSCROLL_OVERSCAN: SUBROUTINE
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer

    jsr RoomScrollTask_AnimW2

ROOMSCROLL_OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne ROOMSCROLL_OVERSCAN_WAIT

    jmp ROOMSCROLL_VERTICAL_SYNC


ROOMSCROLL_HALT_START: SUBROUTINE
    ldx #$FF
    txs

; Set scroll Direction:
    ldy #3
    lda roomIdNext
    sec
    sbc roomId
.scroll_dir_check_loop
    cmp RoomScroll_DirCheck,y
    beq .select_scroll_dir
    dey
    bpl .scroll_dir_check_loop
    tya ; -1
    ldx #ROOM_PX_HEIGHT-1
    bmi .set_scroll_vars
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


RoomScroll_DirCheck:
; E, W, N, S
    .byte #$01, #$FF, #$F0, #$10

RoomScroll_Timer
    .byte #ROOMSCROLL_TIMER_EW, #ROOMSCROLL_TIMER_EW, #ROOM_PX_HEIGHT, #ROOM_PX_HEIGHT

RoomScroll_RoomDY
    .byte #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT*2-1


RoomScrollTask_Invalid: SUBROUTINE
    lda #SLOT_F0_ROOM
    sta BANK_SLOT
    jsr LoadRoom

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

RoomScroll_Update:
    lda roomScrollDY
    sta roomDY

    lda roomScrollDir
    bmi RoomScrollTask_Invalid
    lda roomScrollTask
    asl
    asl
    ora roomScrollDir
    tax
    ldy RoomScroll_TaskMatrix,x
    sty roomScrollTask2

RoomScrollTask:
    lda RoomScrollTaskBank,y
    sta BANK_SLOT
    lda RoomScrollTaskH,y
    pha
    lda RoomScrollTaskL,y
    pha
    rts


RoomScrollTask_LoadRoom: SUBROUTINE
    inc roomScrollTask
    jmp LoadRoom


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

RoomScrollTask_AnimE: SUBROUTINE
    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM
; Room travels left
    ldy #ROOM_PX_HEIGHT-1
.loop
    clc

; RoomB
    lda rPF2_1B,y
    ror
    sta wPF2_1B,y

    lda rPF1_1B,y
    rol
    sta wPF1_1B,y

    lda rPF0_1B,y
    ror
    sta wPF0_1B,y
    and #%1000
    cmp #%1000

    lda rPF2_0B,y
    ror
    sta wPF2_0B,y

    lda rPF1_0B,y
    rol
    sta wPF1_0B,y

; get carry
    rol
    and #1
    tax
    sec

; RoomA
    lda rPF2_1A,y
    ror
    and .PF2_carry_mask,x
    sta wPF2_1A,y

    lda rPF1_1A,y
    rol
    sta wPF1_1A,y

    lda rPF0_1A,y
    ror
    sta wPF0_1A,y
    and #%1000
    cmp #%1000

    lda rPF2_0A,y
    ror
    sta wPF2_0A,y

    lda rPF1_0A,y
    rol
    sta wPF1_0A,y


    dey
    bpl .loop

    dec roomTimer
    bne .rts
    inc roomScrollTask
.rts
    rts

.PF2_carry_mask
    .byte  #$F7,  #$FF


RoomScrollTask_AnimW2: SUBROUTINE
    lda roomScrollTask2
    cmp #ROOMSCROLL_TASK__WEST
    bne .rts
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


RoomScroll_Right: SUBROUTINE
    clc

; RoomB
    lda rPF1_0B,y
    ror
    sta wPF1_0B,y

    lda rPF2_0B,y
    rol
    sta wPF2_0B,y

; get carry
    rol
    and #1
    tax
    sec

    lda rPF0_1B,y
    rol
    and .PF0_carry_mask,x
    sta wPF0_1B,y


    lda rPF1_1B,y
    ror
    sta wPF1_1B,y

    lda rPF2_1B,y
    rol
    sta wPF2_1B,y
    and #%10000
    cmp #%10000

; RoomA

    lda rPF1_0A,y
    ror
    sta wPF1_0A,y

    lda rPF2_0A,y
    rol
    sta wPF2_0A,y


; get carry
    rol
    and #1
    tax
    sec

    lda rPF0_1A,y
    rol
    and .PF0_carry_mask,x
    sta wPF0_1A,y

    lda rPF1_1A,y
    ror
    sta wPF1_1A,y

    lda rPF2_1A,y
    rol
    ora #$F0
    sta wPF2_1A,y
    rts

.PF0_carry_mask
    .byte  #$EF,  #$FF