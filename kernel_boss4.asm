;==============================================================================
; mzxrules 2025
;==============================================================================
; ! Game Version

KERNEL_BOSS4_SETV
    .byte #$40

KERNEL_BOSS4_START:
    bit KERNEL_BOSS4_SETV
    tay

    lda rPlColor
    sta COLUP0

    lda rEnColor
    sta COLUP1

    lda rNUSIZ0_T
    sta NUSIZ0

    lda #SLOT_RW_F0_BOSS4
    sta BANK_SLOT_RAM

    ldx rGanonKernelId
    lda Boss4KernelH,x
    pha
    lda Boss4KernelL,x
    pha

    ldx #%10001
    stx NUSIZ1
    ldx #0
    stx CXCLR
    txa
    rts

KERNEL_BOSS4_LOOP_33: SUBROUTINE
.loop
    sta WSYNC
    sta ENAM0           ; 3
    stx GRP1            ; 3

    lda rPLSPR_MEM_OFF,y ; 4
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

    lda rPLMSPR_MEM_OFF,y ; 4 - 40
    dey                 ; 2 - 42

    bpl .loop           ; 3 - 45/44
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

    lda rPLSPR_MEM_OFF,y ; 4
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

    lda rPLMSPR_MEM_OFF,y ; 5 - 43 / 46
    dey                 ; 2 - 45 / 48

    bpl .loop           ; 3 - 48/47, 51/50
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

    lda rPLSPR_MEM_OFF,y ; 4
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

    lda rPLMSPR_MEM_OFF,y ; 4 - 49 / 52
    dey                 ; 2 - 51 / 54

    bpl .loop           ; 3 - 54/53, 57/56
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

    lda rPLSPR_MEM_OFF,y ; 4
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

    lda rPLMSPR_MEM_OFF,y ; 5 - 49 / 52
    dey                 ; 2 - 51 / 54

    bpl .loop           ; 3 - 54/53, 57/56
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

    lda rPLSPR_MEM_OFF,y ; 4
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

    lda rPLMSPR_MEM_OFF,y ; 4 - 49 / 52
    dey                 ; 2 - 51 / 54

    bpl .loop           ; 3 - 54/53, 57/56
    sta WSYNC

    iny
    sty GRP0
    sty GRP1
    rts
    LOG_BANK_SIZE "GANON_KERNEL_54/57", KERNEL_BOSS4_LOOP_54