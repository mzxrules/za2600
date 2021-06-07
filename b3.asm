;==============================================================================
; mzxrules 2021
; TextKernel is based on text24.asm
; https://atariage.com/forums/topic/317782-text-kernel-approaches/
;==============================================================================
TextKernel: SUBROUTINE
    sta WSYNC ; Scanlines 56 to 97 (3116) (TIM64T 48)
    lda #49
    sta TIM64T
; start
    lda #6
    sta NUSIZ0
    sta NUSIZ1
    lda #$0F
    sta COLUP0
    sta COLUP1
    lda #1
    sta VDELP0
    sta VDELP1
    
TextSetPosition: SUBROUTINE
    lda Frame
    and #1
    beq .position_frame_1
        lda #32
        ldx #0
        jsr SetHorizPos
        lda #48
        ldx #1
        jsr SetHorizPos
        jmp .end_position
    
.position_frame_1    
        lda #40
        ldx #0
        jsr SetHorizPos
        lda #56
        ldx #1
        jsr SetHorizPos
.end_position

    sta WSYNC
    sta HMOVE
    
    lda #$FE
    sta TextLoop

TextDisplayLoop:
.SetVFlag
    inc TextLoop
    inc TextLoop
    lda Frame
    and #$01        ; a ==   x1
    eor #1
    ora TextLoop    ; a ==   11
    ora mesgId      ; a == 1111
    tax
    lda MesgAL,x
    sta TMesgPtr
    lda MesgAH,x
    sta TMesgPtr+1

    clv ; Overflow stores text a/b
    ldy #11
    lda Frame
    and #1
    bne .loadTextLoop
    bit .SetVFlag
    
.loadTextLoop
    lda (TMesgPtr),y
    sta Text0,y
    dey
    bpl .loadTextLoop

.drawtext
    ldx Text0
    lda left_text,x
    ldx Text1
    ora right_text,x
    ldy #0
Frame0Text
    ; Text line 1 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx Text2               ; 4     (13)
    lda left_text,x         ; 4     (17)
    ldx Text3               ; 4     (21)
    ora right_text,x        ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)
    
    ldx Text4               ; 4     (32)
    lda left_text,x         ; 4     (36)
    ldx Text5               ; 4     (40)
    ora right_text,x        ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)
    
    ldx Text6               ; 4     (51)
    lda left_text,x         ; 4     (55)
    ldx Text7               ; 4     (59)
    ora right_text,x        ; 4     (63)
    
    ldy #$0F                ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)
    
    ;line 2
    sta WSYNC               ; 3     (0)

    ldx Text8               ; 4     (4)
    lda left_text,x         ; 4     (8)
    ldx Text9               ; 4     (12)
    ora right_text,x        ; 4     (16)
    sta Temp                ; 3     (19)

    ldx Text10              ; 4     (23*)
    lda left_text,x         ; 4     (27)
    ldx Text11              ; 4     (31)
    ora right_text,x        ; 4     (35)
    
    ldx Temp                ; 3     (38)
    VSLEEP;sleep 4
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx Text0               ; 3     (58)
    lda left_text+1,x       ; 4     (62)
    ldx Text1               ; 3     (65)
    ora right_text+1,x      ; 4     (69)

    ; Text line 2 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx Text2               ; 4     (13)
    lda left_text+1,x       ; 4     (17)
    ldx Text3               ; 4     (21)
    ora right_text+1,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)
    
    ldx Text4               ; 4     (32)
    lda left_text+1,x       ; 4     (36)
    ldx Text5               ; 4     (40)
    ora right_text+1,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)
    
    ldx Text6               ; 4     (51)
    lda left_text+1,x       ; 4     (55)
    ldx Text7               ; 4     (59)
    ora right_text+1,x      ; 4     (63)
    
    ldy #$0F                ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)
    
    ;line 2
    sta WSYNC               ; 3     (0)

    ldx Text8               ; 4     (4)
    lda left_text+1,x       ; 4     (8)
    ldx Text9               ; 4     (12)
    ora right_text+1,x      ; 4     (16)
    sta Temp                ; 3     (19)

    ldx Text10              ; 4     (23*)
    lda left_text+1,x       ; 4     (27)
    ldx Text11              ; 4     (31)
    ora right_text+1,x      ; 4     (35)
    
    ldx Temp                ; 3     (38)
    VSLEEP;sleep 4
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx Text0               ; 3     (58)
    lda left_text+2,x       ; 4     (62)
    ldx Text1               ; 3     (65)
    ora right_text+2,x      ; 4     (69)

    ; Text line 3 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx Text2               ; 4     (13)
    lda left_text+2,x       ; 4     (17)
    ldx Text3               ; 4     (21)
    ora right_text+2,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)
    
    ldx Text4               ; 4     (32)
    lda left_text+2,x       ; 4     (36)
    ldx Text5               ; 4     (40)
    ora right_text+2,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)
    
    ldx Text6               ; 4     (51)
    lda left_text+2,x       ; 4     (55)
    ldx Text7               ; 4     (59)
    ora right_text+2,x      ; 4     (63)
    
    ldy #$0F                ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)
    
    ;line 2
    sta WSYNC               ; 3     (0)

    ldx Text8               ; 4     (4)
    lda left_text+2,x       ; 4     (8)
    ldx Text9               ; 4     (12)
    ora right_text+2,x      ; 4     (16)
    sta Temp                ; 3     (19)

    ldx Text10              ; 4     (23*)
    lda left_text+2,x       ; 4     (27)
    ldx Text11              ; 4     (31)
    ora right_text+2,x      ; 4     (35)
    
    ldx Temp                ; 3     (38)
    VSLEEP; sleep 4
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx Text0               ; 3     (58)
    lda left_text+3,x       ; 4     (62)
    ldx Text1               ; 3     (65)
    ora right_text+3,x      ; 4     (69)

    ; Text line 4 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx Text2               ; 4     (13)
    lda left_text+3,x       ; 4     (17)
    ldx Text3               ; 4     (21)
    ora right_text+3,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)
    
    ldx Text4               ; 4     (32)
    lda left_text+3,x       ; 4     (36)
    ldx Text5               ; 4     (40)
    ora right_text+3,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)
    
    ldx Text6               ; 4     (51)
    lda left_text+3,x       ; 4     (55)
    ldx Text7               ; 4     (59)
    ora right_text+3,x      ; 4     (63)
    
    ldy #$0F                ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)
    
    ;line 2
    sta WSYNC               ; 3     (0)

    ldx Text8               ; 4     (4)
    lda left_text+3,x       ; 4     (8)
    ldx Text9               ; 4     (12)
    ora right_text+3,x      ; 4     (16)
    sta Temp                ; 3     (19)

    ldx Text10              ; 4     (23*)
    lda left_text+3,x       ; 4     (27)
    ldx Text11              ; 4     (31)
    ora right_text+3,x      ; 4     (35)
    
    ldx Temp                ; 3     (38)
    VSLEEP; sleep 4
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx Text0               ; 3     (58)
    lda left_text+4,x       ; 4     (62)
    ldx Text1               ; 3     (65)
    ora right_text+4,x      ; 4     (69)

    ; Text line 5 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx Text2               ; 4     (13)
    lda left_text+4,x       ; 4     (17)
    ldx Text3               ; 4     (21)
    ora right_text+4,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)
    
    ldx Text4               ; 4     (32)
    lda left_text+4,x       ; 4     (36)
    ldx Text5               ; 4     (40)
    ora right_text+4,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)
    
    ldx Text6               ; 4     (51)
    lda left_text+4,x       ; 4     (55)
    ldx Text7               ; 4     (59)
    ora right_text+4,x      ; 4     (63)
    
    ldy #$0F                ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)
    
    ;line 2
    sta WSYNC               ; 3     (0)

    ldx Text8               ; 4     (4)
    lda left_text+4,x       ; 4     (8)
    ldx Text9               ; 4     (12)
    ora right_text+4,x      ; 4     (16)
    sta Temp                ; 3     (19)

    ldx Text10              ; 4     (23*)
    lda left_text+4,x       ; 4     (27)
    ldx Text11              ; 4     (31)
    ora right_text+4,x      ; 4     (35)
    
    ldx Temp                ; 3     (38)
    VSLEEP; sleep 4
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
    
    lda TextLoop
    bne .end
    jmp TextDisplayLoop
    
.end
    lda #0
    sta VDELP0
    sta VDELP1
    sta GRP0
    sta GRP1
    sta GRP0
    
    lda #COLOR_PLAYER_00
    sta COLUP0
    jsr PosWorldObjects
    
.waitTimerLoop
    lda INTIM
    bne .waitTimerLoop
    ldy TEXT_ROOM_HEIGHT
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