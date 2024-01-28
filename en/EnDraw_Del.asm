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
    lda EnDrawH,y
    pha
    lda EnDrawL,y
    pha
    lda EnDraw_BankLUT,y
    sta BANK_SLOT
    lda plState2
    and #~EN_LAST_DRAWN
    ora EnDraw_LastDrawn,x
    sta plState2
    rts
EnDraw_LastDrawn:
    .byte $00, #EN_LAST_DRAWN