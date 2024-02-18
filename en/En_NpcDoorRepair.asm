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
    lda rWorldRoomFlags,y
    ora #WRF_SV_ITEM_GET
    sta wWorldRoomFlags,y
    rts
.end
    lda npcDecRupee
    bne .skip_unlock
    lda plState
    and #~#PS_LOCK_ALL
    sta plState
.skip_unlock
    jmp NpcShop_UpdateRupees