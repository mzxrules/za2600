;==============================================================================
; mzxrules 2023
;==============================================================================

HALT_VERTICAL_SYNC:
    jsr VERTICAL_SYNC

HALT_FROM_FLUTE:
    lda PHaltType
    cmp #HALT_TYPE_FLUTE
    bne .next
    jsr HaltFlute_OverscanTop
.next

    lda #SLOT_F4_AU1
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_F0_ENDRAW
    sta BANK_SLOT
    jsr EnDraw_Del

    lda #SLOT_F4_PAUSE_DRAW_WORLD
    sta BANK_SLOT

    jsr DRAW_PAUSE_WORLD

HALT_OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #36
    sta TIM64T ; 27 scanline timer
; reset world kernel vars
    lda #7
    sta wENH
    lda #0
    sta wNUSIZ1_T
    sta wREFP1_T

HALT_FROM_ENTER_LOC:
    lda PHaltType
    cmp #HALT_TYPE_ENTER_DUNG
    beq .do_ent
    cmp #HALT_TYPE_ENTER_CAVE
    bne .next
.do_ent
    jsr HaltEnterLoc_OverscanBottom
.next


HALT_OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne HALT_OVERSCAN_WAIT
    sta WSYNC
    jmp HALT_VERTICAL_SYNC


HALT_FLUTE_ENTRY: SUBROUTINE
    ldx #$FF
    txs
    lda Frame
    sta PFrame

    lda #HALT_TYPE_FLUTE
    sta PHaltType

    lda #19
    sta PAnim
    jmp HALT_FROM_FLUTE

HALT_ENTER_CAVE_ENTRY: SUBROUTINE
    lda #HALT_TYPE_ENTER_CAVE
    sta PHaltType
    bpl .entry_common

HALT_ENTER_DUNG_ENTRY:
    lda #HALT_TYPE_ENTER_DUNG
    sta PHaltType

.entry_common
    ldx #$FF
    txs
    lda Frame
    sta PFrame

    lda #MS_PLAY_NONE
    sta SeqFlags
    lda #SFX_ENTER
    sta SfxFlags

    lda #19
    sta PAnim
    jmp HALT_FROM_ENTER_LOC


HaltFlute_OverscanTop: SUBROUTINE
    lda PFrame
    clc
    adc #$7F
    cmp Frame
    beq .test_spawn_tornado
    rts

.test_spawn_tornado
    lda #-4
    sta plItemTimer
    lda itemTri
    beq .noTornado
    lda worldId
    bne .noTornado
    lda roomId
    bmi .noTornado

; update next dest if tornado was set
    ldx #-1
    lda plState3
    and #PS_ACTIVE_ITEM2
    tay
    cpy #PLAYER_FLUTE_FX
    bne .loop
    lda plItem2Dir
    and #7
    tax
.loop
    inx
    cpx #8
    bne .skipRollover
    ldx #0
.skipRollover
    lda Bit8,x
    and itemTri
    beq .loop
; x = next destination index

; If the timer is 0, spawn the tornado and set destination
    lda plItem2Time
    beq .spawn_tornado
; If timer is not zero, but a tornado is active, just update destination
    cpy #PLAYER_FLUTE_FX
    beq .update_dest
    bne .noTornado

.spawn_tornado
    lda #-85
    sta plItem2Time
    lda #0
    sta plm1X
    lda plY
    sta plm1Y
    lda #PLAYER_FLUTE_FX
    sta plState3

.update_dest
    stx plItem2Dir

.noTornado

    ldx #$FF
    txs
    lda #SLOT_F0_PL
    sta BANK_SLOT
    jmp MAIN_UNPAUSE


HaltEnterLoc_OverscanBottom: SUBROUTINE
    lda Frame
    sec
    sbc PFrame
    cmp #32
    bne .walk_in_anim
.enter_loc
    lda #$40
    sta plX
    lda #$10
    sta plY

    lda #7
    sta wPLH
    ldx #$FF
    txs
    lda #>OVERSCAN_WAIT
    pha
    lda #<OVERSCAN_WAIT-1
    pha
    lda PHaltType
    cmp #HALT_TYPE_ENTER_CAVE
    beq .MAIN_CAVE_ENT
    ;lda #SLOT_FC_MAIN
    jmp MAIN_DUNG_ENT
.MAIN_CAVE_ENT
    jmp MAIN_CAVE_ENT

.walk_in_anim
    cmp #0
    beq .skipAnim
    and #3
    bne .skipAnim
    ldy rPLH
    dey
    sty wPLH
    ldy plY
    iny
    sty plY
.skipAnim
    lda PHaltType
    cmp #HALT_TYPE_ENTER_CAVE
    beq .rts

.setup_mem
    lda Frame
    and #$07
    asl
    asl
    asl
    asl
    tax

    ldy #15

.mem_init_loop
.w0
    lda #SLOT_RW_F8_W0
    sta BANK_SLOT_RAM

    lda rWorldRoomENCount,x
    bne .w1
    lda #$FF
    sta wWorldRoomENCount,x

.w1
    lda #SLOT_RW_F8_W1
    sta BANK_SLOT_RAM
    lda #$FF
    sta wWorldRoomENCount,x

.w2
    lda #SLOT_RW_F8_W2
    sta BANK_SLOT_RAM
    lda #$FF
    sta wWorldRoomENCount,x
    inx
    dey
    bpl .mem_init_loop


    lda #SLOT_RW_F8_W0
    sta BANK_SLOT_RAM
.rts
    rts


