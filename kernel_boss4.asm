;==============================================================================
; mzxrules 2025
;==============================================================================
; ! Game Version

KERNEL_BOSS4_START:
    bit KERNEL_BOSS4_SETV
    tay

    lda #%00010101 ; ball size 2, reflect, pf priority
    sta CTRLPF

    lda enState
    and #1
    ora #SLOT_F4_BOSS4
    sta BANK_SLOT

    lda rPlColor
    sta COLUP0

    lda rEnColor
    sta COLUP1
    sta COLUPF

    lda rNUSIZ0_T
    sta NUSIZ0

    lda #SLOT_RW_F0_BOSS4
    sta BANK_SLOT_RAM

    ldx rGanonKernelId
    lda Boss4KernelH,x

KERNEL_BOSS4_SETV
    pha
    lda Boss4KernelL,x
    pha

    ldx #%10001
    stx NUSIZ1
    ldx #0
    txa
    rts
    LOG_SIZE "KERNEL_BOSS4_START", KERNEL_BOSS4_START

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
    sta ENABL           ; 3 -  3
    sleep 10            ;   - 13

    lda (enSpr),y       ; 5 - 18
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 7             ;   - 33
    sta GRP1            ; 3 - 36

    lda rPLMSPR_MEM_OFF,y ; 4 - 40
    dey                 ; 2 - 42

    bpl .loop           ; 3 - 45/44
    jmp KERNEL_BOSS4_END

    LOG_SIZE "GANON_KERNEL_33", KERNEL_BOSS4_LOOP_33

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
    VSLEEP69_bvs        ;   - 36 / 39
    sta GRP1            ; 3 - 39 / 42

    lda (enMSpr),y      ; 5 - 44 / 45
    sta WSYNC
    sta ENABL           ; 3 -  3
    sleep 10            ;   - 13

    lda (enSpr),y       ; 5 - 18
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 4
    VSLEEP69_bvs        ;   - 36 / 39
    sta GRP1            ; 3 - 39 / 42

    lda rPLMSPR_MEM_OFF,y ; 5 - 43 / 46
    dey                 ; 2 - 45 / 48

    bpl .loop           ; 3 - 48/47, 51/50
    jmp KERNEL_BOSS4_END
    LOG_SIZE "GANON_KERNEL_36/39", KERNEL_BOSS4_LOOP_36

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
    VSLEEP69_bvs        ;   - 42 / 45
    sta GRP1            ; 3 - 45 / 48

    lda (enMSpr),y      ; 5 - 50 / 53
    sta WSYNC
    sta ENABL           ; 3 -  3
    sleep 10            ;   - 13

    lda (enSpr),y       ; 5 - 18
    sta GRP1            ; 3 - 21

    lda (enSpr2),y      ; 5 - 26
    sleep 10
    VSLEEP69_bvs        ;   - 42 / 45
    sta GRP1            ; 3 - 45 / 48

    lda rPLMSPR_MEM_OFF,y ; 4 - 49 / 52
    dey                 ; 2 - 51 / 54

    bpl .loop           ; 3 - 54/53, 57/56
    jmp KERNEL_BOSS4_END
    LOG_SIZE "GANON_KERNEL_42/45", KERNEL_BOSS4_LOOP_42
    .align $100


KERNEL_BOSS4_LOOP_48: SUBROUTINE
KERNEL_BOSS4_LOOP_54:
    clv
KERNEL_BOSS4_LOOP_51:
KERNEL_BOSS4_LOOP_57:
KERNEL_BOSS4_LOOP_60:
.loop
    sta WSYNC
    sta ENAM0           ; 3
    stx GRP1            ; 3

    lda rPLSPR_MEM_OFF,y ; 4
    sta GRP0            ; 3 - 13

    lda (enSpr),y       ; 5
    sta GRP1            ; 3 - 21

; DELAY LOGIC START
; 5-6 must hit 22 cycles (c = 0)
; 7-8 must hit 28 cycles (c = 1)

    VSLEEP69_bvs        ; + 6
; 16 cycles remain
    lda rGanonKernelId  ; + 4
    cmp #7              ; + 2

; 10 cycles remain
    bcs .c28_t13_a
; 8 cycles to death
    bcc .t5_a ; jmp
.c28_t13_a
; 13 cycles remain
    cmp #9              ; + 2
    VSLEEP69_bcs        ; + 6
.t5_a
    lda (enSpr2),y      ; + 5
    ; DELAY LOGIC END

    lda (enSpr2),y      ; + 5
; 48 / 51
    sta GRP1            ; 3 - 51 / 54 / 57 / 60 / 63

    lda (enMSpr),y      ; 5 - 50 / 53
    sta WSYNC
    sta ENABL           ; 3 -  3
    sleep 10            ;   - 13

    lda (enSpr),y       ; 5 - 18
    sta GRP1            ; 3 - 21

; DELAY LOGIC START
; 5-6 must hit 22 cycles (c = 0)
; 7-8 must hit 28 cycles (c = 1)

    VSLEEP69_bvs        ; + 6
; 16 cycles remain
    lda rGanonKernelId  ; + 4
    cmp #7              ; + 2

; 10 cycles remain
    bcs .c28_t13_b
; 8 cycles to death
    bcc .t5_b ; jmp
.c28_t13_b
; 13 cycles remain
    cmp #9              ; + 2
    VSLEEP69_bcs        ; + 6
.t5_b
    lda (enSpr2),y      ; + 5
    ; DELAY LOGIC END

    lda (enSpr2),y      ; + 5
; 48 / 51
    sta GRP1            ; 3 - 51 / 54 / 57 / 60 / 63

    lda rPLMSPR_MEM_OFF,y ; 4 - 67
    dey                 ; 2 - 69

    bpl .loop           ; 3 - 72/71
KERNEL_BOSS4_END:
    sta WSYNC

    iny ; #0
    sty GRP0
    sty GRP1
    sty CXCLR
    rts
    LOG_SIZE "GANON_KERNEL_48 to 60", KERNEL_BOSS4_LOOP_48
