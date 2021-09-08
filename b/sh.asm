;==============================================================================
; mzxrules 2021
;==============================================================================
;ShopKernel:
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
    
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC
    
    jmp KERNEL_WORLD_RESUME