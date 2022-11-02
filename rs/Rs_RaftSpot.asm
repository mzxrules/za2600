;==============================================================================
; mzxrules 2021
;==============================================================================
Rs_RaftSpot: SUBROUTINE
    lda plState
    and #$20
    bne .fixPos
; If item not obtained
    lda #ITEMF_RAFT
    and ITEMV_RAFT
    beq .rts
; If not touching water surface
    bit CXP0FB
    bpl .rts
    ldy plY
    cpy #$40
    bne .rts
    ldx plX
    cpx #$40
    bne .rts
    iny
    sty plY
    lda #PL_DIR_U
    sta plDir
    lda plState
    ora #$22
    sta plState
    lda #SFX_SURF
    sta SfxFlags
.fixPos
    lda #$40
    sta plX
.rts
    rts