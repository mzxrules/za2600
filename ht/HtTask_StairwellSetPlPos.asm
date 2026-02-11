;==============================================================================
; mzxrules 2026
;==============================================================================

HtTask_StairwellSetPlPos: SUBROUTINE
    lda #PL_DIR_D
    sta plDir

    ldy roomId
    bpl .enter_stairwell
.exit_stairwell
; TODO: implement more positions
    lda #$40
    sta plX
    lda #$10
    sta plY
    jmp Halt_TaskNext

.enter_stairwell
    lda #$44
    sta plY

; compare current roomId to roomEX the lower will be set to the
; left exit, while the higher will be set to the right.
;
; This handles both the stairwell and item cases. Then we just set
; roomIdNext to $FF if the roomEX is positive
    lda roomEX
    cmp roomId
    bcs .enter_stairwell_left

.enter_stairwell_right
    sty wSubRoomIdR
    sta wSubRoomIdL
    ldx #$70
    bpl .subworld_return_stairs ; jmp

.enter_stairwell_left
    sty wSubRoomIdL
    sta wSubRoomIdR
    ldx #$10

.subworld_return_stairs
    stx plX
    bit roomEX
    bmi .set_Gi
    lda #$FF
.set_Gi
    sta roomIdNext
    jmp Halt_TaskNext