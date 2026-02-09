;==============================================================================
; mzxrules 2024
;==============================================================================

; Overscan routine
HtTask_EnterSubworldCave: SUBROUTINE
    lda rOSFrameState
    bpl .continue ; #OS_FRAME_OVERSCAN
; on OS_FRAME_VBLANK, first frame
    ldx rHaltFrame
    inx
    cpx Frame
    bne .rts

    bit worldId
    bpl .rts
; stop music and play entrance sfx
    lda #MS_PLAY_NONE
    sta SeqFlags
    lda #SFX_ENTER
    sta SfxFlags
.rts
    rts
.continue
    lda Frame
    sec
    sbc rHaltFrame
    cmp #32
    beq .goto_subworld

.anim_enter_cave
    cmp #0
    beq .skipAnim
    and #3
    bne .skipAnim

    ldy rPLH
    dey
    sty wPLH

.walk_up_anim
    ldy plY
    iny
    sty plY
.skipAnim
    rts

.goto_subworld
; the cave entering animation is complete.
    lda #7
    sta wPLH

; Reset the stack and halt state
    ldx #$FF
    txs

subworld_in_overworld: SUBROUTINE
    lda #PL_DIR_U
    sta plDir

    lda #$40
    sta plX
    lda #$10
    sta plY

; assume roomEX is standard cave type
    ldx #HALT_TYPE_RSCR_NONE
    lda roomEX
    cmp #CV_LV_START
    bcc .enter_cave_subworld
.enter_dungeon
    adc [#LV_MIN - #CV_LV_START -1]
    sta wWorldIdNext

    lda #SLOT_FC_MAIN
    sta BANK_SLOT
    jsr SPAWN_AT_DEFAULT
    ldx #HALT_TYPE_GAME_START
.enter_cave_subworld
    stx wHaltType
    jmp MAIN_OVERSCAN_WAIT

/*
HtTask_SwapWorld_UpdateENCount: SUBROUTINE
    ; Task takes 8 frames
    lda Frame
    and #$07
    asl
    asl
    asl
    asl
    tax

    ldy #$10-1

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
    rts
*/