;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Tektite: SUBROUTINE
    lda enState,x
    and #1
    tay
    lda EnDraw_TektiteColors,y
    tay
    jsr EnDraw_PosAndStunColor

    lda #>SprE12
    sta enSpr+1


    lda enTektiteThink,x
    bpl .up
    cmp #$E0
    bcs .down
    and #$8
    bne .up


.down
    lda #<SprE13
    sta enSpr
    rts

.up lda #<SprE12
    sta enSpr
    rts

    LOG_SIZE "EnDraw_Tektite", EnDraw_Tektite