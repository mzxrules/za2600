;==============================================================================
; mzxrules 2022
;==============================================================================
    align 16
PosMenuObject: SUBROUTINE
    INCLUDE "c/sub_PosObject.asm"

;   Sword, Bomb, Bow,   Candle
;   Flute, Wand, Meat,  Potion
DRAW_PAUSE_MENU: SUBROUTINE

    lda #%00110000 ; ball size 8, reflect playfield
    sta CTRLPF
    lda #COLOR_PF_BLUE_D
    sta COLUPF
    lda #1
    sta VDELP0
    sta VDELP1
    lda #0
    sta GRP0
    sta GRP1
    sta GRP0
    sta REFP1

    lda #SLOT_SPR_A
    sta BANK_SLOT
    lda #$34
    ldx #0
    jsr PosMenuObject
    lda #$44
    ldx #1
    jsr PosMenuObject
    lda plState2
    and #[PS_ACTIVE_ITEM & 3]
    tay
    lda draw_pause_menu_item_cursor_pos,y
    ldx #2
    jsr PosMenuObject
    sta WSYNC
    sta HMOVE

; Configure Item Sprite page
    lda #>SprItem0
    sta PItemSpr0+1
    sta PItemSpr1+1
    sta PItemSpr2+1
    sta PItemSpr3+1

;==============================================================================
; Initialize Sword, Bomb, Bow, Candle Slots
;==============================================================================

; Sword
    bit ITEMV_SWORD3
    bmi .displaySword3
    bvs .displaySword2
    lda ITEMV_SWORD1
    and #ITEMF_SWORD1
    beq .setSwordItem

.displaySword1
    lda #GI_SWORD1
    bpl .setSwordItem

.displaySword2
    lda #GI_SWORD2
    bpl .setSwordItem

.displaySword3
    lda #GI_SWORD3
    bpl .setSwordItem

.setSwordItem
    sta PGiItems+0

; Bombs
    lda itemBombs
    beq .setBombItem
    lda #GI_BOMB

.setBombItem
    sta PGiItems+1

; Bow
    lda ITEMV_BOW
    and #ITEMF_BOW
    beq .tryDisplayArrow

    lda ITEMV_ARROW
    tax
    and ITEMF_ARROW_SILVER
    bne .displayBowArrowSilver
    txa
    and ITEMF_ARROW
    bne .displayBowArrow
    lda #GI_BOW
    bpl .setBowItem
.displayBowArrow
    lda #GI_BOW_ARROW
    bpl .setBowItem

.displayBowArrowSilver
    lda #GI_BOW_ARROW_SILVER
    bpl .setBowItem


.tryDisplayArrow
    lda ITEMV_ARROW
    tax
    and ITEMF_ARROW_SILVER
    bne .displaySilverArrow
    txa
    and ITEMF_ARROW
    beq .setBowItem
    lda #GI_ARROW
    bpl .setBowItem

.displaySilverArrow
    lda #GI_ARROW_SILVER

.setBowItem
    sta PGiItems+2

; Candle
    lda #ITEMF_CANDLE_RED
    and ITEMV_CANDLE_RED
    bne .displayCandleRed
    lda #ITEMF_CANDLE_BLUE
    and ITEMV_CANDLE_BLUE
    beq .setCandleItem
    lda #GI_CANDLE_BLUE
    bpl .setCandleItem
.displayCandleRed
    lda #GI_CANDLE_RED
.setCandleItem
    sta PGiItems+3

; Precompute first 4 item's sprite ptr and colors
    INCLUDE "c/draw_pause_item4_init.asm"

;==============================================================================
; Initialize PGiItems for Flute, Wand, Meat, Potion
;==============================================================================

; Flute
    lda ITEMV_FLUTE
    and #ITEMF_FLUTE
    beq .setFluteItem
    lda #GI_FLUTE
.setFluteItem
    sta PGiItems+0

; Wand
    lda ITEMV_FIRE_MAGIC
    and #ITEMF_FIRE_MAGIC
    beq .setWandItem
    lda #GI_FIRE_MAGIC
.setWandItem
    sta PGiItems+1

; Meat
    lda ITEMV_MEAT
    and #ITEMF_MEAT
    beq .setMeatItem
    lda #GI_MEAT
.setMeatItem
    sta PGiItems+2

; Potion
    bit ITEMV_POTION_RED
    bmi .displayPotionRed
    bvs .displayPotionBlue
    lda ITEMV_NOTE
    and #ITEMF_NOTE
    beq .setPotionItem
    lda #GI_NOTE
    bpl .setPotionItem
.displayPotionRed
    lda #GI_POTION_RED
    bpl .setPotionItem

.displayPotionBlue
    lda #GI_POTION_BLUE
.setPotionItem
    sta PGiItems+3

KERNEL_PAUSE_MENU_MAIN: SUBROUTINE ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_PAUSE_MENU_MAIN
    sta VBLANK
    lda #0
    sta COLUBK
    sta PF0
    sta PF1
    sta PF2

    lda #$02
    sta NUSIZ0
    sta NUSIZ1

;==============================================================================
; Draw Box Top Line
;==============================================================================
    sta WSYNC
    ldy #4
    lda #3
    sta PF1
    lda #$FF
    sta PF2
.sleep_line_top
    dey
    bpl .sleep_line_top
    sta PF0
    lda #$FE
    sta PF1
    lda #0
    sta PF2

    sta WSYNC
    lda #0
    sta PF0
    sta PF2
    lda #2
    sta PF1

    sta WSYNC
    sta WSYNC

;==============================================================================
; Draw Top Row Items
;==============================================================================

    INCLUDE "c/draw_pause_item4_kernel.asm"

;==============================================================================
; Draw Top Row Cursor
;==============================================================================
    sta WSYNC
    lda #$30
    sta NUSIZ0
    lda #COLOR_WHITE
    sta COLUP0
    lda plState2
    and #4
    bne .skipRow0
    lda #2
    sta ENAM0
.skipRow0
    sta WSYNC
    lda #0
    sta ENAM0
    lda #$02
    sta NUSIZ0
    sta WSYNC

;==============================================================================
; Draw Bottom Row Items
;==============================================================================
    SUBROUTINE
    INCLUDE "c/draw_pause_item4_init.asm"
    INCLUDE "c/draw_pause_item4_kernel.asm"

;==============================================================================
; Draw Bottom Row Cursor
;==============================================================================
    sta WSYNC
    lda #$30
    sta NUSIZ0
    lda #COLOR_WHITE
    sta COLUP0
    lda plState2
    and #4
    beq .skipRow1
    lda #2
    sta ENAM0
.skipRow1
    sta WSYNC
    lda #0
    sta ENAM0
    lda #$02
    sta NUSIZ0
    sta WSYNC

;==============================================================================
; Draw Box Bottom Line
;==============================================================================
    sta WSYNC
    ldy #4
    lda #3
    sta PF1
    lda #$FF
    sta PF2
.sleep_line_bottom
    dey
    bpl .sleep_line_bottom
    sta PF0
    lda #$FE
    sta PF1
    lda #0
    sta PF2

    sta WSYNC
    sta PF0
    sta PF1

    sta WSYNC
    sta WSYNC
    jmp DRAW_PAUSE_MENU_TRI

draw_pause_menu_item_cursor_pos:
    .byte #$35, #$45, #$55, #$65

draw_pause_menu_item_sprite_zp:
    .byte #<PItemSpr0, #<PItemSpr1, #<PItemSpr2, #<PItemSpr3