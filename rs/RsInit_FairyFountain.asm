;==============================================================================
; mzxrules 2023
;==============================================================================
RsInit_FairyFountain: SUBROUTINE
    lda #EN_GREAT_FAIRY
    sta enType
    lda #0
    sta enState
    sta roomEN
    rts