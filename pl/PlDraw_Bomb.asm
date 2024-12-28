;==============================================================================
; mzxrules 2024
;==============================================================================

PlDraw_Bomb: SUBROUTINE
    lda plm0Y
    bmi .draw_initial
    cpy #ITEM_ANIM_BOMB_DETONATE
    bmi .draw_initial

.drawBombAnimation
    bne .skipDetonateEffect
    lda #SFX_BOMB
    sta SfxFlags

.skipDetonateEffect
    lda #7
    sta wM0H
    lda #$30
    sta wNUSIZ0_T

    clc
    lda BombAnimDeltaX-$100,y
    adc plm0X
    sta m0X
    clc
    lda BombAnimDeltaY-$100,y
    adc plm0Y
    sta m0Y
    rts
.draw_initial

; Initial Animation state
    lda #$20
    sta wNUSIZ0_T
    lda #3
    sta wM0H
    lda plm0X
    sta m0X
    lda plm0Y
    sta m0Y
    rts

    .byte -2,  4, -8, 8, -8, 4,  4, -8, 8, -8, 4
BombAnimDeltaX:
    .byte -2, -4,  8, 0, -8, 4, -4,  8, 0, -8, 4
BombAnimDeltaY: