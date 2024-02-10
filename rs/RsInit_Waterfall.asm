;==============================================================================
; mzxrules 2024
;==============================================================================

RsInit_Waterfall: SUBROUTINE
    lda #$7F
    sta wPF2Room + 12
    sta wPF2Room + 13
    lda #$40+1
    sta blX
    lda #$38
    sta blY
    lda #BL_PUSH_BLOCK_WATERFALL
    sta blType
    rts