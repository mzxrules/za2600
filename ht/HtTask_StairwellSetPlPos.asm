;==============================================================================
; mzxrules 2026
;==============================================================================

HtTask_StairwellSetPlPos: SUBROUTINE
    lda #PL_DIR_D
    sta plDir

    lda roomId
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

    lda roomEX
    bmi .enter_stairwell_item_stairs
.enter_stairwell_stairwell
    cmp roomId
    bcs .enter_stairwell_left

.enter_stairwell_right
    sta wSubRoomIdL
    lda roomId
    sta wSubRoomIdR

    lda #$70
    sta plX

    lda #$FF
    sta roomIdNext
    jmp .subworld_return_stairs

.enter_stairwell_item_stairs
.enter_stairwell_left
    sta wSubRoomIdR
    lda roomId
    sta wSubRoomIdL

    lda #$10
    sta plX

    lda #$FF
    sta roomIdNext

.subworld_return_stairs
    jmp Halt_TaskNext