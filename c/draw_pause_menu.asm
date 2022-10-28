;==============================================================================
; mzxrules 2022
;==============================================================================
PosMenuObjects: SUBROUTINE
    sec            ; 2
    sta WSYNC      ; 3
.DivideLoop
    sbc #15        ; 2  6 - each time thru this loop takes 5 cycles, which is
    bcs .DivideLoop; 2  8 - the same amount of time it takes to draw 15 pixels
    eor #7         ; 2 10 - The EOR & ASL statements convert the remainder
    asl            ; 2 12 - of position/15 to the value needed to fine tune
    asl            ; 2 14 - the X position
    asl            ; 2 16
    asl            ; 2 18
    sta.wx HMP0,X  ; 5 23 - store fine tuning of X
    sta RESP0,X    ; 4 27 - set coarse X position of object
;                  ;   67, which is max supported scan cycle
    rts

;   Sword, Bomb, Bow,   Candle
;   Flute, Wand, Meat,  Potion
DRAW_PAUSE_MENU: SUBROUTINE

    lda #%00110000 ; ball size 8, reflect playfield
    sta CTRLPF
    lda #COLOR_DARK_BLUE
    sta COLUPF
    lda #1
    sta VDELP0
    sta VDELP1
    lda #0
    sta GRP0
    sta GRP1
    sta GRP0

    lda #SLOT_SPR_A
    sta BANK_SLOT
    lda #$34
    ldx #0
    jsr PosMenuObjects
    lda #$44
    ldx #1
    jsr PosMenuObjects
    lda plState2
    and #[PS_ACTIVE_ITEM & 3]
    tay
    lda draw_pause_menu_item_cursor_pos,y
    ldx #2
    jsr PosMenuObjects
    sta WSYNC
    sta HMOVE

; Configure Item Sprite page
    lda #>SprItem0
    sta PItemSpr0+1
    lda #>SprItem0
    sta PItemSpr1+1
    lda #>SprItem0
    sta PItemSpr2+1
    lda #>SprItem0
    sta PItemSpr3+1

;==============================================================================
; Initialize Sword, Bomb, Bow, Candle Slots
;==============================================================================

; Sword
    bit ITEMV_SWORD3
    bmi .displaySword3
    bvs .displaySword2
    nop
    nop
    lda #GI_SWORD2
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
    beq .setBowItem
    lda #GI_BOW
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

;==============================================================================
; Finish Frame
;==============================================================================
    ldy #71
.dummy_end
    sta WSYNC
    sta WSYNC
    dey
    bpl .dummy_end

;==============================================================================
; End Kernel
;==============================================================================

; Reset CTRLPF
    lda #%00110001 ; ball size 8, reflect playfield
    sta CTRLPF
    lda #COLOR_PLAYER_00
    sta COLUP0
    rts

draw_pause_menu_item_cursor_pos:
    .byte #$35, #$45, #$55, #$65

draw_pause_menu_item_sprite_zp:
    .byte #<PItemSpr0, #<PItemSpr1, #<PItemSpr2, #<PItemSpr3