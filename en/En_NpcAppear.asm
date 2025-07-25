;==============================================================================
; mzxrules 2024
;==============================================================================

En_NpcAppear: SUBROUTINE
    bit enState
    bpl .init

.main
    lda npcTimer
    cmp #1
    adc #0
    sta npcTimer
    beq .end
    lda npcTimer
    ror
    bcc .rts
    inc mesgLength
    lda #SFX_TALK
    sta SfxFlags
    rts

.end
    lda npcType
    sta enType
    lda enState
    and #3
    sta enState
    lda plState
    and #~#PS_LOCK_ALL
    sta plState
.rts
    rts

.init
    lda #-48
    sta npcTimer

    lda roomId
    and #$7F
    sta shopRoom
    tay

    lda #NPC_CAVE
    bit enState
    beq .en_npc

    ldx roomEX
    lda NpcCaveOpeningDialogs-#CV_SWORD1,x
    sta mesgId

    cpx #CV_RUPEES10 + 1
    bcc .test_onetime_appear
    cpx #CV_POTION
    beq .test_silent_lady
    cpx #CV_GIVE_HEART_POTION
    beq .test_onetime_appear
    cpx #CV_TAKE_HEART_RUPEE
    beq .test_take_heart_rupee
    cpx #CV_DOOR_REPAIR
    beq .test_onetime_appear
    bne .can_appear

.en_npc
    lda roomEX
    sta mesgId
    cmp #MESG_NEED_TRIFORCE
    beq .test_need_triforce
    cmp #MESG_GRUMBLE_GRUMBLE
    beq .test_hungry
    cmp #MESG_CHOICE_GIVE_BOMB
    beq .test_choice_give_bomb
    bne .can_appear ; jmp

.test_choice_give_bomb
    lda rWorldRoomFlags,y
    bmi .cannot_appear ; #WRF_SV_ITEM_GET
    lda #EN_NPC_SHOP1
    sta npcType
    bne .can_appear ; jmp

.test_need_triforce
    lda itemTri
    cmp #$FF
    beq .cannot_appear

    lda #RF_NO_ENCLEAR
    ora roomFlags
    sta roomFlags
    bne .can_appear
    rts

.test_hungry
    lda rWorldRoomFlags,y
    bmi .cannot_appear ; #WRF_SV_ITEM_GET
    lda #EN_NPC_MONSTER
    sta npcType
    lda #NPC_SPR_MONSTER
    sta enState
    bne .can_appear ; jmp

.test_silent_lady
    lda ITEMV_NOTE
    and #ITEMF_NOTE
    bne .can_appear
    lda #EN_NPC
    sta enType
    rts

.test_onetime_appear
    lda rWorldRoomFlags,y
    bpl .can_appear ; #WRF_SV_ITEM_GET
.cannot_appear
    lda #EN_NONE
    sta enType
    rts

.test_take_heart_rupee
    lda rWorldRoomFlags,y
    bmi .cannot_appear ; #WRF_SV_ITEM_GET
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    bne .can_appear

.can_appear
    lda plState
    ora #PS_LOCK_ALL
    sta plState
    lda #TEXT_MODE_DIALOG
    sta wTextMode
    lda enState
    ora #NPC_INIT
    sta enState
    lda #0
    sta mesgLength
    ldy #5
.clearMesgChar
    lda #MESG_CHAR_SPACE
    sta mesgChar,y
    dey
    bpl .clearMesgChar
    rts


NpcCaveOpeningDialogs:
; NpcGiveOneDialogs
    .byte MESG_TAKE_THIS
    .byte MESG_MASTER_SWORD
    .byte MESG_MASTER_SWORD
    .byte MESG_NOTE
    .byte MESG_GIVE_RUPEES
    .byte MESG_GIVE_RUPEES
    .byte MESG_GIVE_RUPEES

;NpcShopDialogs
; Regular
    .byte MESG_SHOP_CHEAP
    .byte MESG_SHOP_CHEAP
    .byte MESG_SHOP_EXPENSIVE
    .byte MESG_SHOP_EXPENSIVE
; Special
    .byte MESG_CHOICE_GIVE_ITEM
    .byte MESG_CHOICE_TAKE_ITEM
; Potion
    .byte MESG_POTION
; Door Repair
    .byte MESG_TAKE_RUPEES
; Money Making Game
    .byte MESG_MONEY_GAME

; NpcPath
    .byte MESG_PATH
    .byte MESG_PATH
    .byte MESG_PATH
    .byte MESG_PATH

; Hints
    .byte MESG_HINT_GRAVE
    .byte MESG_HINT_LOST_WOODS
    .byte MESG_HINT_LOST_HILLS
    .byte MESG_HINT_TREE_AT_DEAD_END