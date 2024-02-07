;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_NpcOldMan: SUBROUTINE
    ; Draw Routine
    lda #COLOR_EN_RED
    sta wEnColor
    lda #<SprS0
    sta enSpr
    lda #>SprS0
    sta enSpr+1
    rts


EnDraw_NpcMonster: SUBROUTINE
    ; Draw Routine
    ldx #COLOR_EN_RED_L
    lda enNpcMonsterTimer
    and #$4
    beq .setColor
    ldx #COLOR_EN_BLACK
.setColor
    stx wEnColor
    lda #<SprE7
    sta enSpr
    lda #>SprE7
    sta enSpr+1
    rts

    LOG_SIZE "EnDraw_NpcOldMan", EnDraw_NpcOldMan