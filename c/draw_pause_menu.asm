;==============================================================================
; mzxrules 2022
;==============================================================================

;   Sword, Bomb, Bow,   Candle
;   Flute, Wand, Meat,  Rang
DRAW_PAUSE_MENU: SUBROUTINE
    lda #%00110000 ; ball size 8, standard playfield
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

    lda #SLOT_F0_SPR0
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
    and #$1F
    beq .setBombItem
    lda #GI_BOMB

.setBombItem
    sta PGiItems+1

; Bow
    lda ITEMV_BOW
    and #7
    tax
    lda draw_pause_menu_bow_gi_disp,x
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
    jsr draw_pause_item4_init

;==============================================================================
; Initialize PGiItems for Flute, Wand, Meat, Rang
;==============================================================================

; Flute
    lda ITEMV_FLUTE
    and #ITEMF_FLUTE
    beq .setFluteItem
    lda #GI_FLUTE
.setFluteItem
    sta PGiItems+0

; Wand
    lda ITEMV_WAND
    and #3
    tax
    lda draw_pause_menu_wand_gi_disp,x
.setWandItem
    sta PGiItems+1

; Meat
    lda ITEMV_MEAT
    and #ITEMF_MEAT
    beq .setMeatItem
    lda #GI_MEAT
.setMeatItem
    sta PGiItems+2

; Rang
    lda ITEMV_RANG
    and #ITEMF_RANG
    beq .setRangItem
    lda #GI_RANG
.setRangItem
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
; Draw Item Box
;==============================================================================

; Box Top
    ldx #2
    jsr draw_pause_item4_box_lines

; Top item row
    jsr draw_pause_item4_kernel
    ldx #0
    jsr draw_pause_item4_cursor

; Bottom item row
    jsr draw_pause_item4_init
    jsr draw_pause_item4_kernel
    ldx #1
    jsr draw_pause_item4_cursor

; Box end
    ldx #0
    jsr draw_pause_item4_box_lines

; Raft
    lda ITEMV_RAFT      ; 3 (timing assumes cycle 0)
    and #ITEMF_RAFT
    beq .setRaftItem
    lda #GI_RAFT
.setRaftItem
    sta PGiItems+0      ; 12 (worst case)
; Boots
    lda ITEMV_BOOTS
    and #ITEMF_BOOTS
    beq .setBootsItem
    lda #GI_BOOTS
.setBootsItem
    sta PGiItems+1      ; 24 (worst case)
; Bracelet
    lda ITEMV_BRACELET
    and #ITEMF_BRACELET
    beq .setBraceletItem
    lda #GI_BRACELET
.setBraceletItem
    sta PGiItems+2      ; 36 (worst case)

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
    sta PGiItems+3      ; 58 (worst case)

;==============================================================================
; Draw Row Underneath Items
;==============================================================================

    jsr draw_pause_item4_init
    jsr draw_pause_item4_kernel

;==============================================================================
; Draw Extra Info
;==============================================================================
    lda worldId
    bpl .draw_dungeon_map

.draw_tri
    jsr draw_pause_menu_tri
    ldy #82
    jmp draw_pause_menu_wsync_loop ; Finish Frame

.draw_dungeon_map
    ldy #17
    jsr draw_pause_menu_wsync_loop
    jsr draw_pause_menu_map
    ldy #18
    jmp draw_pause_menu_wsync_loop ; Finish Frame

;==============================================================================
; draw_pause_menu_wsync_loop
;----------
; Y = scanlines to delay by
;==============================================================================
draw_pause_menu_wsync_loop:
    sta WSYNC
    dey
    bne draw_pause_menu_wsync_loop
    rts

draw_pause_menu_item_cursor_pos:
    .byte #$35, #$45, #$55, #$65

draw_pause_menu_item_sprite_zp:
    .byte #<PItemSpr0, #<PItemSpr1, #<PItemSpr2, #<PItemSpr3

draw_pause_menu_bow_gi_disp:
    .byte #GI_NONE
    .byte #GI_BOW
    .byte #GI_ARROW
    .byte #GI_BOW_ARROW
    .byte #GI_ARROW_SILVER
    .byte #GI_BOW_ARROW_SILVER
    .byte #GI_ARROW_SILVER
    .byte #GI_BOW_ARROW_SILVER

draw_pause_menu_wand_gi_disp:
    .byte #GI_NONE
    .byte #GI_WAND
    .byte #GI_BOOK
    .byte #GI_WAND_BOOK

draw_pause_menu_cursor_bitflip:
    .byte $04, $00


;==============================================================================
; X = 0 for box bottom, 2 for box top (to draw side lines)
;==============================================================================
draw_pause_item4_box_lines: SUBROUTINE
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
    stx PF1

    sta WSYNC
    sta WSYNC
    rts

;==============================================================================
; X = row index the last drawn row of items is on
;==============================================================================
draw_pause_item4_cursor: SUBROUTINE
    lda #$30
    sta NUSIZ0
    lda #COLOR_WHITE
    sta COLUP0
    lda plState2
    and #4
    eor draw_pause_menu_cursor_bitflip,x
    lsr
    sta ENAM0
    sta WSYNC

    lda #0
    sta ENAM0
    lda #$02
    sta NUSIZ0
    sta WSYNC
    rts
