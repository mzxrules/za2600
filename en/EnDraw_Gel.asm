;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Gel: SUBROUTINE
    lda #0
    sta m1X
    sta enX

    ldy #CI_EN_BLACK
    jsr EnDraw_PosAndStunColor
    lda Frame

    lda #>SprE13
    sta enSpr+1
    lda #<SprE13
    sta enSpr

    lda enHp,x
    ror
    tay
    bcs .test_draw_second
    lda #$80
    sta enY

.test_draw_second
    tya
    ror
    bcc .apply_shake

    jsr EnDraw_Gel2
.apply_shake
    ldy enGelAnim,x
    tya
    and #$E0
    bne .skip_obj_en_Shake
    inc enX
.skip_obj_en_Shake
    tya
    and #$E
    bne .rts
    inc m1X
.rts
    rts