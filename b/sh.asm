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

; Routine for making Link hold up items.
; x = enNum
ItemGet:
    lda #PS_HOLD_ITEM
    ora plState2
    sta plState2
    lda #EN_ITEM_GET
    sta enType,x
    ldy #MS_PLAY_GI
    lda cdItemType,x
    cmp #GI_TRIFORCE
    bne .defaultGi
    ldy #MS_PLAY_TRI
.defaultGi
    sty SeqFlags
    lda plState
    ora #PS_LOCK_ALL
    sta plState

GiItemDel: SUBROUTINE
    lda cdItemType,x
    tax
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
    lda worldId
    bmi .rts
    sec
    sbc #LV_MIN
    bmi .rts
    lsr
    tax
    lda Bit8,x
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
    lda worldId
    sec
    sbc #LV_MIN
    lsr
    beq .setMap1
    tay
    lda Bit8-1,y
    ora itemMaps
    sta itemMaps
    rts
.setMap1
    lda #ITEMF_MAP_1
    ora ITEMV_MAP_1
    sta ITEMV_MAP_1
    rts
GiCompass: SUBROUTINE
    lda worldId
    sec
    sbc #LV_MIN
    lsr
    beq .setCompass1
    tay
    lda Bit8-1,y
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
; NpcShop_UpdateRupees
; Increments/Decrements rupee count for shops
; X,Y is clobbered
;==============================================================================

NpcShop_UpdateRupees: SUBROUTINE
    lda Frame
    ror
    bcc .rts

; clamp npcIncRupee
    lda #$99
    sec
    sbc itemRupees
    cmp npcIncRupee
    bcs .end_clamp_inc
    sta npcIncRupee
.end_clamp_inc

; clamp npcDecRupee
    lda itemRupees
    cmp npcDecRupee
    bcs .end_clamp_dec
    sta npcDecRupee
.end_clamp_dec

    sed
    jsr NpcShop_IncRupees
    jsr NpcShop_DecRupees
.rts
    cld
    rts

NpcShop_IncDecCommon: SUBROUTINE
    ldy #SFX_ITEM_RUPEE
    sty SfxFlags

    ldy #$10
    cmp #$30
    bcs .inc_set_delta
    ldy #$01
.inc_set_delta
    sty NpcRupeeDelta

    sec
    sbc NpcRupeeDelta
    rts


NpcShop_IncRupees: SUBROUTINE
    lda npcIncRupee
    beq .rts

    jsr NpcShop_IncDecCommon
    sta npcIncRupee

    lda itemRupees
    clc
    adc NpcRupeeDelta
    sta itemRupees
.rts
    rts

NpcShop_DecRupees: SUBROUTINE
    lda npcDecRupee
    beq .rts

    jsr NpcShop_IncDecCommon
    sta npcDecRupee

    lda itemRupees
    sec
    sbc NpcRupeeDelta
    sta itemRupees
.rts
    rts

En_NpcShopGetSelection: SUBROUTINE
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