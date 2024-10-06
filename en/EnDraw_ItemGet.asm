;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_ItemGet:
    lda plX
    sta enX
    lda plY
    clc
    adc #9
    sta enY

    ldy cdAType
    jmp EnItemDraw