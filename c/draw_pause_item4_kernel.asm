;==============================================================================
; mzxrules 2022
;==============================================================================

;==============================================================================
; draw_pause_item4_kernel
; Renders the four item sprites with color on the pause screen
; Returns with scan cycle 0
;==============================================================================
draw_pause_item4_kernel: SUBROUTINE
    ldy #8
    ldx PItemColors+2
.draw_loop
    dey
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

    tya
    bne .draw_loop

    ; cycle 60
    sta.w GRP1  ; 64 burn a cycle
    sta GRP0    ; 67
    sta GRP1    ; 70
    rts         ; 76