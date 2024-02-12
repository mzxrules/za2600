;==============================================================================
; mzxrules 2024
;==============================================================================

En_NpcAppear: SUBROUTINE
    bit enState
    bmi .main

.init
    lda roomId
    and #$7F
    sta shopRoom
    tay

    ldx roomEX
    cpx #CV_RUPEES10 + 1
    bcc .test_onetime_appear
    cpx #CV_POTION
    beq .test_silent_lady
    cpx #CV_GIVE_HEART_POTION
    beq .test_onetime_appear
    cpx #CV_TAKE_HEART_RUPEE
    beq .test_onetime_appear
    cpx #CV_DOOR_REPAIR
    beq .test_onetime_appear
    bne .can_appear

.test_silent_lady
    lda ITEMV_NOTE
    and #ITEMF_NOTE
    bne .can_appear
    lda #EN_NPC_OLD_MAN
    sta enType
    lda #$40
    sta enX
    lda #$38
    sta enY
    rts

.test_onetime_appear
    lda rRoomFlag,y
    bpl .can_appear ; RF_SV_ITEM_GET
.cannot_appear
    lda #EN_NONE
    sta enType
    rts

.can_appear
    lda NpcCaveOpeningDialogs-#CV_SWORD1,x
    sta mesgId
    lda #-48
    sta npcTimer
    lda plState
    ora #PS_LOCK_ALL
    sta plState
    lda #1
    sta KernelId
    lda #NPC_INIT
    sta enState
    lda #0
    sta mesgLength
    lda #$40
    sta enX
    lda #$38
    sta enY
    ldy #5
.clearMesgChar
    lda #MESG_CHAR_SPACE
    sta mesgChar,y
    dey
    bpl .clearMesgChar
    rts
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
.rts
    rts

.end
    lda npcType
    sta enType
    lda #0
    sta enState
    lda plState
    and #~#PS_LOCK_ALL
    sta plState
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
    ;.byte MESG_POTION0

; NpcPath
    .byte MESG_PATH
    .byte MESG_PATH
    .byte MESG_PATH
    .byte MESG_PATH

; Other
    .byte MESG_MONEY_GAME
    .byte MESG_TAKE_RUPEES

; Hints
    .byte MESG_HINT_GRAVE
    .byte MESG_HINT_LOST_WOODS
    .byte MESG_HINT_LOST_HILLS
    .byte MESG_HINT_TREE_AT_DEAD_END