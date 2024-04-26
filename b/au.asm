;==============================================================================
; mzxrules 2021
;==============================================================================
UpdateAudio: SUBROUTINE
    lda #SLOT_F0_AU0
    sta BANK_SLOT
    lda SeqFlags
    bit SeqFlags
    bpl .continueSequence
    bvc .continueSeqSwitch

    ; Play region dependent sequence
    ldy worldId
    bne .playDungeonTheme
    ldy roomId
    ;play MS_PLAY_THEME or MS_PLAY_THEME_L depending on SeqFlag state
    bpl .continueSeqSwitch
.playNone
    lda #MS_PLAY_NONE
    bne .continueSeqSwitch
.playDungeonTheme
    lda #MS_PLAY_DUNG
    cpy #9
    bmi .continueSeqSwitch
    lda #MS_PLAY_FINAL

.continueSeqSwitch
    and #$3F
    sta SeqFlags
    lda #$FF
    ldx Frame
    sta SeqCur
    sta SeqCur + 1
    stx SeqTFrame
    stx SeqTFrame + 1
.continueSequence
    ldx #0
    jsr AudioChannel
    ldx #1
    jsr AudioChannel

.sfxStart
    lda #SLOT_F0_AU2
    sta BANK_SLOT
    lda SfxFlags
    and #$3F
    beq .sfxEnd
    bit SfxFlags
    bpl .skipResetSfx
    ldy #$FF
    sty SfxCur
.skipResetSfx
    tax
    jsr SfxDel
.sfxEnd
    ldy #5

.set_audio_loop
    lda AUDCT0,y
    sta AUDC0,y
    dey
    bpl .set_audio_loop
    rts

SfxStabPattern:
    .byte $01, $02, $03, $02, $01

SfxSurfVPattern:
    .byte 1, 1, 2, 3, 4, 5, 5, 5, 5, 4, 4, 3, 2, 1, 1, 1

SfxSurfFPattern:
    .byte 2, 2, 3, 3, 5, 5, 7, 7, 1, 1, 1, 1, 1, 1, 1, 1
    /* .byte 02, 03, 05, 07, 05, 10, 10, 10 */

SfxDelay: SUBROUTINE
    clc
    lda SeqTFrame
    adc #$30
    sta SeqTFrame
    clc
    lda SeqTFrame + 1
    adc #$30
    sta SeqTFrame + 1
    jmp SfxStop

SfxWarp: SUBROUTINE
    lda SfxCur
    bpl .continue
; SfxStop
    lda #0
    sta SfxFlags
    rts
.continue
    inc SeqTFrame
    inc SeqTFrame + 1

    ldx #0
    stx AUDVT0
    stx AUDVT1

    lsr
    lsr
    lsr
    tax
    lda ms_warp0_note,x
    jmp SeqChan0

SfxQuake: SUBROUTINE
    lda #8
    sta AUDVT1
    sta AUDCT1
    lda #17
    sta AUDFT1
    lda SfxCur
    bne SfxStop
    rts

SfxStab: SUBROUTINE
    ldx #8
    stx AUDVT1
    stx AUDCT1
    ldy SfxCur
    lda SfxStabPattern,y
    sta AUDFT1
    cpy #4
    bpl SfxStop
    rts

SfxSolve:
SfxSurf: SUBROUTINE
    ldx #8
    stx AUDCT1
    ldy SfxCur

    lda SfxSurfVPattern,y
    sta AUDVT1
    lda SfxSurfFPattern,y
    sta AUDFT1
    cpy #(SfxSurfFPattern-SfxSurfVPattern)
    bpl SfxStop
    rts

SfxShutterDoor: SUBROUTINE
SfxBomb: SUBROUTINE
    lda SfxCur
    cmp #16
    bpl SfxStop
    asl
    sta AUDFT1
    lda #8
    sta AUDVT1
    sta AUDCT1
    rts

SfxItemPickupKey: SUBROUTINE
    lda SfxCur
    cmp #8
    bpl SfxStop
    lsr
    tax
    lda #4
    sta AUDCT1
    lda #8
    sta AUDVT1
    lda .SfxPickupTone,x
    sta AUDFT1
    rts
.SfxPickupTone
    .byte 8, 8, 2, 2

SfxPlHeal:
    lda SfxCur
    cmp #9
    bpl SfxStop
    eor #$FF
    sec
    adc #18
    sta AUDFT1
    lda #4
    sta AUDCT1
    ldx #8
    stx AUDVT1
    rts

SfxItemRupee: SUBROUTINE
SfxItemPickup:
    lda SfxCur
    cmp #4
    bpl SfxStop
    lda #4
    sta AUDCT1
    ldx #8
    stx AUDVT1
    ldx #9
    stx AUDFT1
    rts

SfxStop:
    lda #0
    sta SfxFlags
    rts

SfxDef: SUBROUTINE
    lda SfxCur
    cmp #6
    bpl SfxStop
    lda #6
    sta AUDCT1
    ldx #8
    stx AUDVT1
    ldx #4
    stx AUDFT1
    rts

SfxTalk: SUBROUTINE
    lda #4
    sta AUDVT1
    lda #1
    sta AUDCT1
    lda #4
    sta AUDFT1
    bne SfxStop
    rts

SfxArrowFreq:
    .byte 2, 6, 11

SfxArrow: SUBROUTINE
    ldx SfxCur
    cpx #3
    bpl SfxStop
    lda #8
    sta AUDCT1
    lda #8
    sta AUDVT1
    lda SfxArrowFreq,x
    sta AUDFT1
    rts

SfxPlDamage: SUBROUTINE
    ldx SfxCur
    cpx #7
    bpl SfxStop
    lda SfxDamageFreq,x
    sta AUDFT1
    lda #1
    sta AUDCT1
    lda #8
    sta AUDVT1
    rts
SfxDamageFreq:
    .byte  14, 11, 8, 12, 15, 18, 19
SfxDel:
    stx SfxFlags
    inc SfxCur
    lda SfxH-1,x
    pha
    lda SfxL-1,x
    pha
    rts

; x = channel
AudioChannel: SUBROUTINE
    lda AudioMul16,x
    ora SeqFlags
    and #$1F
    sta Temp0 ; SeqId

    ; Test if next note should be played
    clv
    ldy SeqTFrame,x
    cpy Frame
    bne .skipUpdateCur
    ; Played note has changed
    inc SeqCur,x
    bit .OverflowOn
    ldy Temp0
    lda ms_header,y ; duration
.OverflowOn
    cmp SeqCur,x
    bne .skipUpdateCur
    lda #0
    sta SeqCur,x
.skipUpdateCur
    ldx Temp0
    lda MusicSeqH,x
    pha
    lda MusicSeqL,x
    pha
    rts

MsNone: SUBROUTINE
    lda #0
    sta AUDVT0
    sta AUDVT1
    rts

MsDung0: SUBROUTINE
    ldx SeqCur
    bvc .skipSetDur
    lda ms_dung0_dur,x
    clc
    adc Frame
    sta SeqTFrame
.skipSetDur
    lda ms_dung0_note,x

; A = Packed Note
SeqChan0:
    ldy #0
    beq SeqChan
SeqChan1:
    ldy #1
SeqChan:
    pha
    lsr
    lsr
    lsr
    sta AUDFT0,y
    pla
    and #7
    tax
    lda ToneLookup,x
    sta AUDCT0,y
    lda #2
    sta AUDVT0,y
    rts

MsDung1: SUBROUTINE
    ldx SeqCur + 1
    bvc .skipSetDir
    lda #$0A ;ms_dung1_dur,x
    clc
    adc Frame
    sta SeqTFrame + 1
.skipSetDir
    lda ms_dung1_note,x
    jmp SeqChan1


MsIntro0: SUBROUTINE
    ldx SeqCur
    bvc .skipSetDur
    lda ms_intro0_dur,x
    clc
    adc Frame
    sta SeqTFrame
SeqMuteChan0:
    lda #0
    sta AUDVT0
    rts
.skipSetDur
    lda ms_intro0_note,x
    jmp SeqChan0

MsIntro1: SUBROUTINE
    ldx SeqCur + 1
    bvc .skipSetDur
    lda ms_intro1_dur,x
    clc
    adc Frame
    sta SeqTFrame + 1
    cpx #23
    bne .skipSwitchSeq
    lda #MS_PLAY_THEME_L
    sta SeqFlags
.skipSwitchSeq
SeqMuteChan1:
    lda #0
    sta AUDVT1
    rts
.skipSetDur
    lda ms_intro1_note,x
    jmp SeqChan1

MsWorld0: SUBROUTINE
    ldx SeqCur
    bvc .skipSetDur
    lda ms_world0_dur,x
    clc
    adc Frame
    sta SeqTFrame
    jmp SeqMuteChan0
.skipSetDur
    lda ms_world0_note,x
    jmp SeqChan0

MsWorld1: SUBROUTINE
    ldx SeqCur + 1
    bvc .skipSetDur
    lda ms_world1_dur,x
    clc
    adc Frame
    sta SeqTFrame + 1
    jmp SeqMuteChan1
.skipSetDur
    lda ms_world1_note,x
    jmp SeqChan1

MsFinal0: SUBROUTINE
    ldx SeqCur
    bvc .skipSetDur
    lda ms_final0_dur,x
    clc
    adc Frame
    sta SeqTFrame
    jmp SeqMuteChan0
.skipSetDur
    lda ms_final0_note,x
    jmp SeqChan0

MsFinal1: SUBROUTINE
    ldx SeqCur + 1
    bvc .skipSetDur
    lda #$0C ; ms_final1_dur
    clc
    adc Frame
    sta SeqTFrame + 1
    jmp SeqMuteChan1
.skipSetDur
    txa
    lsr
    lsr
    lsr
    tax
    lda ms_final1_note,x
    jmp SeqChan1

MsTri0: SUBROUTINE
    ldx SeqCur
    bvc .skipSetDur
    lda ms_tri0_dur,x
    clc
    adc Frame
    sta SeqTFrame
.skipSetDur
    lda ms_tri0_note,x
    jmp SeqChan0

MsTri1: SUBROUTINE
    ldx SeqCur + 1
    bvc .skipSetDur
    lda ms_tri1_dur,x
    clc
    adc Frame
    sta SeqTFrame + 1
    cpx #23
    bne .skipSetDur
    lda #MS_PLAY_NONE
    sta SeqFlags
.skipSetDur
    lda ms_tri1_note,x
    jmp SeqChan1

MsGI0: SUBROUTINE
    ldx SeqCur
    bvc .skipSetDur
    lda ms_gi0_dur,x
    clc
    adc Frame
    sta SeqTFrame
.skipSetDur
    lda ms_gi0_note,x
    jmp SeqChan0

MsGI1: SUBROUTINE
    ldx SeqCur + 1
    bvc .skipSetDur
    lda ms_gi1_dur,x
    clc
    adc Frame
    sta SeqTFrame + 1
    cpx #5
    bne .skipSetDur
    lda #MS_PLAY_RSEQ_L
    sta SeqFlags
.skipSetDur
    lda ms_gi1_note,x
    jmp SeqChan1

MsOver0: SUBROUTINE
    ldx SeqCur
    bvc .skipSetDur
    lda ms_over0_dur,x
    clc
    adc Frame
    sta SeqTFrame
.skipSetDur
    lda ms_over0_note,x
    jmp SeqChan0

MsOver1: SUBROUTINE
    ldx SeqCur + 1
    bvc .skipSetDur
    lda ms_over1_dur,x
    clc
    adc Frame
    sta SeqTFrame + 1
.skipSetDur
    lda ms_over1_note,x
    jmp SeqChan1

    ;align 8
ToneLookup
    .byte 0, 1, 4, 6, 12

AudioMul16
    .byte 0, 16