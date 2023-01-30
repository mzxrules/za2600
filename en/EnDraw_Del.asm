;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Del:
    lda #0
    sta REFP1
    ldx enType
    lda EntityDrawH,x
    pha
    lda EntityDrawL,x
    pha
    rts