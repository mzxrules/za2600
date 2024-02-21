;==============================================================================
; mzxrules 2024
;==============================================================================
EN_LEEVER_TYPE_RED = $0
EN_LEEVER_TYPE_BLUE = $40
EN_LEEVER_TYPE_MASK = $40


En_Leever: SUBROUTINE
    lda #EN_LEEVER_TYPE_RED
    sta enState,x
    bpl .commmon_init
En_LeeverBlue:
    lda #EN_LEEVER_TYPE_BLUE
    sta enState,x

.commmon_init
    lda #EN_LEEVER_MAIN
    sta enType,x
    rts
En_LeeverMain:
    lda enState,x
    and #~3
    sta enState,x
    lda Frame
    lsr
    lsr
    lsr
    lsr
    and #3
    cmp #3
    bne .set_mode
    lda #2
.set_mode
    ora enState,x
    sta enState,x
    rts