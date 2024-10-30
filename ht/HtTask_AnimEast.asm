;==============================================================================
; mzxrules 2024
;==============================================================================
HtTask_AnimEast: SUBROUTINE
    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    dec roomTimer
    bne .continue
    jmp Halt_IncTask

.continue
    ldx #1
    lda rHaltVState
    bmi .skip ; #HALT_VSTATE_TOP
    dex ; 0
.skip
    lda RSCR_EW_IndexEnd,x
    sta roomScrollTemp
    ldy RSCR_EW_IndexStart,x

.loop
    jsr RoomScroll_Left
    dey
    cpy roomScrollTemp
    bne .loop
.rts
    rts

HtTask_AnimWest: SUBROUTINE
    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    dec roomTimer
    bne .continue
    jmp Halt_IncTask

.continue
    ldx #1
    lda rHaltVState
    bmi .skip ; #HALT_VSTATE_TOP
    dex ; 0
.skip
    lda RSCR_EW_IndexEnd,x
    sta roomScrollTemp
    ldy RSCR_EW_IndexStart,x

.loop
    jsr RoomScroll_Right
    dey
    cpy roomScrollTemp
    bne .loop
.rts
    rts


RSCR_EW_IndexStart
    .byte #ROOM_PX_HEIGHT-1, #[#ROOM_PX_HEIGHT/2]-1
RSCR_EW_IndexEnd
    .byte #[#ROOM_PX_HEIGHT/2]-1, #0-1