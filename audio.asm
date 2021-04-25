    processor 6502
    INCLUDE "vcs.h"
    INCLUDE "macro.h"
    
; ****************************************
; * Variables                            *
; ****************************************

    SEG.U VARS
    ORG $80
Frame       ds 1
Tone        ds 1
Freq        ds 1
Vol         ds 1
songLen     ds 2
songCur     ds 2
songTFrame  ds 2
Cool        ds 1


    
; ****************************************
; * Constants                            *
; ****************************************

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
    lda ms_header
    sta songLen
    lda ms_header+1
    sta songLen+1
    lda #10
    sta songTFrame
    sta songTFrame+1
    dec songCur
    dec songCur+1
    
    
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
    
    lda Frame
    cmp songTFrame
    bne .skipNoteChange0
    jsr UpdateSong0
.skipNoteChange0
    lda Frame
    cmp songTFrame+1
    bne .skipNoteChange1
    jsr UpdateSong1
.skipNoteChange1
    
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

ProcessInput:
_ = .
    lda SWCHA
    rts
    echo "Input Size ",(.-_)
    
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
      
      
UpdateSong0: SUBROUTINE
    lda #2
    sta AUDV0
    inc songCur
    lda songCur
    cmp ms_header+0
    bne .skipResetSongCur
    lda #0
    sta songCur
.skipResetSongCur
    tax
    lda ms_dung0_note,x
    sta AUDF0
    lda ms_dung0_tone,x
    sta AUDC0
    lda ms_dung0_dur,x
    clc
    adc Frame
    sta songTFrame
    rts
    
UpdateSong1: SUBROUTINE
    lda #3
    sta AUDV0+1
    inc songCur+1
    lda songCur+1
    cmp ms_header+1
    bne .skipResetSongCur
    lda #0
    sta songCur+1
.skipResetSongCur
    tax
    lda ms_dung1_note,x
    sta AUDF0+1
    lda ms_dung1_tone,x
    sta AUDC0+1
    lda ms_dung1_dur,x
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
    
  
    align 256
    include "gen/ms_dung0_note.asm"
    include "gen/ms_dung0_tone.asm"
    include "gen/ms_dung0_dur.asm"
    include "gen/ms_dung1_note.asm"
    include "gen/ms_dung1_tone.asm"
    include "gen/ms_dung1_dur.asm"
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