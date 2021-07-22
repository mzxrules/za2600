;==============================================================================
; mzxrules 2021
;==============================================================================
UpdateAudio_B5: SUBROUTINE
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
    
SfxStop:
    lda #0
    sta SfxFlags
    rts
    
SfxSurf: SUBROUTINE
    ldx #8
    stx AUDCT1
    ldy SfxCur
    
    lda SfxSurfVPattern,y
    sta AUDVT1
    lda SfxSurfFPattern,y
    sta AUDFT1
    cpy #(SfxSurf-SfxSurfFPattern)
    bpl SfxStop
    rts
    
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
    
SfxItemPickup: SUBROUTINE
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
    
SfxDef: SUBROUTINE
    lda SfxCur
    cmp #4
    bpl SfxStop
    lda #6
    sta AUDCT1
    ldx #8
    stx AUDVT1
    ldx #4
    stx AUDFT1
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
    
SfxPlHeal:
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
    lda Mul8,x
    ora SeqFlags
    and #$0F  
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
    
SeqMuteChan0:
    ldy #0
    beq SeqMuteChan
SeqMuteChan1:
    ldy #1
SeqMuteChan:
    lda #0
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
    jmp SeqMuteChan0
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
    cpx #24
    bne .skipSwitchSeq
    lda #MS_PLAY_THEME_L
    sta SeqFlags
.skipSwitchSeq
    jmp SeqMuteChan1
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
    lda #$0C
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