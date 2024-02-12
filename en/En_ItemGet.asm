;==============================================================================
; mzxrules 2022
;==============================================================================

En_ItemGet: SUBROUTINE
    lda cdAType
    cmp #GI_TRIFORCE
    beq .triforce
    lda SeqFlags
    and #$0F
    cmp #[MS_PLAY_GI & $0F]
    beq .rts
    lda plState2
    and #~PS_HOLD_ITEM
    sta plState2
    lda plState
    and #~PS_LOCK_ALL
    sta plState
    ldx #EN_NONE
    stx cdAType

    ldx npcType
    lda enState
    and #GI_EVENT_CAVE
    bne .end
    ldx #EN_CLEAR_DROP
.end
    stx enType
.rts
    rts
.triforce
    lda #GI_EVENT_TRI
    bit enState
    bne .skipTriInit
    ora enState
    sta enState
    ldy #-40
    sty cdBType
.skipTriInit
    lda plHealth
    cmp plHealthMax
    beq .skipHeal
    lda #0
    sta SfxFlags
    lda Frame
    and #1
    bne .rts
    lda #SFX_PL_HEAL
    sta SfxFlags

    inc plHealth
    rts
.skipHeal
    lda SeqFlags
    bne .rts ; MS_PLAY_NONE
    lda cdBType
    cmp #1
    adc #0
    sta cdBType
    bmi .rts

    lda #RS_EXIT_DUNG2
    sta roomRS
    rts