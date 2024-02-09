;==============================================================================
; mzxrules 2024
;==============================================================================
RsInit_BlockLeftStairs: SUBROUTINE
    lda #$80
    sta blY
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags

    lda #BL_PUSH_BLOCK_LEFT
    sta blType
.loop
    rts