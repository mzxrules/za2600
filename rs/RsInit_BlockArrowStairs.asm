;==============================================================================
; mzxrules 2026
;==============================================================================

RsInit_BlockArrowStairs: SUBROUTINE
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    ldx #$18
    stx blX
    ldx #$2C
    stx blY
    lda #BL_PUSH_BLOCK_ARROW
    sta blType
    rts
    LOG_SIZE "RsInit_BlockArrow", RsInit_BlockArrow