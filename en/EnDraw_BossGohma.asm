;==============================================================================
; mzxrules 2021
;==============================================================================

EnDraw_BossGohma: SUBROUTINE

    ldy enGohmaCiColor
    jsr EnDraw_PosAndStunColor


    lda Frame
    and #1
    tay
    beq .skipSprShift
    clc
    lda enX
    adc #8
    sta enX
.skipSprShift

    lda Frame
    and #$10
    lsr
    lsr
    lsr
    lsr
    tax
    lda BossGohma_Reflect,x
    sta wREFP1_T
    txa
    eor BossGohma_SprFlip,y
    clc
    adc enState
    and #7
    tay

    lda BossGohma_SprL,y
    sta enSpr+1
    lda BossGohma_SprH,y
    sta enSpr

    lda #8
    sta wENH

    ldx #1
    lda miType,x
    ror
    bcs .draw_missile
    ldx #0
.draw_missile
    jmp EnDraw_SmallMissile


BossGohma_SprL:
    .byte #>SprGohma0, #>SprGohma1, #>SprGohma2, #>SprGohma3, #>SprGohma4, #>SprGohma5, #>SprGohma2, #>SprGohma3
BossGohma_SprH:
    .byte #<SprGohma0, #<SprGohma1, #<SprGohma2, #<SprGohma3, #<SprGohma4, #<SprGohma5, #<SprGohma2, #<SprGohma3

BossGohma_SprFlip:
    .byte 0, 1

BossGohma_Reflect:
    .byte 0, #%0001100

    LOG_SIZE "EnDraw_BossGohma", EnDraw_BossGohma