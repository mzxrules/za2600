;==============================================================================
; mzxrules 2024
;==============================================================================

; Overscan routine
HtTask_EnterSubworldStairs: SUBROUTINE
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
    cmp #2
    beq .goto_subworld
    rts

.goto_subworld
; reset stack
    ldx #$FF
    txs

    lda worldId
    bmi .subworld_in_overworld

.subworld_in_dungeon
    lda #HALT_TYPE_RSCR_STAIRS
    sta wHaltType
    jmp MAIN_OVERSCAN_WAIT

.subworld_in_overworld
    lda #HALT_TYPE_RSCR_NONE
    sta wHaltType
    jmp subworld_in_overworld
