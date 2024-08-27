;==============================================================================
; mzxrules 2021
;==============================================================================
    INCLUDE "kworld.asm"
    INCLUDE "c/kernel48.asm"

    ;align 256

    INCLUDE "spr/spr_nocontroller.asm"
    INCLUDE "spr/spr_titledemo.asm"

ENTRY: SUBROUTINE ; Address FC00
    CLEAN_START
; wipe ram
    ldy #3
.wipe_rambanks_loop
    sty BANK_SLOT_RAM
.wipeRam
    dex
    sta $F200,x
    sta $F300,x
    bne .wipeRam
    dey
    bpl .wipe_rambanks_loop

    sta BANK_SLOT ; load copy of bank to F000
    jmp ENTRY_INIT ; jump to F000 address space

.ENTRY_RAM_BANKS
    .byte #SLOT_RW_F8_W0, #SLOT_RW_F8_W1, #SLOT_RW_F8_W2

.ENTRY_SLOT_SPR
    .byte #SLOT_F0_SPR0, #SLOT_F0_SPR1, #SLOT_F0_SPR1

ENTRY_INIT:  ; Address F000
    ldy #SLOT_FC_MAIN
    sty BANK_SLOT

; initialize extended ram
    ldy #2 ; ram banks to init

.init_ram_loop
    lda .ENTRY_RAM_BANKS,y
    sta BANK_SLOT_RAM
    txa ; set A to 0

    ; kernel transfer
    ldx #KERNEL_LEN
.initWorldKernMem
    lda KERNEL_WORLD-1,x
    sta wKERNEL-1,x
    dex
    bne .initWorldKernMem

    lda .ENTRY_SLOT_SPR,y
    sta wWorldSprBank_DEFAULT

    ldx #127
    lda #$FF
.init_RoomENC
    sta wWorldRoomENCount,x
    dex
    bpl .init_RoomENC

    dey
    bpl .init_ram_loop

    ; kernel48 transfer
    ldy #SLOT_RW_F4_KERNEL48
    sty BANK_SLOT_RAM

    ldx #KERNEL48_LEN
.init48KernMem
    lda KERNEL48-1,x
    sta wKERNEL48-1,x
    dex
    bne .init48KernMem


ENTRY_KERNEL:
    ldx #$3
    stx roomTimer
    ldx #11
    stx roomDY

ENTRY_VERTICAL_SYNC: SUBROUTINE
    lda #2
    ldx #49
    sta WSYNC
    sta VSYNC
    stx TIM64T ; 41 scanline timer
    inc Frame

    lda Frame
    cmp #4
    bne .skipSetColor
    lda #COLOR_EN_TRIFORCE
    sta COLUP0
    sta COLUP1
.skipSetColor

    sta WSYNC
    sta WSYNC
    lda #0
    sta GRP0
    sta GRP1
    sta GRP0
    sta WSYNC
    sta VSYNC


.draw_48_prep
    sta WSYNC
    lda #$03            ; +2 (2)
    sta NUSIZ0          ; +3 (5)  Three copies close for P0 and P1
    sta NUSIZ1          ; +3 (8)
    SLEEP 11
    sta HMCLR           ; +3 (22)
    lda #$80            ; +2 (24)
    sta HMP0            ; +3 (27)
    lda #$90            ; +2 (29)
    sta HMP1            ; +3 (32)
    nop                 ; +2 (34)
    sta RESP0           ; +3 (37)
    sta RESP1

    sta WSYNC
    sta HMOVE

    lda #$01
    sta VDELP0
    sta VDELP1


    ldy #54
.preframe_delay
    dey
    sta WSYNC
    sta WSYNC
    cpy roomDY
    bne .preframe_delay
    sty PMapDrawTemp0

    bit roomFlags
    bmi .setup_title
    jsr ENTRY_SETUP_DRAW_NOINPUT
    jmp .cont
.setup_title
    jsr ENTRY_SETUP_TITLE

.cont
    sta WSYNC

    jsr rKERNEL48
    sta WSYNC

    ldy #70
.delay_frame
    sta WSYNC
    sta WSYNC
    dey
    bpl .delay_frame

ENTRY_POST_DRAW:

.check_state
    bit roomFlags
    bmi .update_title_timer

.input_test
    ldx #$3
    lda INPT1
    bmi .input_pass
    stx roomTimer
.input_pass
    dec roomTimer
    bne .verticalSync

    lda #$80
    sta roomFlags
    lda #$1 ; Display Delay $90
    sta roomTimer
    lda #13
    sta roomDY
.verticalSync
    jmp ENTRY_VERTICAL_SYNC

.update_title_timer
    dec roomTimer
    beq ENTRY_START_GAME
    jmp ENTRY_VERTICAL_SYNC

ENTRY_START_GAME:
    IFCONST ITEMS
.cheats
    lda #8
    sta itemKeys
    lda #$99
    sta itemRupees
    lda #$F0
    sta itemBombs
    lda #$FC
    sta itemFlags
    lda #$FF
    sta itemFlags+1
    sta itemFlags+2
    ENDIF

    lda #%00110001 ; ball size 8, reflect playfield
    sta CTRLPF
    sta VDELBL

    ; seed RNG
    ; lda INTIM
    ; sta Rand16+1
    ; eor #$FF
    sta Rand16

    ; set ball
    lda #$60
    sta blY

    ; set player stats
    lda #$18
    sta plHealthMax
    jsr RESPAWN
    IFCONST TESTPOS
    lda #0
    sta worldId
    lda #$0
    sta roomIdNext
    lda ITEMV_SWORD1
    ora #ITEMF_SWORD1
    sta ITEMV_SWORD1
    ENDIF

    jmp MAIN_ENTRY

ENTRY_SETUP_DRAW_NOINPUT:
    TEX48P RAMSEG_F4, SprNoController, 0
    TEX48P RAMSEG_F4, SprNoController, 1
    TEX48P RAMSEG_F4, SprNoController, 2
    TEX48P RAMSEG_F4, SprNoController, 3
    TEX48P RAMSEG_F4, SprNoController, 4
    TEX48P RAMSEG_F4, SprNoController, 5
    rts

ENTRY_SETUP_TITLE:
    TEX48P RAMSEG_F4, SprTitleDemo, 0
    TEX48P RAMSEG_F4, SprTitleDemo, 1
    TEX48P RAMSEG_F4, SprTitleDemo, 2
    TEX48P RAMSEG_F4, SprTitleDemo, 3
    TEX48P RAMSEG_F4, SprTitleDemo, 4
    TEX48P RAMSEG_F4, SprTitleDemo, 5
    rts