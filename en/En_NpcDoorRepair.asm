;==============================================================================
; mzxrules 2024
;==============================================================================
En_NpcDoorRepair: SUBROUTINE
    lda #SEG_SH
    sta BANK_SLOT
    bit enState
    bmi .end ; #NPC_INIT

    lda #NPC_INIT
    ora enState
    sta enState

    lda #$10
    sta npcDecRupee
    lda plState
    ora #PS_LOCK_ALL
    sta plState

    ldy shopRoom
    lda rRoomFlag,y
    ora #RF_SV_ITEM_GET
    sta wRoomFlag,y
    rts
.end
    lda npcDecRupee
    bne .skip_unlock
    lda plState
    and #~#PS_LOCK_ALL
    sta plState
.skip_unlock
    jmp NpcShop_UpdateRupees