;==============================================================================
; mzxrules 2021
;==============================================================================

En_NpcMonster: SUBROUTINE
    bit roomFlags
    bmi .rts ; RF_EV_LOAD

    bit enState
    bmi .main
.init
    lda #[#NPC_INIT | #NPC_SPR_MONSTER]
    sta enState
    rts

.main
    bvc .main_continue
    inc npcTimer
    lda npcTimer
    cmp #$18
    bne .rts
.kill
    lda #0
    sta enType
    sta mesgId
    sta KernelId
    rts

.main_continue
    lda plState3
    and #PS_ACTIVE_ITEM2
    cmp #PLAYER_MEAT_FX
    bne En_Npc
    lda plItem2Time
    beq En_Npc

    lda #[#NPC_INIT | #NPC_ITEM_GOT | #NPC_SPR_MONSTER]
    sta enState

    lda #$E8
    sta plItem2Time

    lda #0
    sta mesgId
    sta KernelId
    sta roomRS

    ldy shopRoom
    lda rWorldRoomFlags,y
    ora #WRF_SV_ITEM_GET
    sta wWorldRoomFlags,y

    lda ITEMV_MEAT
    and #~ITEMF_MEAT
    sta ITEMV_MEAT

    lda #SEQ_SOLVE_DUR
    sta SeqSolveCur

En_Npc: ; SUBROUTINE
    lda roomFlags
    bmi .skipSetPos ; #RF_EV_LOAD
    lda #$30
    cmp plY
    bpl .skipSetPos
    sta plY
.skipSetPos
.rts
    rts