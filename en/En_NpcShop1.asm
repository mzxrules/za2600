;==============================================================================
; mzxrules 2024
;==============================================================================
En_NpcShop1: SUBROUTINE
    lda #SEG_SH
    sta BANK_SLOT
    bit enState
    bvs .shop_end
    bmi .main

.init
    lda #0
    sta npcIncRupee
    sta npcDecRupee

    lda enState
    ora #NPC_INIT
    sta enState

    lda #1
    sta KernelId

.rts
    rts

.shop_end
    jmp NpcShop_UpdateRupees

.main
    lda roomFlags
    and #RF_EV_LOAD
    bne .skipSetPos
    lda #$30
    cmp plY
    bpl .skipSetPos
    sta plY
.skipSetPos

    jsr En_NpcShopGetSelection
    cpx #-1
    beq .rts
    lda itemRupees
    cmp #$40
    bcc .rts
.buyBombCap
    lda #$40
    sta npcDecRupee

    ldx #[$40 + 12]
    bit itemBombs
    bvc .setNewBombs
    ldx #[$C0 + 16]
.setNewBombs
    stx itemBombs
    ldy shopRoom
    lda rWorldRoomFlags,y
    ora #WRF_SV_ITEM_GET
    sta wWorldRoomFlags,y
    lda enState
    ora #NPC_ITEM_GOT
    sta enState
    lda #0
    sta KernelId
    rts