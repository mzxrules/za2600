;==============================================================================
; mzxrules 2024
;==============================================================================

EN_ENEMY_MOBLIN_RED     = $0
EN_ENEMY_MOBLIN_BLUE    = $1
EN_ENEMY_LYNEL_RED      = $2
EN_ENEMY_LYNEL_BLUE     = $3

EN_MOBLIN_TYPE_RED = $0
EN_MOBLIN_TYPE_BLUE = $1
EN_MOBLIN_FIRING = $2

EN_LYNEL_TYPE_RED = $0
EN_LYNEL_TYPE_BLUE = $1
EN_LYNEL_FIRING = #2

En_Enemy_MiType:
    BYTE_miType #MI_SPAWN_ARROW, -4
    BYTE_miType #MI_SPAWN_ARROW, -4
    BYTE_miType #MI_SPAWN_SWORD, -8
    BYTE_miType #MI_SPAWN_SWORD, -16

En_Enemy_Damage:
    .byte -4
    .byte -4
    .byte -8
    .byte -16

En_Moblin: SUBROUTINE
    ldy #EN_ENEMY_MOBLIN_RED
    bpl .commmon_init

En_MoblinBlue:
    ldy #EN_ENEMY_MOBLIN_BLUE
    bpl .commmon_init

En_LynelBlue:
    ldy #EN_ENEMY_LYNEL_BLUE
    bpl .commmon_init

En_Lynel:
    ldy #EN_ENEMY_LYNEL_RED

.commmon_init
    sty enEnemyType,x
    lda .Init_EnState,y
    sta enState,x
    lda .Init_Hp,y
    sta enHp,x
    lda .Init_EnType,y
    sta enType,x
    rts

.Init_EnType:
    .byte #EN_MOBLIN_MAIN
    .byte #EN_MOBLIN_MAIN
    .byte #EN_LYNEL_MAIN
    .byte #EN_LYNEL_MAIN

.Init_EnState:
    .byte #EN_MOBLIN_TYPE_RED  | #EN_MOBLIN_FIRING
    .byte #EN_MOBLIN_TYPE_BLUE | #EN_MOBLIN_FIRING
    .byte #EN_LYNEL_TYPE_RED   | #EN_LYNEL_FIRING
    .byte #EN_LYNEL_TYPE_BLUE  | #EN_LYNEL_FIRING

.Init_Hp:
    .byte #2-1
    .byte #3-1
    .byte #3-1
    .byte #6-1


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
    jmp EnSys_KillEnemyB
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