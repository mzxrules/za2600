;==============================================================================
; mzxrules 2023
;==============================================================================
EN_GLOCK_HOMEX = $30
EN_GLOCK_HOMEY = $3E
EN_GLOCK_HOMEY2 = $3E-16+2
En_BossGlock: SUBROUTINE
    bit enState
    bmi .skipInit
    lda #$80
    sta enState
    lda #-1 ;#24-1
    sta enHp
    lda #EN_GLOCK_HOMEX
    sta en0X
    lda #EN_GLOCK_HOMEY
    sta en0Y
    jsr Random
    sta enGlockThink

    lda #0
    sta wPF2Room + 11
    sta wPF2Room + 12
    sta wPF2Room + 13
    sta wPF2Room + 14
    sta wPF2Room + 15
    sta wPF2Room + 16

    jmp EnSysEnDie



.splitHead
    lda #EN_BOSS_GLOCK_HEAD
    sta enType+1

    lda #EN_GLOCK_HOMEX
    sta en1X
    lda #EN_GLOCK_HOMEY-8
    sta en1Y
    lda #0
    sta enGlockHeadThink

    rts
.skipInit

    ;rts

    lda enState
    and #1
    bne .moveIn

.moveOUt
    dec en0Y
    lda en0Y
    cmp #EN_GLOCK_HOMEY2
    bne .skipAnim
    lda enState
    ora #1
    sta enState
    bmi .skipAnim ; jmp

.moveIn
    inc en0Y
    lda en0Y
    cmp #EN_GLOCK_HOMEY
    bne .skipAnim
    lda enState
    and #~1
    sta enState

    inc enGlockNeck
    lda enGlockNeck
    and #3
    sta enGlockNeck


.skipAnim

    lda #$80
    sta m1Y

    lda #EN_GLOCK_HOMEX + 4
    sta m1X

    lda #EN_GLOCK_HOMEY2
    sta m1Y

    rts

    lda Frame
    eor #$FF
    sec
    adc #0
    and #$3F
    sta m1Y
.noMissile
    rts