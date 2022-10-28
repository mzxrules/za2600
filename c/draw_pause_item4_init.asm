;==============================================================================
; mzxrules 2022
;==============================================================================
    ldy #3
.sprite_init_loop:
    lda PGiItems,y

    tax
    lda GiItemColors,x
    sta PItemColors,y
    txa
    asl
    asl
    asl
    pha
    lda draw_pause_menu_item_sprite_zp,y
    tax
    pla
    sta 0,x
    dey
    bpl .sprite_init_loop