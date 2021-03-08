    processor 6502
    INCLUDE "vcs.h"
    INCLUDE "macro.h"
    
; ****************************************
; * Variables                            *
; ****************************************

    SEG.U VARS
    ORG $80
Frame       ds 1
plX         ds 1
plXL        ds 1
enX         ds 1
plY         ds 1
plYL        ds 1
enY         ds 1
plDY        ds 1
enDY        ds 1    
plSpr       ds 2
enSpr       ds 2
plSprOff    ds 1
enSprOff    ds 1
bgColor     ds 1
pfRoom      ds 1
pfSpr       ds 2
plLastDir   ds 1

    
; ****************************************
; * Constants                            *
; ****************************************

ROOM_PX_HEIGHT      = 22 ; height of room in pixels
PLAY_HEIGHT         = [(8*ROOM_PX_HEIGHT)/2-1] ; Screen visible height of play
GRID_STEP           = 4 ; unit grid that the player should snap to

BoardXL = $10
BoardXR = $8A
BoardYU = $58
BoardYD = $05

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
    sta bgColor 
    
    ; set playfield
    lda #$0E
    sta COLUPF
    
    lda #%00000001
    sta CTRLPF
    
    lda #$20
    sta plX
    sta plY
    sta plXL
    sta plYL
    sta enX
    sta enY
    
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
    ;sta GRP0    ; blanks player0 if VDELP0 was off
    ;sta GRP1    ; blanks player0 if VDELP0 was on, player1 if VDELP1 was off 
    ;sta GRP0    ; blanks                           player1 if VDELP1 was on
    sta WSYNC
    sta VSYNC
    
VERTICAL_BLANK: SUBROUTINE ; 37 SCANLINES
    jsr ProcessInput
    lda plX
    sta enX
    lda plY
    sta enY
    sta CXCLR
    lda #1
    ;sta VDELP0
    sta VDELP1
    
.NoDelayP0
    ; player draw height
    lda #(PLAY_HEIGHT+8)
    sec
    sbc plY
    sta plDY
    
    ; player sprite setup
    lda #<(SprP0 + 7) ; Sprite + height-1
    clc
    adc plSprOff
    sec ; set Carry
    sbc plY
    sta plSpr
    
    lda #>(SprP0 + 7)
    sbc #0
    sta plSpr+1
    
    lda plX
    ldx #0
    
    jsr PosObject
    
    lda Frame
    and #8
    sta enSprOff
    lda Frame
    and #$10
    ;bne .enTestmove
    ;inc enX
    ;.byte 0x2C
;.enTestmove:    
    ;inc enX
    lda enX
    cmp #BoardXR
    bne .enMoveReset
    lda #BoardXL
    sta enX
.enMoveReset
    
; test player board bounds
    lda plX
    ldy plY
    cmp #BoardXR
    bne .plXRSkip
    ldx #BoardXL+1
    stx plX
.plXRSkip
    cmp #BoardXL
    bne .plXLSkip
    ldx #BoardXR-1
    stx plX
.plXLSkip
    cpy #BoardYU
    bne .plYUSkip
    ldx #BoardYD+1
    stx plY
.plYUSkip
    cpy #BoardYD
    bne .plYDSkip
    ldx #BoardYU-1
    stx plY
.plYDSkip
    
    ; enemy draw height
    lda #(PLAY_HEIGHT+8)
    sec
    sbc enY
    sta enDY
    
    ; enemy sprite setup
    lda #<(SprE0 + 7)
    clc
    adc enSprOff
    sec
    sbc enY
    sta enSpr
    
    lda #>(SprE0 + 7)
    sbc #0
    sta enSpr+1
    lda enX
    ldx #1
    jsr PosObject
    
    ; room setup
    ldy pfRoom
    lda #ROOM_PX_HEIGHT-1
.pfSprLoop
    cpy #0
    beq .pfSprLoopEnd
    clc
    adc #ROOM_PX_HEIGHT
    dey
    jmp .pfSprLoop
.pfSprLoopEnd
    sta pfSpr
    
    lda bgColor
    sta COLUBK
    
    sta WSYNC
    sta HMOVE
    
    ldx #0
    
KERNEL_MAIN: SUBROUTINE ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN
    sta VBLANK
    
    ldy #PLAY_HEIGHT
    sta WSYNC
    
; prep Player    
/*    
    lda #7 ;player height
    dcp plDY
    bcs .DrawP0_pre
    lda #0
    .byte $2C ; BIT compare hack to skip 2 byte op
    
.DrawP0_pre:
    lda (plSpr),y
*/
    
KERNEL_LOOP: SUBROUTINE
    stx GRP0        ; 3
    
    ldx pfSpr       ; 3
    lda PF1Room0,x  ; 4
    sta PF1         ; 3
    lda PF2Room0,x  ; 4
    sta PF2         ; 3

; Enemy
    lda #7 ; enemy height
    dcp enDY
    bcs .DrawE0
    lda #0
    .byte $2C ; BIT compare hack to skip 2 byte op
.DrawE0:
    lda (enSpr),y
    sta WSYNC
    sta GRP1

; Player  
    lda #7 ;player height
    dcp plDY
    bcs .DrawP0
    lda #0
    .byte $2C ; BIT compare hack to skip 2 byte op
.DrawP0:
    lda (plSpr),y
    tax
    
; Playfield
    tya
    and #3
    beq .skipPFDec
    .byte $2C
.skipPFDec
    dec pfSpr

    sta WSYNC
    
    dey
    bpl KERNEL_LOOP
    
KERNEL_PAD: SUBROUTINE
    lda #0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1
    lda #2
    sta COLUBK
    ldy #16
.loop:
    sta WSYNC
    dey
    bpl .loop
    
OVERSCAN: ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer
    
    lda CXPPMM
    and #$80
    beq SkipPlayerEnemyCollision
    ;lda #$30
    ;sta plX
    ;sta plY
SkipPlayerEnemyCollision:
    lda CXP0FB
    and #$80
    beq SkipPlayerPFCollision
    lda plXL
    sta plX
    lda plYL
    sta plY
SkipPlayerPFCollision
    lda plX
    sta plXL
    lda plY
    sta plYL

OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne OVERSCAN_WAIT
    
    jmp VERTICAL_SYNC

ProcessInput:
_ = .
    lda SWCHA
    and #$F0
    
ContRight:
    asl
    bcs ContLeft
    lda plY
    and #(GRID_STEP - 1)
    beq MovePlayerRight
    and #(GRID_STEP / 2)
    beq MovePlayerDown
    jmp MovePlayerUp
    
MovePlayerRight:
    lda #$00
    sta plSprOff
    inc plX
    jmp ContFin
    
ContLeft:
    asl
    bcs ContDown
    lda plY
    and #(GRID_STEP - 1)
    beq MovePlayerLeft
    and #(GRID_STEP / 2)
    beq MovePlayerDown
    jmp MovePlayerUp
    
MovePlayerLeft:
    lda #$08
    sta plSprOff
    dec plX
    jmp ContFin
    
ContDown:
    asl
    bcs ContUp
    lda plX
    and #(GRID_STEP - 1)
    beq MovePlayerDown
    and #(GRID_STEP / 2)
    beq MovePlayerLeft
    jmp MovePlayerRight
    
MovePlayerDown:
    lda #$10
    sta plSprOff
    dec plY
    jmp ContFin
    
ContUp:
    asl
    bcs ContFin
    lda plX
    and #(GRID_STEP - 1)
    beq MovePlayerUp
    and #(GRID_STEP / 2)
    beq MovePlayerLeft
    jmp MovePlayerRight
    
MovePlayerUp:
    lda #$18
    sta plSprOff
    inc plY
    
ContFin:
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
    
    
	echo "-CODE-",$F000,(.)
    
KERNEL_SIMPLE: SUBROUTINE
; y = boardHeight
; Player
    lda #7 ;player height
    dcp plDY
    bcs .DrawP0
    lda #0
    .byte $2C ; BIT compare hack to skip 2 byte op
    
.DrawP0:
    lda (plSpr),y
    sta GRP0
    sta WSYNC
; Playfield
    tya
    lsr
    lsr
    tax
    
    lda PF1Room0,x
    sta PF1
    lda PF2Room0,x
    sta PF2

    dey
    sta WSYNC
    bne KERNEL_SIMPLE    
    
    
    align 256
SpriteStart = (.)
    INCLUDE "sprite.asm"
    
	echo "-SPRITE-",SpriteStart,(.)

    
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