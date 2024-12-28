;==============================================================================
; mzxrules 2024
;==============================================================================

PlDraw_Arrow: SUBROUTINE
    ldy plItemDir
    lda WeaponWidth_8px_thin,y
    sta wNUSIZ0_T
    lda WeaponHeight_8px_thin,y
    sta wM0H
    lda plm0X
    sta m0X
    lda plm0Y
    sta m0Y
    rts