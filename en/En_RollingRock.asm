;==============================================================================
; mzxrules 2023
;==============================================================================
EN_ROLLING_ROCK_HasInit      = $04
EN_ROLLING_ROCK_HasAppeared  = $02
EN_ROLLING_ROCK_IsMoveChosen = $01

EN_ROLLING_ROCK_SetInit      = $04
EN_ROLLING_ROCK_SetAppeared  = $06
EN_ROLLING_ROCK_SetMoveChosen= $07

EN_ROLLING_ROCK_ANIM_length = #8
EN_ROLLING_ROCK_ANIM_go_up  = EN_ROLLING_ROCK_ANIM_length - 2

; set init -> set state HasInit
; wait to appear -> set state HasAppeared
; roll next move -> set state roll move

En_RollingRock: SUBROUTINE
    lda enState,x
    bne .Main
    jsr Random

    ora #$E0
    and EnRollingRock_TimerDelay,x
    sta enRollingRockTimer,x

    jsr Random
    tay
    and #$3
    sta enRollingRockSize,x

    lda #EN_ROLLING_ROCK_SetInit
    sta enState,x
    lda #$4F
    sta en0Y,x
    tya
    and #$1F
    clc
    adc #$20
    sta en0X,x
    rts

.Main
; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda #-8
    jsr UPDATE_PL_HEALTH
.endCheckHit

    lda enState,x
    ror
    bcs .DoMove
    ror
    bcs .SelectMove
    ror
    bcs .WaitAppear

.WaitAppear
    lda enRollingRockTimer,x
    cmp #1
    adc #0
    sta enRollingRockTimer,x
    bne .rts
.phase2
    lda #EN_ROLLING_ROCK_SetAppeared
    sta enState,x
    rts

.SelectMove
; test left bounds
    lda #$08
    cmp en0X,x
    bcc .rightCheck
    lda #1
    bpl .setDir
.rightCheck
    lda #$74-$10
    cmp en0X,x
    bcs .randomSelect
    lda #0
    bpl .setDir
.randomSelect
    jsr Random
    and #$1

.setDir
    sta enDir,x

    lda #EN_ROLLING_ROCK_ANIM_length
    sta enRollingRockTimer,x

    lda #EN_ROLLING_ROCK_SetMoveChosen
    sta enState,x
    rts

.DoMove

    dec en0Y,x
    bmi .reset

    dec enRollingRockTimer,x
    beq .FinishMove

    lda #EN_ROLLING_ROCK_ANIM_go_up
    cmp enRollingRockTimer,x
    bcs .DoMove_SkipYInc ; decrease y
    inc en0Y,x
    inc en0Y,x
.DoMove_SkipYInc
    lda enDir,x
    ror
    bcc .rockleft
.rockright
    inc en0X,x
    rts
.rockleft
    dec en0X,x
    rts


.FinishMove
    lda #$FE
    sta enRollingRockTimer,x

    lda #EN_ROLLING_ROCK_SetInit
    sta enState,x
    rts
.reset
    lda #0
    sta enState,x
.rts
    rts

EnRollingRock_LimitX:
    .byte #$F0, #$10

EnRollingRock_TimerDelay:
    .byte #$FF, #~$40