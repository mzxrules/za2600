;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_BlockDiamondStairs: SUBROUTINE
    ldx #$40
    stx blX
    lda #$3C
    sta blY

    lda #0
    sta wPF2Room + 13
    sta wPF2Room + 14

    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    lda #BL_PUSH_BLOCK
    sta blType
    rts