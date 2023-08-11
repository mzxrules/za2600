;==============================================================================
; mzxrules 2023
;==============================================================================
    sta WSYNC
    lda #$03            ; +2 (2)
    sta NUSIZ0          ; +3 (5)  Three copies close for P0 and P1
    sta NUSIZ1          ; +3 (8)
    SLEEP 11
    sta HMCLR           ; +3 (22)
    lda #$80            ; +2 (24)
    sta HMP0            ; +3 (27)
    lda #$90            ; +2 (29)
    sta HMP1            ; +3 (32)
    nop                 ; +2 (34)
    sta RESP0           ; +3 (37)
    sta RESP1

    sta WSYNC
    sta HMOVE

    lda #COLOR_EN_TRIFORCE
    sta COLUPF
    lda #$FC
    sta PF2


    lda #SLOT_RW_MAP
    sta BANK_SLOT_RAM

    lda #$01
    sta VDELP0
    sta VDELP1
    ldy #39
    sty PMapDrawTemp0
.loop
    repeat 2
    ldy PMapDrawTemp0   ; +3 (65)
    lda rMAP_0,y        ; +4 (69)
    sta WSYNC           ; +3 (72->0)
    sta GRP0            ; +3 (3)
    lda rMAP_1,y        ; +4 (7)
    sta GRP1            ; +3 (10)
    lda rMAP_2,y        ; +4 (14)
    sta GRP0            ; +3 (17)
    lda rMAP_3,y        ; +4 (21)
    sta PMapDrawTemp1   ; +3 (24)
    lda rMAP_4,y        ; +4 (28)
    tax                 ; +2 (30)
    lda rMAP_5,y        ; +4 (34)
    ldy PMapDrawTemp1   ; +3 (37)
    nop                 ; +2 (39)
    cpx $80             ; +3 (42)
    sty GRP1            ; +3 (45)
    stx GRP0            ; +3 (48)
    sta GRP1            ; +3 (51)
    sta GRP0            ; +3 (54)
    repend
    dec PMapDrawTemp0   ; +5 (59)
    bpl .loop           ; +3 (62)

    lda #$00            ; +2 (63)
    sta GRP0            ; +3 (66)
    sta GRP1            ; +3 (69)
    sta VDELP0          ; +3 (72)
    sta VDELP1          ; +3 (75)

    sta WSYNC
    sta WSYNC
    lda #COLOR_BLACK
    sta COLUPF