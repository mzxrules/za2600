N SET 0

KERNEL48:
.loop
    repeat 2
    ldy PMapDrawTemp0   ; +3 (65)
rTex_0,N
    lda rTex_00,y      ; +4 (69)
    sta WSYNC           ; +3 (72->0)
    sta GRP0            ; +3 (3)
rTex_1,N
    lda rTex_10,y      ; +4 (7)
    sta GRP1            ; +3 (10)
rTex_2,N
    lda rTex_20,y      ; +4 (14)
    sta GRP0            ; +3 (17)
rTex_3,N
    lda rTex_30,y      ; +4 (21)
    sta PMapDrawTemp1   ; +3 (24)
rTex_4,N
    lda rTex_40,y      ; +4 (28)
    tax                 ; +2 (30)
rTex_5,N
    lda rTex_50,y      ; +4 (34)
    ldy PMapDrawTemp1   ; +3 (37)
    nop                 ; +2 (39)
    cpx $80             ; +3 (42)
    sty GRP1            ; +3 (45)
    stx GRP0            ; +3 (48)
    sta GRP1            ; +3 (51)
    sta GRP0            ; +3 (54)
N SET N+1
    repend
    dec PMapDrawTemp0   ; +5 (59)
    bpl .loop           ; +3 (62)

    lda #$00            ; +2 (63)
    sta GRP0            ; +3 (66)
    sta GRP1            ; +3 (69)
    sta VDELP0          ; +3 (72)
    sta VDELP1          ; +3 (75)
    rts

    LOG_SIZE "-KERNEL48-", KERNEL48