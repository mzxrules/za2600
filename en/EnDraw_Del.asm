;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Del:
    ldx #0
    stx REFP1
    lda enType+1
    beq .skip
    lda Frame
    and #1
    tax
.skip
    ldy enType,x
    lda EntityDrawH,y
    pha
    lda EntityDrawL,y
    pha
    rts