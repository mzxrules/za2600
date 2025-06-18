;==============================================================================
; mzxrules 2025
;==============================================================================

EnDraw_BossGanon: SUBROUTINE
    lda #>SprGanon0
    sta enSpr+1

    lda Frame
    and #3
    tay
    lda Frame
    and #$80
    ora EnDraw_BossGanon_SprOff,y

    sta enSpr

    lda #31
    sta wENH

    tya
    and #3
    tay

    clc
    lda en0X,x
    adc EnDraw_BossGanon_XOff,y
    sta enX

    lda en0Y,x
    sta enY

    lda #SLOT_F0_SPR2
    sta wWorldSprBank

    lda #$9A
    sta wEnColor

.rts
    rts

EnDraw_BossGanon_XOff:
    .byte $00, $08, $10, $18

EnDraw_BossGanon_SprOff:
    .byte $00, $20, $40, $60
    .byte $80, $A0, $C0, $E0