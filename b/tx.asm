;==============================================================================
; mzxrules 2021
; TextKernel is based on text24.asm
; https://atariage.com/forums/topic/317782-text-kernel-approaches/
;==============================================================================
ShopKernel: BHA_BANK_FALL #SLOT_F0_SHOP

TextKernel: SUBROUTINE
    ; Scanlines 56 to 97 (3116) (TIM64T 48)
    ; assumes COLUP0, COLUP1 set to #COLOR_WHITE

    sta WSYNC
    sleep 10

    lda Frame  ; 3
    and #1     ; 2
    tay        ; 2

; start
    lda #6      ; 2
    sta NUSIZ0  ; 3
    sta NUSIZ1  ; 3
    lda #1     ; 2
    sta VDELP0 ; 3
    sta RESP0  ; 3 - 33     TIA POS #36
    nop        ; 2 - 35
    sta RESP1  ; 3 - 38     TIA POS #51
    sta VDELP1 ; 3 - 41

    lda TextSetHMP0,y
    sta HMP0 ; #32/#40
    lda TextSetHMP1,y
    sta HMP1 ; #48/#56

    sta WSYNC ; To Scanline 59
    sta HMOVE

    lda #SLOT_F4_MESG
    sta BANK_SLOT
    ldx mesgId
    lda MesgAL,x
    sta TMesgPtr
    lda MesgAH,x
    sta TMesgPtr+1

    lda #$FF
    sta TextLoop
    ; CYCLE 5
TextDisplayLoop:
    lda Frame
    ror
.SetVFlag
    inc TextLoop
    lda TextLoop
    rol
    sta WSYNC
    adc #SLOT_F4_MESG
    sta BANK_SLOT

    ldy #11
.loadTextLoop
    cpy mesgDY
    bcc .drawChar0
    lda #MESG_CHAR_SPACE
    .byte $2C
.drawChar0
    lda (TMesgPtr),y
    sta TextReg+0,y
    dey

    cpy mesgDY
    bcc .drawChar1
    lda #MESG_CHAR_SPACE
    .byte $2C
.drawChar1
    lda (TMesgPtr),y
    sta TextReg+0,y
    dey

    cpy mesgDY
    bcc .drawChar2
    lda #MESG_CHAR_SPACE
    .byte $2C
.drawChar2
    lda (TMesgPtr),y
    sta TextReg+0,y
    dey
    bpl .loadTextLoop

    clv ; Overflow stores text a/b
    lda Frame
    and #1
    eor #1
    tax
    bne .ClearVFlag
    bit .SetVFlag
.ClearVFlag

; Special case for drawing second row
    lda TextLoop
    beq .drawText
    lda rTextMode
    cmp #TEXT_MODE_SHOP
    beq .fetchShopText
    sta WSYNC ; add delay between letters
    bne .drawText ; jmp
.fetchShopText
; Set sign and digit chars for shops
    ; 12/15
    lda mesgChar+0      ; 3
    sta TextReg+1,x     ; 4
    lda mesgChar+1      ; 3
    sta TextReg+5,x     ; 4
    lda mesgChar+2      ; 3
    sta TextReg+9,x     ; 4
    cpx #0
    bne .drawText
    ; set sign chars
    lda mesgChar+3
    sta TextReg+0
    lda mesgChar+4
    sta TextReg+4
    lda mesgChar+5
    sta TextReg+8
    ; 33/36
.drawText
    ldx TextReg+0       ; 3
    lda left_text,x     ; 4
    ldx TextReg+1       ; 3
    ora right_text,x    ; 4
    ldy #0              ; 2
Frame0Text
    ; Text line 1 / 5

    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx TextReg+2           ; 4     (13)
    lda left_text,x         ; 4     (17)
    ldx TextReg+3           ; 4     (21)
    ora right_text,x        ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)

    ldx TextReg+4           ; 4     (32)
    lda left_text,x         ; 4     (36)
    ldx TextReg+5           ; 4     (40)
    ora right_text,x        ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)

    ldx TextReg+6           ; 4     (51)
    lda left_text,x         ; 4     (55)
    ldx TextReg+7           ; 4     (59)
    ora right_text,x        ; 4     (63)

    ldy #COLOR_WHITE        ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)

    ;line 2
    sta WSYNC               ; 3     (0)

    ldx TextReg+8           ; 4     (4)
    lda left_text,x         ; 4     (8)
    ldx TextReg+9           ; 4     (12)
    ora right_text,x        ; 4     (16)
    sta TextTemp            ; 3     (19)

    ldx TextReg+10          ; 4     (23*)
    lda left_text,x         ; 4     (27)
    ldx TextReg+11          ; 4     (31)
    ora right_text,x        ; 4     (35)

    ldx TextTemp            ; 3     (38)
    VSLEEP ; sleep 4 or 6
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx TextReg+0           ; 3     (58)
    lda left_text+1,x       ; 4     (62)
    ldx TextReg+1           ; 3     (65)
    ora right_text+1,x      ; 4     (69)

    ; Text line 2 / 5

    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx TextReg+2           ; 4     (13)
    lda left_text+1,x       ; 4     (17)
    ldx TextReg+3           ; 4     (21)
    ora right_text+1,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)

    ldx TextReg+4           ; 4     (32)
    lda left_text+1,x       ; 4     (36)
    ldx TextReg+5           ; 4     (40)
    ora right_text+1,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)

    ldx TextReg+6           ; 4     (51)
    lda left_text+1,x       ; 4     (55)
    ldx TextReg+7           ; 4     (59)
    ora right_text+1,x      ; 4     (63)

    ldy #COLOR_WHITE        ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)

    ;line 2
    sta WSYNC               ; 3     (0)

    ldx TextReg+8           ; 4     (4)
    lda left_text+1,x       ; 4     (8)
    ldx TextReg+9           ; 4     (12)
    ora right_text+1,x      ; 4     (16)
    sta TextTemp            ; 3     (19)

    ldx TextReg+10          ; 4     (23*)
    lda left_text+1,x       ; 4     (27)
    ldx TextReg+11          ; 4     (31)
    ora right_text+1,x      ; 4     (35)

    ldx TextTemp            ; 3     (38)
    VSLEEP ; sleep 4 or 6
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx TextReg+0           ; 3     (58)
    lda left_text+2,x       ; 4     (62)
    ldx TextReg+1           ; 3     (65)
    ora right_text+2,x      ; 4     (69)

    ; Text line 3 / 5

    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx TextReg+2           ; 4     (13)
    lda left_text+2,x       ; 4     (17)
    ldx TextReg+3           ; 4     (21)
    ora right_text+2,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)

    ldx TextReg+4           ; 4     (32)
    lda left_text+2,x       ; 4     (36)
    ldx TextReg+5           ; 4     (40)
    ora right_text+2,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)

    ldx TextReg+6           ; 4     (51)
    lda left_text+2,x       ; 4     (55)
    ldx TextReg+7           ; 4     (59)
    ora right_text+2,x      ; 4     (63)

    ldy #COLOR_WHITE        ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)

    ;line 2
    sta WSYNC               ; 3     (0)

    ldx TextReg+8           ; 4     (4)
    lda left_text+2,x       ; 4     (8)
    ldx TextReg+9           ; 4     (12)
    ora right_text+2,x      ; 4     (16)
    sta TextTemp            ; 3     (19)

    ldx TextReg+10          ; 4     (23*)
    lda left_text+2,x       ; 4     (27)
    ldx TextReg+11          ; 4     (31)
    ora right_text+2,x      ; 4     (35)

    ldx TextTemp            ; 3     (38)
    VSLEEP ; sleep 4 or 6
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx TextReg+0           ; 3     (58)
    lda left_text+3,x       ; 4     (62)
    ldx TextReg+1           ; 3     (65)
    ora right_text+3,x      ; 4     (69)

    ; Text line 4 / 5

    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx TextReg+2           ; 4     (13)
    lda left_text+3,x       ; 4     (17)
    ldx TextReg+3           ; 4     (21)
    ora right_text+3,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)

    ldx TextReg+4           ; 4     (32)
    lda left_text+3,x       ; 4     (36)
    ldx TextReg+5           ; 4     (40)
    ora right_text+3,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)

    ldx TextReg+6           ; 4     (51)
    lda left_text+3,x       ; 4     (55)
    ldx TextReg+7           ; 4     (59)
    ora right_text+3,x      ; 4     (63)

    ldy #COLOR_WHITE        ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)

    ;line 2
    sta WSYNC               ; 3     (0)

    ldx TextReg+8           ; 4     (4)
    lda left_text+3,x       ; 4     (8)
    ldx TextReg+9           ; 4     (12)
    ora right_text+3,x      ; 4     (16)
    sta TextTemp            ; 3     (19)

    ldx TextReg+10          ; 4     (23*)
    lda left_text+3,x       ; 4     (27)
    ldx TextReg+11          ; 4     (31)
    ora right_text+3,x      ; 4     (35)

    ldx TextTemp            ; 3     (38)
    VSLEEP ; sleep 4 or 6
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx TextReg+0           ; 3     (58)
    lda left_text+4,x       ; 4     (62)
    ldx TextReg+1           ; 3     (65)
    ora right_text+4,x      ; 4     (69)

    ; Text line 5 / 5

    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx TextReg+2           ; 4     (13)
    lda left_text+4,x       ; 4     (17)
    ldx TextReg+3           ; 4     (21)
    ora right_text+4,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)

    ldx TextReg+4           ; 4     (32)
    lda left_text+4,x       ; 4     (36)
    ldx TextReg+5           ; 4     (40)
    ora right_text+4,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)

    ldx TextReg+6           ; 4     (51)
    lda left_text+4,x       ; 4     (55)
    ldx TextReg+7           ; 4     (59)
    ora right_text+4,x      ; 4     (63)

    ldy #COLOR_WHITE        ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)

    ;line 2
    sta WSYNC               ; 3     (0)

    ldx TextReg+8           ; 4     (4)
    lda left_text+4,x       ; 4     (8)
    ldx TextReg+9           ; 4     (12)
    ora right_text+4,x      ; 4     (16)
    sta TextTemp            ; 3     (19)

    ldx TextReg+10          ; 4     (23*)
    lda left_text+4,x       ; 4     (27)
    ldx TextReg+11          ; 4     (31)
    ora right_text+4,x      ; 4     (35)

    ldx TextTemp            ; 3     (38)
    VSLEEP ; sleep 4 or 6
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    sta WSYNC
    lda #0
    sta GRP0
    sta GRP1
    sta GRP0

FinishVS
    sleep 13
    lda #0
    sta GRP1
    sta GRP0
    sta GRP1

    ldx TextLoop
    bne .end
    jmp TextDisplayLoop

.end
    ;lda #0
    sta VDELP0
    sta VDELP1
    sta GRP0
    sta GRP1
    sta GRP0

    ldy rTextMode
    cpy #TEXT_MODE_SHOP
    bne .worldKernelReturn
    jmp ShopKernel
.worldKernelReturn

    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT

    jmp KERNEL_WORLD_TX_RETURN

TextSetHMP0:
    .byte $40, #$C0

TextSetHMP1:
    .byte $30, #$B0

    LOG_SIZE "TextKernel", TextKernel