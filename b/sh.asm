;==============================================================================
; mzxrules 2021
;==============================================================================
;ShopKernel:
; match code in tx.asm to line up PC after bank swap
    lda #SLOT_SH
    sta BANK_SLOT

KERNEL_SHOP: SUBROUTINE
; Load Sprites
    lda #SLOT_SP_A2
    sta BANK_SLOT

; Position P0 in the middle of the screen
    lda #$40
    ldy plX
    sta plX
    ldx #1
    jsr PosWorldObjects_X
    sty plX ; reset player position

; Initialize sprite pointers
    ldy #2
    ldx #0
.sprite_setup_loop
    lda shopItem,y
    asl
    asl
    asl
    sta ShopSpr0,x
    lda #>SprItem0+4
    sta ShopSpr0+1,x
    inx
    inx
    dey
    bpl .sprite_setup_loop
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
    
; Cycle padding to line up world kernel draw routine    
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC

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

    lda #COLOR_PLAYER_00
    sta COLUP0
    
.waitTimerLoop
    lda #SLOT_DRAW
    sta BANK_SLOT
    ldy #SHOP_ROOM_HEIGHT
    jsr PosWorldObjects
    sta WSYNC
    
    jmp KERNEL_WORLD_RESUME

;==============================================================================
; GET ITEM
;==============================================================================
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

GiSword2:
GiSword3:
    lda Bit8-6-GI_SWORD2,x
    ora itemFlags
    sta itemFlags
    rts
    
GiRingRed:
    lda #[ITEMF_RING_RED | ITEMF_RING_BLUE]
    bmi .cGiRedRing
GiBow:
GiRaft:
GiBoots:
GiFlute:
GiFireMagic:
GiBracelet:
GiRingBlue:
    lda Bit8-GI_BOW,x
.cGiRedRing
    ora itemFlags+1
    sta itemFlags+1
    rts
    
GiArrows:
GiArrowsSilver:
GiCandleBlue:
GiCandleRed:
GiMeat:
GiNote:
GiPotionBlue:
GiPotionRed:
    lda Bit8-GI_ARROWS,x
    ora itemFlags+2
    sta itemFlags+2
    rts

GiTriforce:
    inc itemTri
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
    
GiMap:
    ldy worldId
    lda Bit8-2,y
    ora itemMaps
    sta itemMaps
GiNone:
    rts

;==============================================================================
; En Clear Item Drop System
;==============================================================================

EnClearDrop_: SUBROUTINE
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
    ;lda #SFX_ITEM_PICKUP
    ;sta SfxFlags
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
    ldx cdAX
    stx enX
    ldy cdAY
    sty enY
    
    lda cdAType
    cmp #EN_STAIRS
    bne .rts
    
EnStairs_:
    cpx plX
    bne .rts
    cpy plY
    bne .rts
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
    lda cdBX
    sta enX
    lda cdBY
    sta enY
    
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

EnShopkeeper_: SUBROUTINE
    bit enState
    bmi .skipInit
    lda roomEX
    lsr
    lsr
    sta mesgId
    lda #2
    sta KernelId
    lda #$80
    sta enState
.skipInit
    bvc .continue
    lda #$F0
    sta enY
    jmp .rts
.continue

    lda #$30
    cmp plY
    bpl .skipSetPos
    sta plY
.skipSetPos

    lda roomEX
    and #$0F
    sta shopItem
    asl
    clc
    adc shopItem
    tax ; shop index * 3

    ldy #2
.init_shop
    lda ShopGiItems,x
    sta shopItem,y
    lda ShopPrices,x
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
    cmp shopDigit,x
    bcs .buyItem
    cld
    bcc .shopEnd
.buyItem
    sec
    sbc shopDigit,x
    sta itemRupees
    cld

    lda #[$C0 | GI_EVENT_SHOP]
    sta enState
    lda #0
    sta KernelId
    lda shopItem,x
    sta cdAType
    
    
; Special entity for making Link hold up items.
ItemGet:
    lda #PS_HOLD_ITEM
    ora plState2
    sta plState2
    lda plX
    sta enX
    sta enXL
    lda plY
    clc
    adc #9
    sta enY
    sta enYL
    lda #EN_ITEM_GET
    sta enType
    ldy #MS_PLAY_TRI
    ldx cdAType
    cpx #GI_TRIFORCE
    beq .skipGiTheme
    ldy #MS_PLAY_GI
.skipGiTheme
    sty SeqFlags
    lda plState
    ora #PS_LOCK_ALL
    sta plState
    jmp GiItemDel


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
; Cheap
    .byte GI_ARROWS, GI_RECOVER_HEART, GI_BOMB
    .byte GI_KEY, GI_RECOVER_HEART, GI_ARROWS
    .byte GI_KEY, GI_RECOVER_HEART, GI_ARROWS
    .byte GI_KEY, GI_RECOVER_HEART, GI_ARROWS
; Expensive
    .byte GI_ARROWS, GI_RECOVER_HEART, GI_BOMB
    .byte GI_KEY, GI_RECOVER_HEART, GI_ARROWS
    .byte GI_KEY, GI_RECOVER_HEART, GI_ARROWS
    .byte GI_KEY, GI_RECOVER_HEART, GI_ARROWS
; Potion
    .byte GI_NONE, GI_NONE, GI_NONE
    .byte GI_POTION_BLUE, GI_FAIRY, GI_POTION_RED

ShopPrices:
; Cheap
    .byte $30, $05, $10
    .byte $20, $05, $40
    .byte $30, $05, $10
    .byte $20, $05, $40
; Expensive    
    .byte $30, $05, $10
    .byte $20, $05, $40
    .byte $30, $05, $10
    .byte $20, $05, $40
; Potion
    .byte $AA, $AA, $AA
    .byte $20, $10, $20