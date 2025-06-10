;==============================================================================
; mzxrules 2024
;==============================================================================
EN_GORIYA_TYPE_RED  = $0
EN_GORIYA_TYPE_BLUE = $2
EN_GORIYA_FIRING    = $1

EN_GORIYA_RANG_TIME = $18 ; affects maximum distance thrown.

En_GoriyaInitState:
    .byte #EN_GORIYA_TYPE_RED | #EN_GORIYA_FIRING
    .byte #EN_GORIYA_TYPE_BLUE | #EN_GORIYA_FIRING
En_GoriyaInitHp:
    .byte #3-1, #5-1

En_GoriyaBlue: SUBROUTINE
    ldy #1
    bpl .cont_goriya_init

En_Goriya:
    ldy #0
.cont_goriya_init
    lda enState,x
    ora En_GoriyaInitState,y
    sta enState,x

    lda En_GoriyaInitHp,y
    sta enHp,x

    lda #EN_GORIYA_MAIN
    sta enType,x
    rts

En_GoriyaMain:
; check damaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT
    lda enHp,x
    bpl .endCheckDamaged
    jmp EnSys_KillEnemyB
.endCheckDamaged

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
    and #EN_GORIYA_FIRING
    bne .normal_movement

    lda enState,x
    and #EN_ENEMY_MOVE_RECOIL
    beq .normal_movement
    jmp EnMove_Recoil

.normal_movement

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
    eor #EN_GORIYA_FIRING
    sta enState,x
    ror ; #EN_GORIYA_FIRING
    bcc .rts

    lda #$C0 ; $20 delay to fire, $20 stall before moving again
    sta enEnemyShootT,x
    rts

.skip_

.test_fire_rang
    lda enState,x
    ror ; #EN_GORIYA_FIRING
    bcc .walk

; Waiting to fire the rang
    lda enEnemyShootT,x
    cmp #$E0 ; handles $20 delay to fire
    bne .end_test_fire_rang

.fire_rang
    lda enDir,x
    sta mi0Dir,x
    SET_A_miType #MI_SPAWN_RANG, -4
    sta miType,x
    lda en0X,x
    sta mi0X,x
    lda en0Y,x
    sta mi0Y,x
.end_test_fire_rang
.rts
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
    and #$F
    clc
    adc #2
    sta enEnemyStep,x

    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_NewDir
    sty enDir,x
    bpl .move ; jmp

.seek_next
    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_RandDirIfBlocked
    sty enDir,x
.move
    lda Frame
    and #1
    bne .rts
    jsr EnMoveDir
    rts