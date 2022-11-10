    lda #1
    sta VDELP0
    sta VDELP1
    
    lda #55
    ldx #0
    jsr PosMenuObject_2
    lda #63
    ldx #1
    jsr PosMenuObject_2
    sta WSYNC
    lda #$03            ; +2 (2)
    sta NUSIZ0          ; +3 (5)  Three copies close for P0 and P1
    sta NUSIZ1          ; +3 (8)
    lda #COLOR_EN_TRIFORCE ; +2 (10)
    sta COLUP0          ; +3 (16)
    sta COLUP1          ; +3 (19)

    sta WSYNC
    sta HMOVE
    ldy #15

.x48
    sta WSYNC
    sty scrtch1
    lda tri_0,y ; +4 (69) ; logo0
    sta GRP0    ; +3 (3)
    lda tri_1,y ; +4 (7) ; logo1
    sta GRP1    ; +3 (10)
    lda tri_2,y ; +4 (14) ; logo2
    sta GRP0    ; +3 (17)
    ldx tri_4,y ; +4 (21) ; logo4
    lda tri_3,y ; +4 (28) ; logo3
    sta scrtch2

    lda tri_5,y ; +4 (34) ; logo5
    ldy scrtch2 ; +3 (37)
    sty GRP1    ; +3 (45)
    stx GRP0    ; +3 (48)
    sta GRP1    ; +3 (51)
    sta GRP0    ; +3 (54)
    ldy scrtch1 ; +5 (59)

    dey
    bpl     .x48            ; +3 (62)

    lda #$00            ; +2 (63)
    sta GRP0            ; +3 (66)
    sta GRP1            ; +3 (69)
    sta GRP0            ; +3 (66)

    rts
    
   
    align 16

tri_0:
tri_1:
tri_2:
tri_3:
tri_4:
tri_5:
    REPEAT 8
    .byte $AA, $55
    REPEND

PosMenuObject_2: SUBROUTINE
    INCLUDE "c/sub_PosObject.asm"