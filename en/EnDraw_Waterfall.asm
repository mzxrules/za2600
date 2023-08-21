;==============================================================================
; mzxrules 2023
;==============================================================================

En_Waterfall: = ALWAYS_RTS
EnDraw_Waterfall: SUBROUTINE
    ; draw sprite
    lda #$40
    sta enX
    lda roomId
    ldx #31 ; height
    ldy #$38 ; y
    cmp #$1A
    beq .pos1
.pos2
    ldx #23
    ldy #$8
.pos1
    sty enY
    stx wENH
    lda #>SprWaterfall0
    sta enSpr+1
    lda Frame
    ror
    and #$7
    bcs .alt
    adc #<SprWaterfall1-7
    sta enSpr
    lda #COLOR_EN_LIGHT_BLUE
    sta wEnColor
    rts

.alt ; carry set
    clc
    adc #5
    and #$7
    adc #<SprWaterfall1-7
    sta enSpr
    lda #COLOR_LIGHT_WATER
    sta wEnColor
    rts

    LOG_SIZE "EnDraw_Waterfall", EnDraw_Waterfall