;==============================================================================
; mzxrules 2025
;==============================================================================

En_BossGanon:
    lda #SLOT_RW_F0_BOSS4
    sta BANK_SLOT_RAM

    lda enState,x
    bmi .skipInit
    lda #$80
    sta enState,x

    lda #$20
    sta en0X,x
    lda #$30
    sta en0Y,x

.skipInit
    lda en0X,x
    sec
    adc #0
    cmp #$54
    bne .skip_repos
    lda #$10
.skip_repos
    sta en0X,x

    SET_A_miType #MI_RUN_BALL, -8
    sta miType,x

    ldy #$30
    sty mi0X,x
    sty mi0Y,x

    lda Frame
    and #$80
    sta wGanonShow

    rts