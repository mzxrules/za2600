;==============================================================================
; mzxrules 2021
;==============================================================================

En_NpcOldMan:
    lda #$40
    sta enX
    lda #$38
    sta enY

    lda roomFlags
    and #RF_EV_LOAD
    bne .skipSetPos
    lda #$30
    cmp plY
    bpl .skipSetPos
    sta plY
.skipSetPos
    rts