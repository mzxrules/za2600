;==============================================================================
; mzxrules 2023
;==============================================================================
RsInit_BlockPathStairs: SUBROUTINE
    lda #$80
    sta blY
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags

    lda #BL_PATH_PUSH_BLOCK
    sta blType
    rts