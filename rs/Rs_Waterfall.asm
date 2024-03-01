;==============================================================================
; mzxrules 2022
;==============================================================================
Rs_Waterfall: SUBROUTINE
    lda #EN_WATERFALL
    sta enType
    ldx #$40
    cpx plX
    bne .rts
    ldy #$38
    cpy plY
    bne .rts
    ldy #$30
    jmp RS_ENTER_CAVE
.rts
    rts