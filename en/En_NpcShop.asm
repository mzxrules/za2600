;==============================================================================
; mzxrules 2024
;==============================================================================
En_NpcShop2: SUBROUTINE
En_NpcShop: SUBROUTINE
    lda #SEG_SH
    sta BANK_SLOT
    ldx roomEX
    bit enState
    bvs .shop_end
    bmi En_NpcShopMain

.init
    lda #0
    sta npcIncRupee
    sta npcDecRupee

.init_default_shop
    lda #TEXT_MODE_SHOP
    sta wTextMode

    cpx #CV_TAKE_HEART_RUPEE
    bne .skip_MinusDisp
    lda #MESG_CHAR_MINUS
    sta mesgChar+3
    sta mesgChar+5
.skip_MinusDisp

; Pick Shop
    txa ; roomEX
    sta Temp0
    asl
    clc
    adc Temp0
    tax ; shop index * 3

    ldy #2
.init_shop
    lda ShopGiItems-[CV_SHOP1 * 3],x
    sta shopItem,y
    lda ShopPrices-[CV_SHOP1 * 3],x
    sta shopPrice,y
    inx
    dey
    bpl .init_shop

    lda enState
    ora #NPC_INIT
    sta enState
.rts
    rts

.shop_end
    jmp NpcShop_UpdateRupees

En_NpcShopMain: SUBROUTINE
    lda roomEX
    cmp #CV_MONEY_GAME
    bne .no_rng
    jsr Rng2
.no_rng
    lda #NPC_ITEM_GOT
    bit enState
    bne .rts
; Shop logic
    jsr En_NpcShopGetSelection
    cpx #-1
    beq .rts
    lda roomEX
    cmp #CV_TAKE_HEART_RUPEE
    beq .take_item
    cmp #CV_GIVE_HEART_POTION
    beq .give_item
    bne .try_buy_item

.give_item
    ldy shopRoom
    lda rWorldRoomFlags,y
    ora #WRF_SV_ITEM_GET
    sta wWorldRoomFlags,y
    bne .getItem ;jmp

.try_buy_item
    sed
    lda itemRupees
    cmp shopPrice,x ; item price
    bcs .buyItem
    cld
    bcc .rts
.buyItem
    sec
    sbc shopPrice,x
    sta itemRupees
    cld
.getItem
    lda #[#NPC_INIT | #NPC_ITEM_GOT | #NPC_CAVE]
    ora enState
    sta enState
    lda #0
    sta wTextMode
    lda shopItem,x
    ldx enNum
    sta cdItemType,x
    jmp ItemGet

.take_item
    cpx #2
    beq .take_health
.try_take_rupees
    lda itemRupees
    cmp #$20
    bcc .rts
    sec
    sbc #$20
    sta itemRupees
    ;lda #$20
    ;sta npcDecRupee
.take_item_clear
    ldy shopRoom
    lda rWorldRoomFlags,y
    ora #WRF_SV_ITEM_GET
    sta wWorldRoomFlags,y
    lda roomFlags
    ora #RF_EV_CLEAR
    sta roomFlags
    lda #0
    sta wTextMode
    lda #[#NPC_INIT | #NPC_ITEM_GOT | #NPC_CAVE]
    ora enState
    sta enState
.rts
    rts

.take_health
    lda plHealthMax
    cmp #3*8+1
    bcs .steal_max_health
    lda #1
    sta plHealth
    bpl .take_item_clear ; jmp
.steal_max_health
    sec
    sbc #8
    sta plHealthMax
    cmp plHealth
    bcs .take_item_clear
    sta plHealth
    bcc .take_item_clear ; jmp


ShopGiItems:
; Regular
    .byte GI_SHIELD, GI_KEY, GI_CANDLE_BLUE
    .byte GI_SHIELD, GI_BOMB, GI_ARROW
    .byte GI_SHIELD, GI_MEAT, GI_RECOVER_HEART
    .byte GI_KEY, GI_MEAT, GI_RING_BLUE
; Heart Potion
    .byte GI_HEART, GI_NONE, GI_POTION_RED
; Money or life
    .byte GI_HEART, GI_NONE, GI_RUPEE
; Potion
    .byte GI_POTION_BLUE, GI_FAIRY, GI_POTION_RED
; Door Repair
    .byte GI_NONE, GI_RUPEE, GI_NONE
; Money Game
    .byte GI_RUPEE, GI_RUPEE, GI_RUPEE

ShopPrices:
; Regular
    .byte $65, $40, $25 ; 160, 100, 60
    .byte $50, $10, $30 ; 130, 20, 80
    .byte $35, $40, $05 ; 90, 100, 10
    .byte $30, $25, $99 ; 80, 60, 250
; Heart Potion
    .byte $AA, $AA, $AA
; Money or Life
    .byte $01, $AA, $20 ; LifeCost = $20 ; -50
; Potion
    .byte $16, $10, $25 ; 40, NA, 68
; Door Repair
    .byte $AA, $10, $AA ; NA, 20, NA
