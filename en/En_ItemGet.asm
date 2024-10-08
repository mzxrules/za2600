;==============================================================================
; mzxrules 2022
;==============================================================================

En_ItemGet: SUBROUTINE
    lda cdItemType,x
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
    lda #EN_NONE
    sta cdItemType,x

    ldy #EN_NONE
    lda enState,x
    and #NPC_CAVE
    beq .set_non_npc
    ldy npcType
.set_non_npc
    sty enType,x
.rts
    rts

.triforce
    lda enState,x
    tay
    and #GI_EVENT_TRI
    bne .skipTriInit
    tya
    ora #GI_EVENT_TRI
    sta enState,x
    ldy #-40
    sty cdItemTimer,x
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
    lda cdItemTimer,x
    cmp #1
    adc #0
    sta cdItemTimer,x
    bmi .rts

    lda #RS_EXIT_DUNG2
    sta roomRS
    rts