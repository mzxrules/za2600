;==============================================================================
; mzxrules 2026
;==============================================================================

RsInit_StairsEast: SUBROUTINE
    lda #$80
    sta blY

    ; Zero east door flags
    lda roomDoors
    and #$CF
    sta roomDoors
    rts