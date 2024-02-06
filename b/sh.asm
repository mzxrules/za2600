;==============================================================================
; mzxrules 2021
;==============================================================================
; match code in tx.asm to line up PC after bank swap
ShopKernel: BHA_BANK_FALL #SLOT_F0_SHOP

KERNEL_SHOP: SUBROUTINE
; Load Sprites
    lda #SLOT_F4_SPR0
    sta BANK_SLOT

; Position P0 in the middle of the screen
    lda #$40
    ldy plX
    sta plX
    ldx #1
    jsr PosWorldObjects_X
    sty plX ; reset player position

; Initialize sprite pointers
    ldy shopItem+0
    lda GiItemSpr,y
    sta ShopSpr2
    ldy shopItem+1
    lda GiItemSpr,y
    sta ShopSpr1
    ldy shopItem+2
    lda GiItemSpr,y
    sta ShopSpr0
    lda #>SprItem0+4
    sta ShopSpr0+1
    sta ShopSpr1+1
    sta ShopSpr2+1

    ldy #15
    sty ShopDrawY


; Set P1 sprite to double with large gap, and player to regular
    lda #%0100
    sta NUSIZ1
    lda #%0000
    sta NUSIZ0

    ldx shopItem+1
    lda GiItemColors,x
    sta COLUP0



; DRAW
.draw_loop
    sta WSYNC
    lda ShopDrawY
    lsr
    tay

    lda (ShopSpr2),y
    sta GRP1
    ldx shopItem
    lda GiItemColors,x
    sta COLUP1

    lda (ShopSpr1),y
    sta GRP0

    ldx shopItem+2
    lda GiItemColors,x
    sta COLUP1

    lda (ShopSpr0),y
    sta GRP1
    dec ShopDrawY
    bne .draw_loop


; KERNEL_SHOP RETURN
    ldx #0
    stx GRP0
    stx GRP1

.waitTimerLoop
    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    ldy #SHOP_ROOM_HEIGHT
    jsr PosWorldObjects
    sta WSYNC

; Cycle padding to line up world kernel draw routine
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC

    jmp KERNEL_WORLD_RESUME

;==============================================================================
; GET ITEM
;==============================================================================

; Special entity for making Link hold up items.
ItemGet:
    lda #PS_HOLD_ITEM
    ora plState2
    sta plState2
    lda plX
    sta enX
    lda plY
    clc
    adc #9
    sta enY
    lda #EN_ITEM_GET
    sta enType
    ldy #MS_PLAY_GI
    ldx cdAType
    cpx #GI_TRIFORCE
    bne .defaultGi
    ldy #MS_PLAY_TRI
.defaultGi
    sty SeqFlags
    lda plState
    ora #PS_LOCK_ALL
    sta plState

GiItemDel: SUBROUTINE
    lda ItemIdH,x
    pha
    lda ItemIdL,x
    pha
    rts

GiBomb: SUBROUTINE
    lda enType
    cmp #EN_ITEM_GET
    beq .skipSfx
    lda #SFX_ITEM_PICKUP
    sta SfxFlags
.skipSfx
    sed
    clc
    lda itemBombs
    adc #4
    cmp #$16
    bmi .skipCap
    lda #$16
.skipCap
    sta itemBombs
    cld
    rts

GiRupee: SUBROUTINE
    lda #1
    bne AddRupees

GiRupee5: SUBROUTINE
    lda #5
    bne AddRupees

; Assume returns not zero
AddRupees: SUBROUTINE
    sed
    clc
    adc itemRupees
    bcc .skipCap
    lda #$99
.skipCap
    sta itemRupees
    cld
    lda #SFX_ITEM_PICKUP
    sta SfxFlags
    rts

GiFairy: SUBROUTINE
    lda #8*5
    bpl .setHealth
GiRecoverHeart:
    lda #8
.setHealth
    jmp UPDATE_PL_HEALTH

GiShield:
GiFlute:
GiMeat:
GiSword1:
GiSword2:
GiSword3:
    lda Bit8+2-GI_SHIELD,x
    ora itemFlags
    sta itemFlags
    rts

GiRingRed:
    lda #[ITEMF_RING_RED | ITEMF_RING_BLUE]
    bmi .cGiRedRing ; JMP
GiWand:
GiBook:
GiRang:
GiRaft:
GiBoots:
GiBracelet:
GiRingBlue:
    lda Bit8-GI_WAND,x
.cGiRedRing
    ora itemFlags+1
    sta itemFlags+1
    rts

GiBow:
GiArrow:
GiArrowSilver:
GiCandleBlue:
GiCandleRed:
GiNote:
GiPotionBlue:
GiPotionRed:
    lda Bit8-GI_BOW,x
    ora itemFlags+2
    sta itemFlags+2
    rts

GiTriforce:
    ldx worldId
    lda Bit8-1,x
    ora itemTri
    sta itemTri
    rts
GiKey:
    inc itemKeys
    lda enType
    cmp #EN_ITEM_GET
    beq .rts
    lda #SFX_ITEM_PICKUP_KEY
    sta SfxFlags
.rts
    rts
GiMasterKey:
    lda #$C0
    sta itemKeys
    rts

GiHeart:
    clc
    lda #8
    adc plHealthMax
    sta plHealthMax
    lda #8
    adc plHealth
    sta plHealth
    rts

GiMap: SUBROUTINE
    ldy worldId
    cpy #2
    bcc .setMap1
    lda Bit8-2,y
    ora itemMaps
    sta itemMaps
    rts
.setMap1
    lda #ITEMF_MAP_1
    ora ITEMV_MAP_1
    sta ITEMV_MAP_1
    rts
GiCompass: SUBROUTINE
    ldy worldId
    cpy #2
    bcc .setCompass1
    lda Bit8-2,y
    ora itemCompass
    sta itemCompass
    rts
.setCompass1
    lda #ITEMF_COMPASS_1
    ora ITEMV_COMPASS_1
    sta ITEMV_COMPASS_1
    rts

GiNone:
    rts

;==============================================================================
; En Clear Item Drop System
;==============================================================================

EnClearDrop: SUBROUTINE
; process last drawn entity
    lda enState
    and #1 ; CD_LAST_UPDATE
    tay
    lda Bit8+6,y
    and enState ; CD_UPDATE_B / CD_UPDATE_A
    beq .endCollisionCheck ; Entity not active

    lda CXPPMM
    bpl .endCollisionCheck ; Player hasn't collided with Entity

    cpy #0 ; Check if CD_UPDATE_A
    beq .EnItemCollision ; Potentially collided with permanent item

    ; Collided with random drop
    ldx cdBType
    beq .endCollisionCheck ; Safety check
    jsr GiItemDel
    lda #EN_NONE
    sta cdBType
    jmp .endCollisionCheck

.EnItemCollision
    lda cdAType
    cmp #EN_ITEM
    bne .endCollisionCheck

    ; item collected
    ldx roomId
    lda rRoomFlag,x
    ora #RF_SV_ITEM_GET
    sta wRoomFlag,x
    ldx roomEX
    cpx #GI_TRIFORCE
    bmi .EnItem_GiItem
    cpx #GI_KEY
    beq .EnItem_GiItem
    stx cdAType
    jmp ItemGet
.EnItem_GiItem
    lda #EN_NONE
    sta cdAType
    jsr GiItemDel

.endCollisionCheck
    ; Update enState flags
    lda #0 ; EN_NONE / GI_NONE
    ldx cdAType
    beq .ATypeNotLoaded
    ora #CD_UPDATE_A
.ATypeNotLoaded
    ldy cdBType
    beq .BTypeNotLoaded
    ora #CD_UPDATE_B
.BTypeNotLoaded
    sta enState
    ; Execute routine
    lda enState
    bne .execute

    ; Nothing to execute
    rts

.execute
    tax ; x = enState
    lda Frame
    and #4
    bne .TryTypeB
.TryTypeA
    txa
    and #CD_UPDATE_A
    bne .TypeA
.TypeB
    jmp EnClearDropTypeB
.TryTypeB
    txa
    and #CD_UPDATE_B
    bne .TypeB
.TypeA

EnClearDropTypeA: SUBROUTINE
    lda cdAType
    cmp #EN_STAIRS
    bne .rts

EnStairs:
    ldx cdAX
    ldy cdAY
    cpx plX
    bne .rts
    cpy plY
    bne .rts
    lda worldId
    bne .dungeonStairs
.worldStairs
    jmp ENTER_CAVE
.dungeonStairs
    lda roomEX
    sta roomId
    lda roomFlags
    ora #RF_EV_LOAD
    sta roomFlags
.rts
    rts

; Random Item Drops
EnClearDropTypeB: SUBROUTINE
    inc enState

    lda cdBType
    cmp #CD_ITEM_RAND
    bne .skipRollItem

    inc cdBType ; set GI_NONE
    jsr Random
    cmp #255 ; drop rate odds, N out of 256
    bcs .skipRollItem
    jsr Random
    and #3
    tay
    lda EnRandomDrops,y
    sta cdBType
.skipRollItem
    rts

EnRandomDrops:
    .byte #GI_RECOVER_HEART, #GI_FAIRY, #GI_BOMB, #GI_RUPEE5

En_NpcGiveOne: SUBROUTINE
    ldx roomEX
    lda roomId
    and #$7F
    tay
    lda rRoomFlag,y
    bpl .skip_SetItemGet ; RF_SV_ITEM_GET
    lda #$C0
    sta enState
.skip_SetItemGet

    bit enState
    bvs .rts
    bmi .main

.init
    lda NpcGiveOneDialogs-CV_SWORD1,x
    sta mesgId
    lda #1
    sta KernelId
    lda #$80
    sta enState

.main
    bit CXPPMM
    bpl .rts
    cpx #CV_RUPEES100
    bcc .maxHealthTest
.rupee
    lda NpcGiveOneData-CV_SWORD1,x
    jsr AddRupees
    bne .give_item ; jmp
.maxHealthTest
    lda plHealthMax
    cmp NpcGiveOneData-CV_SWORD1,x
    bcc .rts
.give_item
; Set RF_SV_ITEM_GET Flag
    lda rRoomFlag,y
    ora #RF_SV_ITEM_GET
    sta wRoomFlag,y
; Trigger ItemGet
    lda #[$C0 | GI_EVENT_CAVE]
    sta enState

    lda #0
    sta KernelId
    lda NpcGiveOneItems-CV_SWORD1,x
    sta cdAType
    jmp ItemGet

.rts
    rts


En_NpcShopkeeper: SUBROUTINE
    bit enState
    bvs .rts
    bmi .main
    ldy roomEX
    lda ShopDialogs-CV_SHOP1,y
    sta mesgId
    lda #2
    sta KernelId
    lda #$80
    sta enState

.main
    lda roomEX
    asl
    clc
    adc roomEX
    tax ; shop index * 3

    ldy #2
.init_shop
    lda ShopGiItems-[CV_SHOP1 * 3],x
    sta shopItem,y
    lda ShopPrices-[CV_SHOP1 * 3],x
    sta shopDigit,y
    inx
    dey
    bpl .init_shop

; Shop logic
    bit CXPPMM
    bpl .shopEnd
    ldx #0 ; selected item index
    lda plX
    cmp #$30
    bmi .itemSelected
    inx
    cmp #$50
    bmi .itemSelected
    inx
.itemSelected
    sed
    lda itemRupees
    cmp shopDigit,x ; item price
    bcs .buyItem
    cld
    bcc .shopEnd
.buyItem
    sec
    sbc shopDigit,x
    sta itemRupees
    cld

    lda #[$C0 | GI_EVENT_CAVE]
    sta enState
    lda #0
    sta KernelId
    lda shopItem,x
    sta cdAType

    jmp ItemGet

.shopEnd
; Update shop price display digit

    ldy #2
    lda #1
    and Frame
    beq .tensDigit
.onesDigit
    lda shopDigit,y
    and #$0F
    sta shopDigit,y
    dey
    bpl .onesDigit
    bmi .rts
.tensDigit
    lda shopDigit,y
    lsr
    lsr
    lsr
    lsr
    sta shopDigit,y
    dey
    bpl .tensDigit
.rts
    rts

ShopGiItems:
; Regular
    .byte GI_SHIELD, GI_KEY, GI_CANDLE_BLUE
    .byte GI_SHIELD, GI_BOMB, GI_ARROW
    .byte GI_SHIELD, GI_MEAT, GI_RECOVER_HEART
    .byte GI_KEY, GI_MEAT, GI_RING_BLUE
; Potion
    .byte GI_POTION_BLUE, GI_FAIRY, GI_POTION_RED
    .byte GI_NONE, GI_NONE, GI_NONE

ShopPrices:
; Regular
    .byte $65, $40, $25 ; 160, 100, 60
    .byte $50, $10, $30 ; 130, 20, 80
    .byte $35, $40, $05 ; 90, 100, 10
    .byte $30, $25, $99 ; 80, 60, 250
; Potion
    .byte $16, $10, $25 ; 40, NA, 68
    .byte $AA, $AA, $AA

ShopDialogs:
    .byte MESG_SHOP_CHEAP
    .byte MESG_SHOP_CHEAP
    .byte MESG_SHOP_EXPENSIVE
    .byte MESG_SHOP_EXPENSIVE
    .byte MESG_POTION
    .byte MESG_POTION0

NpcGiveOneItems:
    .byte GI_SWORD1
    .byte GI_SWORD2
    .byte GI_SWORD3
    .byte GI_NOTE
    .byte GI_RUPEE
    .byte GI_RUPEE
    .byte GI_RUPEE

NpcGiveOneDialogs:
    .byte MESG_TAKE_THIS
    .byte MESG_MASTER_SWORD
    .byte MESG_MASTER_SWORD
    .byte MESG_NOTE
    .byte MESG_GIVE_RUPEES
    .byte MESG_GIVE_RUPEES
    .byte MESG_GIVE_RUPEES

NpcGiveOneData:
; plHealthMax requirements
    .byte #0
    .byte #5*8
    .byte #12*8
    .byte #0
; secret rupee amounts minus 1
    .byte $39 ; $40 -> Rupee100
    .byte $11 ; $12 -> Rupee30
    .byte $04 ; $05 -> Rupee10

LifeCost = $20 ; -50