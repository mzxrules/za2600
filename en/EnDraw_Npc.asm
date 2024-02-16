;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Npc: SUBROUTINE
    lda mesgLength
    lsr
    sta mesgDY

    lda #$40
    sta enX
    lda #$38
    sta enY

    lda enState
    and #3
    tay
    ldx NpcColor,y

    lda npcTimer
    bmi .setColor
    and #$4
    beq .setColor
    ldx #COLOR_EN_BLACK
.setColor
    stx wEnColor
    lda NpcSpriteL,y
    sta enSpr
    lda NpcSpriteH,y
    sta enSpr+1
    rts

NpcSpriteH:
    .byte #>SprS0, #>SprS1, #>SprS2, #>SprE7
NpcSpriteL:
    .byte #<SprS0, #<SprS1, #<SprS2, #<SprE7

NpcColor:
    .byte #COLOR_EN_RED, #COLOR_EN_RED, #COLOR_EN_GREEN, #COLOR_EN_RED_L

    LOG_SIZE "EnDraw_NpcOldMan", EnDraw_NpcOldMan