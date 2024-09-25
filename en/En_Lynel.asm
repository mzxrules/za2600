;==============================================================================
; mzxrules 2024
;==============================================================================
EN_LYNEL_TYPE_RED = $0
EN_LYNEL_TYPE_BLUE = $1
EN_LYNEL_FIRING = #2

En_LynelBlue: SUBROUTINE
    lda #EN_LYNEL_TYPE_BLUE | #EN_LYNEL_FIRING
    sta enState,x
    lda #6-1
    sta enHp,x
    ldy #EN_ENEMY_LYNEL_BLUE
    bpl .commmon_init

En_Lynel:
    lda #EN_LYNEL_TYPE_RED | #EN_LYNEL_FIRING
    sta enState,x
    lda #3-1
    sta enHp,x
    ldy #EN_ENEMY_LYNEL_RED

.commmon_init
    sty enEnemyType,x
    lda #EN_LYNEL_MAIN
    sta enType,x
    rts

En_LynelMain:
En_MoblinMain:
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
    ldy enEnemyType,x
    lda En_Enemy_Damage,y
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
    lda enEnemyShootT,x
    cmp #1
    adc #0
    sta enEnemyShootT,x

    bne .skip_toggle_fire_state

    jsr Random
    and #$F8
    bne .set_shootT
    lda #$80
.set_shootT
    sta enEnemyShootT,x

; Toggle Walking/Firing state, update shoot timer
    lda enState,x
    eor #EN_LYNEL_FIRING
    sta enState,x
    and #EN_LYNEL_FIRING
    beq .rts

    lda #$D0
    sta enEnemyShootT,x
    rts

.skip_toggle_fire_state

    lda enState,x
    and #EN_LYNEL_FIRING
    beq .walk

; Waiting to fire the sword
    lda enEnemyShootT,x
    cmp #$F0
    bne .end_test_fire_sword

.fire_sword
    lda enDir,x
    sta mi0Dir,x
    ldy enEnemyType,x
    lda En_Enemy_MiType,y
    sta miType,x
    lda en0X,x
    sta mi0X,x
    lda en0Y,x
    sta mi0Y,x
.end_test_fire_sword
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
    lda Frame
    and #1
    bne .rts
    jsr EnMoveDir
.rts
    rts
    LOG_SIZE "En_Lynel", En_Lynel