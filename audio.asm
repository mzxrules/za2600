    processor 6502
    INCLUDE "vcs.h"
    INCLUDE "macro.h"

; ****************************************
; * Variables                            *
; ****************************************

    SEG.U VARS
    ORG $80
Frame       ds 1
SeqFlag     ds 1
SWCHA_last  ds 1
Tone        ds 1
Freq        ds 1
Vol         ds 1
songLen     ds 2
seq0Notes   ds 2
seq1Notes   ds 2
seq0Durs    ds 2
seq1Durs    ds 2
songCur     ds 2
songTFrame  ds 2
Cool        ds 1


; ****************************************
; * Constants                            *
; ****************************************

CHAN_1_OFF = 16

    echo "-RAM-",$80,(.)

    SEG CODE
    ORG $F000

ENTRY:
    CLEAN_START

INIT:
    ; set player colors
    lda #$C4
    sta COLUP0
    lda #$74
    sta COLUP1

    ; set bgColor
    lda #$00
    sta COLUBK
    lda #%0001001
    sta Cool

    ; set playfield
    lda #$0E
    sta COLUPF

    lda #%00000001
    sta CTRLPF
    lda #8
    sta Vol
    lda #$87
    sta SeqFlag


;TOP_FRAME ;3 37 192 30
VERTICAL_SYNC: ; 3 SCANLINES
    lda #2
    ldx #49
    sta WSYNC
    sta VSYNC
    stx TIM64T ; 41 scanline timer
    inc Frame
    sta WSYNC
    sta WSYNC
    lda #0      ; LoaD Accumulator with 0 so D1=0
    ;sta PF0     ; blank the playfield
    sta PF1
    sta PF2
    sta GRP0    ; blanks player0 if VDELP0 was off
    sta GRP1    ; blanks player0 if VDELP0 was on, player1 if VDELP1 was off
    sta GRP0    ; blanks                           player1 if VDELP1 was on
    sta WSYNC
    sta VSYNC

VERTICAL_BLANK: SUBROUTINE ; 37 SCANLINES
    jsr ProcessInput
    lda Cool
    sta COLUPF
    ;rol
    adc #0
    sta Cool

    bit SeqFlag
    bpl .ChangeSeqEnd
    lda SeqFlag
    and #$7F
    sta SeqFlag
    and #$0F
    pha
    tay
    ldx #0
    jsr SetSeqChannel
    pla
    ora #CHAN_1_OFF
    tay
    ldx #2
    jsr SetSeqChannel

    lda Frame
    sta songTFrame
    sta songTFrame+1
    lda #$FF
    sta songCur
    sta songCur+1
.ChangeSeqEnd

    ldx Frame
    cpx songTFrame
    bne .skipNoteChange0
    jsr UpdateSong0
    jmp .Channel1
.skipNoteChange0
    inx
    cpx songTFrame
    bne .Channel1
    ldy #0
    jsr MuteChannel
.Channel1
    ldx Frame
    cpx songTFrame+1
    bne .skipNoteChange1
    jsr UpdateSong1
    jmp .end
.skipNoteChange1
    inx
    cpx songTFrame+1
    bne .end
    ldy #1
    jsr MuteChannel
.end

KERNEL_MAIN:  ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN
    sta VBLANK
    ;lda #7
    ;sta AUDV0


    ;lda #0
    ;ldx #7
    ldy #192
KERNEL_LOOP: SUBROUTINE ;-59

    lda Cool
    sta PF1
    sta WSYNC
    dey
    bne KERNEL_LOOP

OVERSCAN: ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer

OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne OVERSCAN_WAIT

    jmp VERTICAL_SYNC

ProcessInput: SUBROUTINE
_ = .
    bit SWCHA_last
    bpl .finalUpdate
    bvc .finalUpdate

    bit SWCHA
    bvc .leftPressed
    bmi .finalUpdate
    lda SeqFlag
    clc
    adc #1
    and #CHAN_1_OFF-1
    ora #$80
    sta SeqFlag
    bmi .finalUpdate

.leftPressed
    lda SeqFlag
    sec
    sbc #1
    and #CHAN_1_OFF-1
    ora #$80
    sta SeqFlag

.finalUpdate
    lda SWCHA
    sta SWCHA_last
    rts
    echo "Input Size ",(.-_)

SetSeqChannel: SUBROUTINE
    lda SeqL_note,y
    sta seq0Notes,x
    lda SeqH_note,y
    sta seq0Notes+1,x
    lda SeqL_dur,y
    sta seq0Durs,x
    lda SeqH_dur,y
    sta seq0Durs+1,x

    txa
    lsr
    tax
    lda ms_header,y
    sta songLen,x
    rts

;===============================================================================
; PosObject
;----------
; subroutine for setting the X position of any TIA object
; when called, set the following registers:
;   A - holds the X position of the object
;   X - holds which object to position
;       0 = player0
;       1 = player1
;       2 = missile0
;       3 = missile1
;       4 = ball
; the routine will set the coarse X position of the object, as well as the
; fine-tune register that will be used when HMOVE is used.
;===============================================================================
PosObject:
        sec
        sta WSYNC
DivideLoop
        sbc #15        ; 2  2 - each time thru this loop takes 5 cycles, which is
        bcs DivideLoop ; 2  4 - the same amount of time it takes to draw 15 pixels
        eor #7         ; 2  6 - The EOR & ASL statements convert the remainder
        asl            ; 2  8 - of position/15 to the value needed to fine tune
        asl            ; 2 10 - the X position
        asl            ; 2 12
        asl            ; 2 14
        sta.wx HMP0,X  ; 5 19 - store fine tuning of X
        sta RESP0,X    ; 4 23 - set coarse X position of object
        rts            ; 6 29

MuteChannel: SUBROUTINE
    lda #0
    sta AUDF0,y
    sta AUDC0,y
    rts

UpdateSong0: SUBROUTINE
    lda #2
    sta AUDV0
    inc songCur
    lda songCur
    cmp songLen
    bne .skipResetSongCur
    lda #0
    sta songCur
.skipResetSongCur
    tay
    lda (seq0Notes),y
    pha
    lsr
    lsr
    lsr
    sta AUDF0
    pla
    and #7
    tax
    lda ToneLookup,x
    sta AUDC0
    lda (seq0Durs),y
    clc
    adc Frame
    sta songTFrame
    rts

UpdateSong1: SUBROUTINE
    lda #1
    sta AUDV0+1
    inc songCur+1
    lda songCur+1
    cmp songLen+1
    bne .skipResetSongCur
    lda #0
    sta songCur+1
.skipResetSongCur
    tay
    lda (seq1Notes),y
    pha
    lsr
    lsr
    lsr
    sta AUDF0+1
    pla
    and #7
    tax
    lda ToneLookup,x
    sta AUDC0+1
    lda (seq1Durs),Y
    clc
    adc Frame
    sta songTFrame+1
    rts

AUDTEST: SUBROUTINE
    and #1
    beq .Tone12
    lda #4
    sta AUDC0
    lda #5
    sta AUDF0
    rts
.Tone12
    lda #12
    sta AUDC0
    lda #1
    sta AUDF0
    rts

    ;lda Freq
    ;ldx Tone
    ;ldy Vol
    ;sta AUDF0
    ;stx AUDC0
    ;sty AUDV0


ToneLookup
    .byte 0, 1, 4, 6, 12

SeqH_note
    .byte #>ms_none_note, #>ms_dung0_note, #>ms_gi0_note, #>ms_over0_note, #>ms_intro0_note, #>ms_world0_note, #>ms_none_note, #>ms_tri0_note
    .byte 0, 0, 0, 0, 0, 0, 0, 0
    .byte #>ms_none_note, #>ms_dung1_note, #>ms_gi1_note, #>ms_over1_note, #>ms_intro1_note, #>ms_world1_note, #>ms_none_note, #>ms_tri1_note
    .byte 0, 0, 0, 0, 0, 0, 0, 0

SeqL_note
    .byte #<ms_none_note, #<ms_dung0_note, #<ms_gi0_note, #<ms_over0_note, #<ms_intro0_note, #<ms_world0_note, #<ms_none_note, #<ms_tri0_note
    .byte 0, 0, 0, 0, 0, 0, 0, 0
    .byte #<ms_none_note, #<ms_dung1_note, #<ms_gi1_note, #<ms_over1_note, #<ms_intro1_note, #<ms_world1_note, #<ms_none_note, #<ms_tri1_note
    .byte 0, 0, 0, 0, 0, 0, 0, 0


SeqH_dur
    .byte #>ms_none_dur, #>ms_dung0_dur, #>ms_gi0_dur, #>ms_over0_dur, #>ms_intro0_dur, #>ms_world0_dur, #>ms_none_dur, #>ms_tri0_dur
    .byte 0, 0, 0, 0, 0, 0, 0, 0
    .byte #>ms_none_dur, #>ms_dung1_dur, #>ms_gi1_dur, #>ms_over1_dur, #>ms_intro1_dur, #>ms_world1_dur, #>ms_none_dur, #>ms_tri1_dur
    .byte 0, 0, 0, 0, 0, 0, 0, 0

SeqL_dur
    .byte #<ms_none_dur, #<ms_dung0_dur, #<ms_gi0_dur, #<ms_over0_dur, #<ms_intro0_dur, #<ms_world0_dur, #<ms_none_dur, #<ms_tri0_dur
    .byte 0, 0, 0, 0, 0, 0, 0, 0
    .byte #<ms_none_dur, #<ms_dung1_dur, #<ms_gi1_dur, #<ms_over1_dur, #<ms_intro1_dur, #<ms_world1_dur, #<ms_none_dur, #<ms_tri1_dur
    .byte 0, 0, 0, 0, 0, 0, 0, 0

ms_none_note:
ms_none_dur:
    .byte 0
    align 256
    include "gen/ms_dung0_note.asm"
    include "gen/ms_dung0_dur.asm"
    include "gen/ms_dung1_note.asm"
    include "gen/ms_dung1_dur.asm"
    include "gen/ms_gi0_note.asm"
    include "gen/ms_gi0_dur.asm"
    include "gen/ms_gi1_note.asm"
    include "gen/ms_gi1_dur.asm"
    include "gen/ms_over0_note.asm"
    include "gen/ms_over1_note.asm"
    include "gen/ms_over0_dur.asm"
    include "gen/ms_over1_dur.asm"
    include "gen/ms_world0_note.asm"
    include "gen/ms_world1_note.asm"
    include "gen/ms_world0_dur.asm"
    include "gen/ms_world1_dur.asm"
    include "gen/ms_intro0_note.asm"
    include "gen/ms_intro1_note.asm"
    include "gen/ms_intro0_dur.asm"
    include "gen/ms_intro1_dur.asm"
    include "gen/ms_tri0_note.asm"
    include "gen/ms_tri0_dur.asm"
    include "gen/ms_tri1_note.asm"
    include "gen/ms_tri1_dur.asm"
    include "gen/ms_header.asm"
    echo "-CODE-",$F000,(.)


    ORG $FFFA             ; Cart config (so 6507 can start it up).
                          ;
                          ; This address will make DASM build a 4K cart image.
                          ; Since the code actually takes < 300 bytes, you can
                          ; replace with ORG $F7FA to build a 2K image. Such
                          ; carts are wired to mirror their contents, so the
                          ; CPU will pick up the config at the same address.
                          ;
                          ; You can even make it 1K with ORG $F3FA, but I'm
                          ; not sure 1K carts were ever manufactured. Stella
                          ; plays them fine, but YMMV on Supercharger and
                          ; other hardware/emulators.

    .WORD ENTRY ; NMI
    .WORD ENTRY ; RESET
    .WORD ENTRY ; IRQ

    END