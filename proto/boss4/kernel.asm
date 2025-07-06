;==============================================================================
; mzxrules 2025
;==============================================================================

KERNEL_BOSS4_SETV
    .byte #$40

KERNEL_BOSS4_START:
    bit KERNEL_BOSS4_SETV
    ldy #$4F

    ldx ganonKernel
    lda Boss4KernelH,x
    pha
    lda Boss4KernelL,x
    pha

    ldx #0
    txa
    rts

KERNEL_BOSS4_LOOP_33: SUBROUTINE
.loop
    sta WSYNC
    sta ENAM0           ; 3
    stx GRP1            ; 3

    lda rPLSPR_MEM,y    ; 4
    sta GRP0            ; 3 - 13

    lda (enSpr),y       ; 5
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 7             ;   - 33
    sta GRP1            ; 3 - 36

    lda (enMSpr),y      ; 5 - 41
    sta WSYNC
    sta ENAM1           ; 3 -  3
    sleep 10            ;   - 13

    lda (enSpr),y       ; 5 - 18
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 7             ;   - 33
    sta GRP1            ; 3 - 36

    lda (plMSpr),y      ; 5 - 41
    dey                 ; 2 - 43

    bpl .loop           ; 3 - 46/45
    sta WSYNC

    iny
    sty GRP0
    sty GRP1
    rts
    LOG_BANK_SIZE "GANON_KERNEL_33", KERNEL_BOSS4_LOOP_33

KERNEL_BOSS4_LOOP_36: SUBROUTINE
    clv
KERNEL_BOSS4_LOOP_39:
.loop
    sta WSYNC
    sta ENAM0           ; 3
    stx GRP1            ; 3

    lda rPLSPR_MEM,y    ; 4
    sta GRP0            ; 3 - 13

    lda (enSpr),y       ; 5
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 4
    VSLEEP69            ;   - 36 / 39
    sta GRP1            ; 3 - 39 / 42

    lda (enMSpr),y      ; 5 - 44 / 45
    sta WSYNC
    sta ENAM1           ; 3 -  3
    sleep 10            ;   - 13

    lda (enSpr),y       ; 5 - 18
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 4
    VSLEEP69            ;   - 36 / 39
    sta GRP1            ; 3 - 39 / 42

    lda (plMSpr),y      ; 5 - 44 / 47
    dey                 ; 2 - 46 / 49

    bpl .loop           ; 3 - 49/48, 52/51
    sta WSYNC

    iny
    sty GRP0
    sty GRP1
    rts
    LOG_BANK_SIZE "GANON_KERNEL_36/39", KERNEL_BOSS4_LOOP_36

KERNEL_BOSS4_LOOP_42: SUBROUTINE
    clv
KERNEL_BOSS4_LOOP_45:
.loop
    sta WSYNC
    sta ENAM0           ; 3
    stx GRP1            ; 3

    lda rPLSPR_MEM,y    ; 4
    sta GRP0            ; 3 - 13

    lda (enSpr),y       ; 5
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 10
    VSLEEP69            ;   - 42 / 45
    sta GRP1            ; 3 - 45 / 48

    lda (enMSpr),y      ; 5 - 50 / 53
    sta WSYNC
    sta ENAM1           ; 3 -  3
    sleep 10            ;   - 13

    lda (enSpr),y       ; 5 - 18
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 10
    VSLEEP69            ;   - 42 / 45
    sta GRP1            ; 3 - 45 / 48

    lda (plMSpr),y      ; 5 - 50 / 53
    dey                 ; 2 - 52 / 55

    bpl .loop           ; 3 - 55/54, 58/57
    sta WSYNC

    iny
    sty GRP0
    sty GRP1
    rts
    LOG_BANK_SIZE "GANON_KERNEL_42/45", KERNEL_BOSS4_LOOP_42

    .align $100


KERNEL_BOSS4_LOOP_48: SUBROUTINE
    clv
KERNEL_BOSS4_LOOP_51:
.loop
    sta WSYNC
    sta ENAM0           ; 3
    stx GRP1            ; 3

    lda rPLSPR_MEM,y    ; 4
    sta GRP0            ; 3 - 13

    lda (enSpr),y       ; 5
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 16
    VSLEEP69            ;   - 42 / 45
    sta GRP1            ; 3 - 45 / 48

    lda (enMSpr),y      ; 5 - 50 / 53
    sta WSYNC
    sta ENAM1           ; 3 -  3
    sleep 10            ;   - 13

    lda (enSpr),y       ; 5 - 18
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 16
    VSLEEP69            ;   - 42 / 45
    sta GRP1            ; 3 - 45 / 48

    lda (plMSpr),y      ; 5 - 50 / 53
    dey                 ; 2 - 52 / 55

    bpl .loop           ; 3 - 55/54, 58/57
    sta WSYNC

    iny
    sty GRP0
    sty GRP1
    rts
    LOG_BANK_SIZE "GANON_KERNEL_48/51", KERNEL_BOSS4_LOOP_48

KERNEL_BOSS4_LOOP_54: SUBROUTINE
    clv
KERNEL_BOSS4_LOOP_57:
.loop
    sta WSYNC
    sta ENAM0           ; 3
    stx GRP1            ; 3

    lda rPLSPR_MEM,y    ; 4
    sta GRP0            ; 3 - 13

    lda (enSpr),y       ; 5
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 22
    VSLEEP69            ;   - 42 / 45
    sta GRP1            ; 3 - 45 / 48

    lda (enMSpr),y      ; 5 - 50 / 53
    sta WSYNC
    sta ENAM1           ; 3 -  3
    sleep 10            ;   - 13

    lda (enSpr),y       ; 5 - 18
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 22
    VSLEEP69            ;   - 42 / 45
    sta GRP1            ; 3 - 45 / 48

    lda (plMSpr),y      ; 5 - 50 / 53
    dey                 ; 2 - 52 / 55

    bpl .loop           ; 3 - 55/54, 58/57
    sta WSYNC

    iny
    sty GRP0
    sty GRP1
    rts
    LOG_BANK_SIZE "GANON_KERNEL_54/57", KERNEL_BOSS4_LOOP_54