;==============================================================================
; mzxrules 2022
;==============================================================================
BlSystem:
    ldx blType
BallDel:
    lda BallH,x
    pha
    lda BallL,x
    pha
BlNone:
    rts

UpdateRoomPush: SUBROUTINE ; CRITICAL, execute in 1 scanline
                        ;       14
    lda roomPush        ; 3     17
    bmi .move_action    ; 2/4   19 21
    eor plDir           ; 3     22
    and #3              ; 2     24
    bne .dont_push      ; 2/4   26 28

    bit CXP0FB          ; 3     29
    bmi .push           ; 2/4   31 33
    bvs .push           ; 2/3   33 34

.dont_push              ;       33 28
    lda plDir           ; 3     36
    and #3              ; 2     38
    sta roomPush        ; 3     41
    bpl .end_push ; jmp ; 3     44

.push                   ;       34 33
    lda roomPush        ; 3     37 36
    cmp #[30<<2]        ; 2     39 38
    bpl .end_push       ; 2/3   41 40 / 42 41
    clc                 ; 2     43
    adc #4              ; 2     45
    sta roomPush        ; 3     48
    bpl .end_push ; jmp ; 3     51

.move_action            ;       ** 21
    inc roomPush
.end_push
    ; Worst Case 51 cycles

; Update RoomTimer
    lda roomTimer
    cmp #1
    adc #0
    sta roomTimer

    sta WSYNC
    jmp MAIN_VERTICAL_SYNC


BlR: SUBROUTINE
    inc blX
    rts
BlL:
    dec blX
    rts
BlU:
    inc blY
    rts
BlD:
    dec blY
    rts

BlPathPushBlock: SUBROUTINE
    ldx roomENCount
    bne .rts

    lda rPF1RoomL + 6
    and #~$0C
    sta wPF1RoomL + 6
    sta wPF1RoomL + 7

    ldx #$14
    stx blX
    ldx #$20
    stx blY
    lda #BL_PUSH_BLOCK
    sta blType
.rts
    rts

BlPushBlockLeft: SUBROUTINE
    ldx roomENCount
    bne .rts

    ldy #1
.loop
    lda rPF1RoomL+9,y
    and #$FC
    sta wPF1RoomL+9,y
    dey
    bpl .loop

    ldx #$1C
    stx blX
    ldx #$2C
    stx blY
    lda #BL_PUSH_BLOCK
    sta blType
.rts
    rts

BlPushBlockDiamondTop: SUBROUTINE
    ldx roomENCount
    bne .rts
    lda #0
    sta wPF2Room + 13
    sta wPF2Room + 14

    ldx #$40
    stx blX
    lda #$3C
    sta blY
    lda #BL_PUSH_BLOCK
    sta blType
    rts

BlPushBlockArrow:
BlPushBlock: ; SUBROUTINE
    ldx roomENCount
    bne .rts

    lda roomPush
    bmi .sliding

    bit CXP0FB
    bvc .rts ; is not pushing block

    cmp #[12 << 2]
    bcc .rts ; has not pushed long enough

    and #3
    cmp plDir
    bne .rts

    ldx blType
    cpx #BL_PUSH_BLOCK_ARROW
    bne .start_sliding
    cmp #PL_DIR_R
    bne .rts

.start_sliding
    sta blDir
    lda #-16 -1 ; Will decrement 1
    sta roomPush
    lda #SEQ_SOLVE_DUR
    sta SeqSolveCur
.rts
    rts
.sliding
    lda roomPush
    cmp #$FF
    beq BlPushEnd
    and #1
    bne .rts
    ldx blDir
    inx
    jmp BallDel

BlPushBlockWaterfall: SUBROUTINE
    lda roomPush
    bmi .sliding

    bit CXP0FB
    bvc .rts ; is not pushing block

    cmp #[8 << 2]
    bcc .rts ; has not pushed long enough

    lda #-32 -1 ; Will decrement 1
    sta roomPush
.rts
    rts

.sliding
    lda #SFX_BOMB
    sta SfxFlags
    lda roomPush
    cmp #$FF
    beq BlPushEnd
    and #3
    bne .rts
    ldx #BL_U
    jmp BallDel

BlPushEnd:
    lda #RF_EV_CLEAR
    bit roomFlags
    bne .rts
    ora roomFlags
    sta roomFlags
    lda #BL_NONE
    sta blType
    rts