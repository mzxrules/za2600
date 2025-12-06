;==============================================================================
; mzxrules 2024
;==============================================================================

; Overscan routine
HtTask_EnterLoc: SUBROUTINE
    lda #HALT_KERNEL_PAUSE_WORLD
    sta wHaltKernelId
    lda rOSFrameState
    bpl .continue ; #OS_FRAME_OVERSCAN
    ldx rHaltFrame
    inx
    cpx Frame
    bne .rts_2

    lda #MS_PLAY_NONE
    sta SeqFlags
    lda #SFX_ENTER
    sta SfxFlags

.rts_2
    rts
.continue
    lda Frame
    sec
    sbc rHaltFrame
    cmp #32
    bne .enter_anim
.enter_loc
    lda #$40
    sta plX
    lda #$10
    sta plY

    lda #7
    sta wPLH
; Reset the stack
    ldx #$FF
    txs
; Push return address of OVERSCAN_WAIT
    lda #>OVERSCAN_WAIT
    pha
    lda #<OVERSCAN_WAIT-1
    pha
    lda rHaltType
    inx ; #0
    stx wHaltType
    cmp #HALT_TYPE_ENTER_CAVE
    beq .MAIN_CAVE_ENT
    jmp MAIN_DUNG_ENT
.MAIN_CAVE_ENT
    jmp MAIN_CAVE_ENT

.enter_anim
    cmp #0
    beq .skipAnim
    and #3
    bne .skipAnim

    ldy rPLH
    dey
    sty wPLH

    ldx roomRS
    cpx #RS_ENT_DUNG_STAIRS
    beq .walk_down_anim

.walk_up_anim
    ldy plY
    iny
    sty plY
.walk_down_anim
.skipAnim
    lda rHaltType
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
.rts
    rts


