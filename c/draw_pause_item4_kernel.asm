;==============================================================================
; mzxrules 2022
;==============================================================================
    ldy #7
    ldx PItemColors+2
.draw_loop
    sta WSYNC

    lda PItemColors+0
    sta COLUP0
    lda (PItemSpr0),y ; 5
    sta GRP0
    lda PItemColors+1
    sta COLUP1
    lda (PItemSpr1),y ; 5
    sta GRP1
    lda (PItemSpr2),y ; 5
    sta GRP0
    lda (PItemSpr3),y ; 5
    sta GRP1
    stx COLUP0
    sta GRP0
    lda PItemColors+3
    sta COLUP1

    sta WSYNC

    lda PItemColors+0
    sta COLUP0
    lda (PItemSpr0),y ; 5
    sta GRP0
    lda PItemColors+1
    sta COLUP1
    lda (PItemSpr1),y ; 5
    sta GRP1
    lda (PItemSpr2),y ; 5
    sta GRP0
    lda (PItemSpr3),y ; 5
    sta GRP1
    stx COLUP0
    sta GRP0
    lda PItemColors+3
    sta COLUP1

    dey
    bpl .draw_loop

    lda #0
    sta GRP1
    sta GRP0
    sta GRP1