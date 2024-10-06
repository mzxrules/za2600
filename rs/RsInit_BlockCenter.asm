;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_BlockCenter: SUBROUTINE
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    ldx #$40
    stx blX
    ldx #$2C
    stx blY
    lda #BL_PUSH_BLOCK
    sta blType
    ldy #1
.loop
    lda rPF2Room+9,y
    and #$7F
    sta wPF2Room+9,y
    dey
    bpl .loop
    lda #RS_NONE
    sta roomRS
    rts
    LOG_SIZE "RsInit_BlockCenter", RsInit_BlockCenter