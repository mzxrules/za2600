;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_BossAqua: SUBROUTINE
    lda Frame
    and #1
    tax
    lda en0X
    sta enX
    sec
    lda en0Y
    sbc #18-8
    sta enY

    txa
    ror
    bcc .skipSprShift
    lda enX
    adc #8-1
    sta enX
.skipSprShift
    txa
    ora enState
    and #3
    tay

    lda BossAqua_SprL,y
    sta enSpr+1
    lda BossAqua_SprH,y
    sta enSpr

    lda enStun
    asl
    asl
    adc #COLOR_EN_GREEN
    sta wEnColor
    lda #18-1
    sta wENH
    jmp EnDraw_SmallMissile

BossAqua_SprL:
    .byte #>SprAqua0, #>SprAqua2, #>SprAqua1, #>SprAqua2

BossAqua_SprH:
    .byte #<SprAqua0, #<SprAqua2, #<SprAqua1, #<SprAqua2