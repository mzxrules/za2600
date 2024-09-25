;==============================================================================
; mzxrules 2021
;==============================================================================
EN_OCTOROK_TYPE_RED = $0
EN_OCTOROK_TYPE_BLUE = $2
EN_OCTOROK_FIRING = $1

En_OctorokInitState:
    .byte #EN_OCTOROK_TYPE_RED | #EN_OCTOROK_FIRING
    .byte #EN_OCTOROK_TYPE_BLUE | #EN_OCTOROK_FIRING
En_OctorokInitHp:
    .byte 1-1, 2-1

En_OctorokBlue: SUBROUTINE
    ldy #1
    bpl .cont_octo_init

En_Octorok:
    ldy #0
.cont_octo_init
    lda enState,x
    ora En_OctorokInitState,y
    sta enState,x

    lda En_OctorokInitHp,y
    sta enHp,x

    lda #EN_OCTOROK_MAIN
    sta enType,x
    rts

En_OctorokMain: SUBROUTINE
; check damaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT
    lda enHp,x
    bpl .endCheckDamaged
    jmp EnSysEnDie
.endCheckDamaged

; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit

; Movement
    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT

; update EnMoveNX/NY
    lda en0X,x
    lsr
    lsr
    sta EnMoveNX
    lda en0Y,x
    lsr
    lsr
    sta EnMoveNY

; check recoil movement
    lda enState,x
    and #EN_ENEMY_MOVE_RECOIL
    beq .normal_movement
    jmp EnMove_Recoil

.normal_movement

; What's the plan, octo dad?


; update shoot timer
    lda enEnemyShootT,x
    cmp #1
    adc #0
    sta enEnemyShootT,x

    bne .skip_
    jsr Random
    and #$F8
    bne .skip_shoot
    lda #$80
.skip_shoot
    sta enEnemyShootT,x
; Toggle Walking/Firing Rock state, update shoot timer
    lda enState,x
    eor #EN_OCTOROK_FIRING
    sta enState,x
    ror ; #EN_OCTOROK_FIRING
    bcc .rts

    lda #$D0
    sta enEnemyShootT,x
    rts

.skip_

.test_fire_rock
    lda enState,x
    ror ; # EN_OCTOROK_FIRING
    bcc .walk

; Waiting to fire the rock
    lda enEnemyShootT,x
    cmp #$F0
    bne .end_test_fire_rock

.fire_rock
    lda enDir,x
    sta mi0Dir,x
    SET_A_miType #MI_SPAWN_ROCK, -4
    sta miType,x
    lda en0X,x
    sta mi0X,x
    lda en0Y,x
    sta mi0Y,x
.end_test_fire_rock
    rts


.walk

    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

    dec enEnemyStep,x
    bpl .seek_next
    jsr Random
    clc
    adc #4
    and #$1C
    sta enEnemyStep,x

    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_RandDir
    sty enDir,x
    bpl .move ; jmp

.seek_next
    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_RandDirIfBlocked
    sty enDir,x

.move
    lda enState,x
    and #EN_OCTOROK_TYPE_BLUE
    ora #1
    and Frame
    and #3
    beq .rts
    jmp EnMoveDir
.rts
    rts

    LOG_SIZE "En_Octorok", En_Octorok