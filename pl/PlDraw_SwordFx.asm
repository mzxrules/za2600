;==============================================================================
; mzxrules 2024
;==============================================================================

PlDraw_SwordFx: SUBROUTINE
    ldy plItem2Dir
    lda WeaponWidth_4px_thick,y
    sta wNUSIZ0_T
    lda WeaponHeight_4px_thick,y
    sta wM0H
    ldx plm1X
    inx
    stx m0X
    ldx plm1Y
    inx
    stx m0Y
    rts