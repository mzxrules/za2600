;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_BossDon: SUBROUTINE
    lda #COLOR_EN_YELLOW_L
    sta wEnColor

    lda enState,x
    ror
    bcc .draw_standard ; EN_BOSS_DON_ATE_BOMB

.draw_bombed
    lda enStun,x
    cmp #EN_BOSS_DON_ANIM_EAT_DETONATE
    bcc .draw_standard
    lda enDir,x
    and #3
    tay

    lda BossDon_SprL_Bomb,y
    sta enSpr
    jmp .setDonSpr


.draw_standard
    lda Frame
    asl
    asl
    asl

    lda enDir,x
    and #3
    bcc .skipOra
    ora #4
.skipOra
    tay

    lda BossDon_SprL,y
    sta enSpr

.setDonSpr
    lda #>SprDon0
    sta enSpr+1

    lda BossDon_REFP1,y
    sta wREFP1_T
    tya
    and #3
    tay

    lda BossDon_NUSIZ1,y
    sta wNUSIZ1_T

    lda #11
    sta wENH

    lda en0X,x
    clc
    adc BossDon_X,y
    sta enX
    lda en0Y,x
    sta enY

    lda #SLOT_F0_SPR2
    sta wWorldSprBank

    rts

BossDon_SprL_Bomb:
    .byte #<SprDon6, #<SprDon6, #<SprDon3, #<SprDon1

BossDon_SprL:
    .byte #<SprDon4, #<SprDon4, #<SprDon2, #<SprDon0
    .byte #<SprDon5, #<SprDon5, #<SprDon2, #<SprDon0

BossDon_REFP1:
    .byte #%0000, #%1000, %0000, %0000
    .byte #%0000, #%1000, %1000, %1000

BossDon_NUSIZ1:
    .byte #%101, #%101, #%00000, #%00000

BossDon_X:
    .byte #0, #-8, #0, #0
