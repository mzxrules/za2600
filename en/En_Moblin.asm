;==============================================================================
; mzxrules 2024
;==============================================================================
EN_MOBLIN_TYPE_RED = $0
EN_MOBLIN_TYPE_BLUE = $1
EN_MOBLIN_FIRING = $2

EN_ENEMY_MOBLIN_RED     = $0
EN_ENEMY_MOBLIN_BLUE    = $1
EN_ENEMY_LYNEL_RED      = $2
EN_ENEMY_LYNEL_BLUE     = $3

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
    lda #EN_MOBLIN_TYPE_RED | #EN_MOBLIN_FIRING
    sta enState,x
    lda #2-1
    sta enHp,x
    ldy #EN_ENEMY_MOBLIN_RED
    bpl .commmon_init

En_MoblinBlue:
    lda #EN_MOBLIN_TYPE_BLUE | #EN_MOBLIN_FIRING
    sta enState,x
    lda #3-1
    sta enHp,x
    ldy #EN_ENEMY_MOBLIN_BLUE

.commmon_init
    sty enEnemyType,x
    lda #EN_MOBLIN_MAIN
    sta enType,x
    rts