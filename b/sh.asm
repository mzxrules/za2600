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
    lda #MS_PLAY_GI
    sta SeqFlags
    rts
    
GiBow:
GiRaft:
GiBoots:
GiFlute:
GiFireMagic:
GiBracelet:
GiMeat:
GiNote:
    lda Bit8-GI_BOW,x
    ora itemFlags+1
    sta itemFlags+1
    lda #MS_PLAY_GI
    sta SeqFlags
    rts
    
GiArrows:
GiArrowsSilver:
GiCandleBlue:
GiCandleRed:
GiRingBlue:
GiRingRed:
GiPotionBlue:
GiPotionRed:
    lda Bit8-GI_ARROWS,x
    ora itemFlags+2
    sta itemFlags+2
    lda #MS_PLAY_GI
    sta SeqFlags
    rts

GiTriforce:
    inc itemTri
    lda #MS_PLAY_TRI
    sta SeqFlags
    rts
GiKey:
    inc itemKeys
    lda #SFX_ITEM_PICKUP
    sta SfxFlags
    rts
GiMasterKey:
    lda #$C0
    sta itemKeys
    lda #MS_PLAY_GI
    sta SeqFlags
    rts
    
GiHeart:
    lda #MS_PLAY_GI
    sta SeqFlags
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
    lda #SFX_ITEM_PICKUP
    sta SfxFlags
    rts
GiNone:
    rts

;==============================================================================
; En Clear Item Drop System
;==============================================================================

EnClearDrop_: SUBROUTINE
    lda enState
    and #1
    tay
    lda Bit8+6,y
    and enState
    beq .endCollisionCheck ; Entity not active
    
    lda CXPPMM
    bpl .endCollisionCheck ; Player hasn't collided with Entity
    
    cpy #0
    beq .EnItemCollision ; Potentially collided with permanent item
    
    ; Collided with random drop
    ldx cdBType
    beq .endCollisionCheck ; Safety check
    lda #SFX_ITEM_PICKUP
    sta SfxFlags
    jsr GiItemDel
    lda #EN_NONE
    sta cdBType
    jmp .endCollisionCheck

.EnItemCollision
    lda cdAType
    cmp #EN_ITEM
    bne .endCollisionCheck

    ; item collected
    lda #EN_NONE
    sta cdAType
    ldx roomId
    lda rRoomFlag,x
    ora #RF_SV_ITEM_GET
    sta wRoomFlag,x
    ldx roomEX
    jsr GiItemDel
    
.endCollisionCheck
    ; Select active entity
    lda #0
    ldx cdAType
    beq .ATypeNotLoaded
    ora #CD_UPDATE_A
.ATypeNotLoaded
    ldy cdBType
    beq .BTypeNotLoaded
    ora #CD_UPDATE_B
.BTypeNotLoaded
    sta enState
    lda enState
    bne .execute
    
    ; Nothing to execute
    lda #$F0
    sta enSpr+1
    lda #$00
    sta enSpr
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
    beq EnStairs_
    cmp #EN_ITEM
    bne .rts
    jmp EnItem
    
EnStairs_:
    lda rFgColor
    sta enColor
    lda #<SprItem31
    sta enSpr
    lda #>SprItem31
    sta enSpr+1

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
    ldy cdBType
    jmp EnItemDraw
    ; rts
    
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
    ldy #GI_RUPEE
    jsr EnItemDraw
    
    lda #%0110
    sta NUSIZ1_T
    
    lda #$20
    sta enX
    lda #$28
    sta enY

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

    lda #$C0
    sta enState
    lda shopItem,x
    tax
    jsr GiItemDel
    lda #0
    sta KernelId


.shopEnd
; Update shop price display digit

    ldy #2
    lda #1
    and Frame
    bne .tensDigit
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