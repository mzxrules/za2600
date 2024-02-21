;==============================================================================
; mzxrules 2024
;==============================================================================
EN_TEKTITE_TYPE_RED = $0
EN_TEKTITE_TYPE_BLUE = $1
EN_TEKTITE_TYPE_MASK = $1


En_Tektite:
    lda #EN_TEKTITE_TYPE_RED
    sta enState,x
    bpl .commmon_init
En_TektiteBlue:
    lda #EN_TEKTITE_TYPE_BLUE
    sta enState,x

.commmon_init
    lda #EN_TEKTITE_MAIN
    sta enType,x
    rts

En_TektiteMain:
    lda enState,x
    and #~2
    sta enState,x

    lda Frame
    lsr
    lsr
    lsr
    and #2
    ora enState,x
    sta enState,x
    rts