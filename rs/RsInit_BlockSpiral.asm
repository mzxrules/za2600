;==============================================================================
; mzxrules 2024
;==============================================================================

RsInit_BlockSpiral: SUBROUTINE
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    ldx #$28
    stx blX
    ldx #$40
    stx blY
    lda #BL_PUSH_BLOCK
    sta blType
    rts