;==============================================================================
; mzxrules 2022
;==============================================================================

En_ItemGet: SUBROUTINE
    lda cdAType
    cmp #GI_TRIFORCE
    beq .triforce
; Wait for sequence to complete
    lda SeqFlags
    and #$0F
    cmp #[#MS_PLAY_GI & $0F]
    beq .rts

; MS_PLAY_GI is over, resume play
    lda plState2
    and #~#PS_HOLD_ITEM
    sta plState2
    lda plState
    and #~#PS_LOCK_ALL
    sta plState
    ldx #EN_NONE
    stx cdAType

    ldx #EN_CLEAR_DROP
    lda enState
    and #NPC_CAVE
    beq .set_non_npc
    ldx npcType
.set_non_npc
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
    sty cdATimer
.skipTriInit
    lda plHealth
    cmp plHealthMax
    beq .skipHeal

    lda Frame
    ror
    lda #0
    bcs .end_tri_heal
    lda #SFX_PL_HEAL
    inc plHealth
.end_tri_heal
    sta SfxFlags
    rts
.skipHeal
    lda SeqFlags
    bne .rts ; MS_PLAY_NONE
    lda cdATimer
    cmp #1
    adc #0
    sta cdATimer
    bmi .rts

    lda #RS_EXIT_DUNG2
    sta roomRS
    rts