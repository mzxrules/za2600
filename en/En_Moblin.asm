;==============================================================================
; mzxrules 2024
;==============================================================================
EN_MOBLIN_TYPE_RED = $0
EN_MOBLIN_TYPE_BLUE = $1
EN_MOBLIN_TYPE_MASK = $1

En_Moblin: SUBROUTINE
    lda #EN_MOBLIN_TYPE_RED
    sta enState,x
    bpl .commmon_init
En_MoblinBlue:
    lda #EN_MOBLIN_TYPE_BLUE
    sta enState,x

.commmon_init
    lda #EN_MOBLIN_MAIN
    sta enType,x
    rts
En_MoblinMain:
    rts