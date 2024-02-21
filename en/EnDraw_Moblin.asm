;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Moblin: SUBROUTINE
    lda enState,x
    and #1
    tay
    lda EnDraw_MoblinColors,y
    tay
    jsr EnDraw_PosAndStunColor

    lda #>SprE4
    sta enSpr+1
    ldy enDir,x
    lda Mul8,y
    clc
    adc #<SprE4
    sta enSpr
    jmp EnDraw_Arrow