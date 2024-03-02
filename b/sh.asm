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
    lda itemBombs
    and #$1F
    clc
    adc #4
    sta Temp0
    lda itemBombs
    rol
    rol
    rol
    and #3
    tax
    lda .MaxBombs,x
    cmp Temp0
    bcs .skipCap
    sta Temp0
.skipCap
    lda itemBombs
    and #$E0
    ora Temp0
    sta itemBombs
    rts
.MaxBombs
    .byte 8, 12, 16, 16

GiRupee: SUBROUTINE
    lda #1
    bne AddRupees

GiRupee5: SUBROUTINE
    lda #3
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
    lda Bit8-GI_BOW,x
    ora itemFlags+2
    sta itemFlags+2
    rts

GiPotionBlue:
    lda #ITEMF_POTION_BLUE
    bit ITEMV_POTION_BLUE
    bne GiPotionRed
    ora ITEMV_POTION_BLUE
    sta ITEMV_POTION_BLUE
    rts
GiPotionRed:
    lda #ITEMF_POTION_BLUE | #ITEMF_POTION_RED
    ora ITEMV_POTION_RED
    sta ITEMV_POTION_RED
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
    lda roomId
    and #$7F
    tax
    lda rWorldRoomFlags,x
    ora #WRF_SV_ITEM_GET
    sta wWorldRoomFlags,x
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
    jsr ENTER_CAVE
    ldx #$40
    ldy #$10
    stx plX
    sty plY
    bpl .rts ; jmp
.dungeonStairs
    lda #$40
    sta plX
    lda #$2C
    sta plY
    lda roomEX
    sta roomIdNext
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

NpcShop_UpdateRupees: SUBROUTINE
    lda Frame
    ror
    bcc .rts
    sed
    lda npcIncRupee
    beq .try_dec_rupees
.inc_rupees
    clc
    sbc #0
    sta npcIncRupee
    lda itemRupees
    cmp #$99
    bcs .zero_inc
    clc
    adc #1
    sta itemRupees
    lda #SFX_ITEM_RUPEE
    sta SfxFlags
    bne .rts ;jmp
.zero_inc
    lda #0
    sta npcIncRupee
    beq .rts ;jmp

.try_dec_rupees
    lda npcDecRupee
    beq .rts
    clc
    sbc #0
    sta npcDecRupee
    lda itemRupees
    beq .zero_dec
    clc
    sbc #0
    sta itemRupees
    lda #SFX_ITEM_RUPEE
    sta SfxFlags
    bne .rts ;jmp
.zero_dec
    lda #0
    sta npcDecRupee
.rts
    cld
    rts

En_NpcShopGetSelction: SUBROUTINE
    ldx #-1
    bit CXPPMM
    bpl .rts
    ldx #0 ; selected item index
    lda plX
    cmp #$30
    bmi .itemSelected
    inx
    cmp #$50
    bmi .itemSelected
    inx
.itemSelected
.rts
    rts