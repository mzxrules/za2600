;==============================================================================
; mzxrules 2021
; TextKernel is based on text24.asm
; https://atariage.com/forums/topic/317782-text-kernel-approaches/
;==============================================================================
ShopKernel: BHA_BANK_FALL #SLOT_F0_SHOP

TextKernel: SUBROUTINE
    nop ; Scanlines 56 to 97 (3116) (TIM64T 48)
    lda #49
    sta TIM64T
; start
    lda #6
    sta NUSIZ0
    sta NUSIZ1
    lda #COLOR_WHITE
    sta COLUP0
    sta COLUP1
    lda #1
    sta VDELP0
    sta VDELP1

TextSetPosition: SUBROUTINE
    lda Frame
    and #1
    tay
    lda Mul8+4,y ; #32/#40
    ldx #0
    jsr SetHorizPos
    lda Mul8+6,y ; #48/#56
    inx
    jsr SetHorizPos

    sta WSYNC ; To Scanline 59
    sta HMOVE

    lda #$FE
    sta TextLoop

TextDisplayLoop:
    sta WSYNC
.SetVFlag
    inc TextLoop
    inc TextLoop
    lda Frame
    and #1
    ora TextLoop
    clc
    adc #SLOT_F4_MESG
    sta BANK_SLOT
    ldx mesgId
    lda MesgAL,x
    sta TMesgPtr
    lda MesgAH,x
    sta TMesgPtr+1

    clv ; Overflow stores text a/b
    ldy #11
    lda Frame
    and #1
    eor #1
    tax
    bne .loadTextLoop
    bit .SetVFlag

.loadTextLoop
    lda (TMesgPtr),y
    sta TextReg+0,y
    dey
    bpl .loadTextLoop

    lda #2
    cmp KernelId
    bne .drawText
    cmp TextLoop
    bne .drawText

    ldy shopDigit+0
    lda MesgDigits,y
    sta TextReg+1,x
    ldy shopDigit+1
    lda MesgDigits,y
    sta TextReg+5,x
    ldy shopDigit+2
    lda MesgDigits,y
    sta TextReg+9,x

.drawText
    ldx TextReg+0
    lda left_text,x
    ldx TextReg+1
    ora right_text,x
    ldy #0
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
    VSLEEP;sleep 4
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
    VSLEEP;sleep 4
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
    VSLEEP; sleep 4
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
    VSLEEP; sleep 4
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

    ldy KernelId
    cpy #2
    bne .worldKernelReturn
    jmp ShopKernel
.worldKernelReturn

    jsr PosWorldObjects

.waitTimerLoop
    lda INTIM
    bne .waitTimerLoop
    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    ldy #TEXT_ROOM_HEIGHT
    sta WSYNC ; 95

    jmp KERNEL_WORLD_RESUME

SetHorizPos: SUBROUTINE
    sta WSYNC   ; start a new line
    bit 0       ; waste 3 cycles
    sec     ; set carry flag
.DivideLoop
    sbc #15     ; subtract 15
    bcs .DivideLoop  ; branch until negative
    eor #7      ; calculate fine offset
    asl
    asl
    asl
    asl
    sta RESP0,x ; fix coarse position
    sta HMP0,x  ; set fine offset
    rts     ; return to caller

    LOG_SIZE "TextKernel", TextKernel