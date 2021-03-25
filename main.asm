    processor 6502
    INCLUDE "vcs.h"
    INCLUDE "macro.h"
    INCLUDE "vars.asm"

    SEG CODE
    
    ORG $0000
    RORG $F000
BANK_0
WORLD_PF1
    INCLUDE "spr_world_pf1.asm"
    INCLUDE "spr_dung_pf1.asm"
WORLD_PF2
    INCLUDE "spr_world_pf2.asm"
    INCLUDE "spr_dung_pf2.asm"
    INCLUDE "spr_en.asm"
    INCLUDE "spr_item.asm"
    ;INCLUDE "spr_num.asm"
MINIMAP
    INCLUDE "spr_map.asm"
    INCLUDE "spr_pl.asm"
    
    LOG_SIZE "-BANK 0- Sprites", BANK_0
    
    
    ORG $0800
    RORG $F000
BANK_1 
;WORLDA
    .byte $02, $03, $02, $03, $00, $01, $02, $03
    .byte $04, $05, $06, $07, $08, $09, $0A, $0B
    .byte $02, $03, $02, $03, $00, $01, $02, $03
    .byte $04, $05, $06, $07, $08, $09, $0A, $0B
    .byte $02, $03, $02, $03, $00, $01, $02, $03
    .byte $04, $05, $06, $07, $08, $09, $0A, $0B
    .byte $02, $03, $02, $03, $00, $01, $02, $03
    .byte $04, $05, $06, $07, $08, $09, $0A, $0B
    ;ds ROOM_MAX -$10
    
;WORLDB
    .byte $02, $03, $02, $03, $00, $01, $02, $03
    .byte $04, $05, $06, $07, $08, $09, $0A, $0B
    ds ROOM_MAX -$10
    
;DOORA 
    ds ROOM_MAX
;DOORB 
    ds ROOM_MAX
;ROOM_SCRIPT 
    ds $20 * 2
    LOG_SIZE "-BANK 1-", BANK_1
    
    ORG $1000
    RORG $F000
BANK_2
    
    LOG_SIZE "-BANK 2-", BANK_2
    
    ORG $1800
    RORG $F000
BANK_3
    
    LOG_SIZE "-BANK 3-", BANK_3
    
    ORG $2000
    RORG $F000
BANK_4
    
    LOG_SIZE "-BANK 4-", BANK_4
    
    ORG $2800
    RORG $F000
BANK_5

    LOG_SIZE "-BANK 5-", BANK_5
    
    ORG $3000
    RORG $F000
BANK_6
    LOG_SIZE "-BANK 6-", BANK_6
        
    ORG $3800
    RORG $F800
    
	repeat 512
	.byte $00
	repend
    
ENTRY: SUBROUTINE
    CLEAN_START
.wipeRam1
    dex
    sta $f800,x
    bne .wipeRam1
    lda $1FE7
.wipeRam2
    lda $00
    dex
    sta $f400,x
    bne .wipeRam2
INIT:
    
    ; set player colors
    lda #COLOR_PLAYER_00
    sta COLUP0
    
    ; set bgColor
    lda #COLOR_PATH
    sta bgColor
    
    ; set playfield
    lda #COLOR_GREEN_ROCK
    sta fgColor
    
    lda #%00000001
    sta CTRLPF
    
    lda #$2C
    sta Rand8
    
    ldx #10-1
INIT_POS:
    sta plX,x
    dex
    bpl INIT_POS
    jsr LoadRoom
    
    
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
    lda $1FE1
    jsr ProcessInput
    jsr Random
    lda #1
    ;sta VDELP0
    sta VDELP1
    jsr EnemyAIDel
    
__EnemyAIReturn:

; test player board bounds
    ldy roomId
    lda plX
    cmp #BoardXR
    bne .plXRSkip
    ldx #BoardXL+1
    stx plX
    inc roomId
.plXRSkip
    cmp #BoardXL
    bne .plXLSkip
    ldx #BoardXR-1
    stx plX
    dec roomId
.plXLSkip
    lda plY
    cmp #BoardYU
    bne .plYUSkip
    ldx #BoardYD+1
    stx plY
    clc
    lda roomId
    adc #$F8
    sta roomId
    lda plY
.plYUSkip
    cmp #BoardYD
    bne .plYDSkip
    ldx #BoardYU-1
    stx plY
    clc
    lda roomId
    adc #$8
    sta roomId
.plYDSkip
    cpy roomId
    beq .skipSwapRoom
; room setup
    jsr LoadRoom
.skipSwapRoom
    jsr UpdateDoors
    lda #ROOM_PX_HEIGHT-1
    sta roomSpr
    
    lda bgColor
    sta COLUBK
    lda fgColor
    sta COLUPF

; Sword 
    bit plState
    bvc .skipSetItemTimer
; If Item Button, stab sword
    lda #ItemTimerSword
    sta plItemTimer
.skipSetItemTimer
    ldy plItemTimer
    bne .drawSword
    lda #$80
    sta m0Y
    bmi .endSword
    
.drawSword
    lda #0
    cpy #-7
    bmi .endSword
    cpy #-1
    beq .drawSword4
    lda #4
.drawSword4
    clc
    adc plDir
    tay
    lda SwordWidth4,y
    sta NUSIZ0
    lda SwordHeight4,y
    sta m0H
    lda SwordOff4X,y
    clc
    adc plX
    sta m0X
    lda SwordOff4Y,y
    clc
    adc plY
    sta m0Y
.endSword
    
;===============================================================================
; Pre-Position Sprites
;===============================================================================

; player draw height
    lda #(ROOM_HEIGHT+8)
    sec
    sbc plY
    sta plDY
    
; player sword draw height
    lda #(ROOM_HEIGHT+8)
    sec
    sbc m0Y
    sta m0DY
    
; player sprite setup
    lda #<(SprP0 + 7) ; Sprite + height-1
    clc
    ldx plDir
    adc Mul8,x
    sec ; set Carry
    sbc plY
    sta plSpr
    
    lda #>(SprP0 + 7)
    sbc #0
    sta plSpr+1
    
; enemy draw height
    lda #(ROOM_HEIGHT+8)
    sec
    sbc enY
    sta enDY
    
; enemy sprite setup
    lda #<(SprP0 + 7)
    clc
    adc enSpr
    sec
    sbc enY
    sta enSpr
    
    lda #>(SprP0 + 7)
    sbc #0
    sta enSpr + 1
    
; mini-map setup
    ldx #1
    stx COLUBK
    lda #$18
    jsr PosObject ; minimap
    lda #8
    sta worldId
    lda roomId
    and #7
    clc
    adc #$18
    ldx #0
    jsr PosObject ; location
    
    lda $1FE0
    sta WSYNC
    sta HMOVE
    
; ===================================================
; Kernel Main
; ===================================================    
KERNEL_MAIN: SUBROUTINE ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN
    sta VBLANK
    
KERNEL_HUD: SUBROUTINE
    ldy #7
    lda #$84
    sta COLUP1
    ;sta WSYNC
    lda roomId
    lsr
    lsr
    lsr
    and #$7
    tax
.loop:
    lda MINIMAP,y
    sta GRP1
    sta WSYNC
    lda #$80
    cpx #0
    beq .skip
    lda #0
.skip
    sta GRP0
    sta WSYNC
    dex
    dey
    bpl .loop
    lda #76
    sta TIM8T
    sta WSYNC
    lda #0
    sta GRP1
    sta GRP0
; HMOVE setup
    lda enX
    ldx #1
    jsr PosObject
    lda plX
    ldx #0
    jsr PosObject
    lda m0X
    ldx #2
    jsr PosObject
    sta WSYNC
    sta HMOVE
    
.waitTimerLoop
    lda INTIM
    bne .waitTimerLoop
    sta WSYNC
    
    lda #$FF
    sta PF0
    sta PF1
    sta PF2
    
    ldy #ROOM_HEIGHT
    lda bgColor
    sta COLUBK
    lda enColor
    sta COLUP1
    
    lda #0
    ldx #0
    sta WSYNC
    sta CXCLR
    LOG_SIZE "-KERNEL HUD-", KERNEL_HUD
   
KERNEL_LOOP: SUBROUTINE ; 76 cycles per scanline
    sta ENAM0       ; 3
    stx GRP0        ; 3
    
    ldx roomSpr     ; 3
    lda rPF1RoomL,x ; 4
    sta PF1         ; 3
    lda rPF2RoomL,x ; 4
    sta PF2         ; 3
    
; Enemy
    lda #7          ; 2     enemy height
    dcp enDY        ; 5
    bcs .DrawE0     ; 2/3
    lda #0          ; 2
    .byte $2C       ; 4-5   BIT compare hack to skip 2 byte op
.DrawE0:
    lda (enSpr),y   ; 5
    pha
    lda rPF1RoomR,x
    sta PF1
    pla
    sta WSYNC       ; 3  34-35 cycles, not counting WSYNC (can save cycle by fixing bcs)
    sta GRP1        ; 3
    
    ldx roomSpr     ; 3
    lda rPF1RoomL,x ; 4
    sta PF1         ; 3
    lda rPF2RoomL,x ; 4
    sta PF2         ; 3

; Player  
    lda #7          ; 2 player height
    dcp plDY        ; 5
    bcs .DrawP0     ; 2/3
    lda #0          ; 2
    .byte $2C       ; 4-5 BIT compare hack to skip 2 byte op
.DrawP0:
    lda (plSpr),y   ; 5
    pha
    ldx roomSpr     ; 3
    lda rPF1RoomR,x ; 4
    sta PF1         ; 3
    pla
    tax             ; 2
    
; Playfield
    tya             ; 2
    and #3          ; 2
    beq .skipPFDec  ; 2/3
    .byte $2C       ; 4-5
.skipPFDec
    dec roomSpr     ; 5
    
; Player Missle 
    lda m0H         ; 3 player height
    dcp m0DY        ; 5
    lda #1          ; 2
    adc #0

    ;sta WSYNC
    
    dey
    bpl KERNEL_LOOP
    lda fgColor
    sta COLUBK
    
    LOG_SIZE "-KERNEL WORLD-", KERNEL_LOOP
    
OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer
    
    lda #0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1
    sta ENAM0
    sta PF0
    
    ldx #1
.posResetLoop
    lda CXP0FB,x
    bpl .SkipPFCollision
    lda plXL,x
    sta plX,x
    lda plYL,x
    sta plY,x
.SkipPFCollision:
    lda plX,x
    sta plXL,x
    lda plY,x
    sta plYL,x
    dex
    bpl .posResetLoop

OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne OVERSCAN_WAIT
    
    jmp VERTICAL_SYNC

ProcessInput: SUBROUTINE

    lda plState
    and #$BF
    sta plState
    bpl .FireNotHit
    lda INPT4
    bmi .FireNotHit
    lda plItemTimer
    bne .FireNotHit
    lda plState
    ora #$40
    sta plState
.FireNotHit
    lda plState
    and #$7F
    bit INPT4
    bpl .skipLastFire
    ora #$80
.skipLastFire
    sta plState

    lda plItemTimer
    cmp #1
    adc #0
    sta plItemTimer
    
    bmi .skipItemInput
    
.skipItemInput
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
    sta plDir
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
    lda #$01
    sta plDir
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
    lda #$2
    sta plDir
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
    lda #$3
    sta plDir
    inc plY
    
ContFin:
    rts
    LOG_SIZE "Input", ProcessInput

LoadRoom: SUBROUTINE
    lda $1FE1
    ldy roomId
    lda WORLDA,y
    tay
    lda #ROOM_SPR_HEIGHT-1
    tax
.roomSprOffLoop
    cpy #0
    beq .roomSprOffLoopEnd
    clc
    adc #ROOM_SPR_HEIGHT
    dey
    jmp .roomSprOffLoop
.roomSprOffLoopEnd
    tay
.roomInitMem
    lda $1FE0
.roomInitMemLoop
    lda.wy WORLD_PF1,y
    ora #$C0
    sta wPF1RoomL+2,x
    sta wPF1RoomR+2,x
    lda.wy WORLD_PF2,y
    sta wPF2Room+2,x
    dey
    dex
    bpl .roomInitMemLoop
      
    lda #$FF
    ldy #1
.roomUpDownBorder
    sta wPF1RoomL,y
    sta wPF2Room,y
    sta wPF1RoomR,y
    sta wPF1RoomL+ROOM_PX_HEIGHT-2,y
    sta wPF1RoomR+ROOM_PX_HEIGHT-2,y
    sta wPF2Room+ROOM_PX_HEIGHT-2,y
    dey
    bpl .roomUpDownBorder
    
UpdateDoors: SUBROUTINE
    ldy #$3F
    ldx #$FF
    lda roomDoors
    
    lsr
    sty wPF2Room+1
    bcc .skipDown0
    stx wPF2Room+1
    
.skipDown0
    lsr
    sty wPF2Room+0
    bcc .skipDown1
    stx wPF2Room+0
    
.skipDown1
    lsr
    sty wPF2Room+ROOM_PX_HEIGHT-2
    bcc .skipUp0
    stx wPF2Room+ROOM_PX_HEIGHT-2
    
.skipUp0
    lsr
    sty wPF2Room+ROOM_PX_HEIGHT-1
    bcc .skipUp1
    stx wPF2Room+ROOM_PX_HEIGHT-1
    
.skipUp1
    lda roomDoors
    and #$C0
    sta Temp1
    lda roomDoors
    asl
    asl
    and #$C0
    sta Temp2
    
    ldy #3
.lrLoop
    lda rPF1RoomL+(ROOM_PX_HEIGHT/2)-2,y
    and #$3F
    ora Temp1
    sta wPF1RoomL+(ROOM_PX_HEIGHT/2)-2,y
    lda rPF1RoomR+(ROOM_PX_HEIGHT/2)-2,y
    and #$3F
    ora Temp2
    sta wPF1RoomR+(ROOM_PX_HEIGHT/2)-2,y
    dey
    bpl .lrLoop
    rts
    
    LOG_SIZE "Room Load", LoadRoom
    
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
    align 16 ; FIXME: Page rollover issue   
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

;===============================================================================
; Generate Random Number
;-----------------------
;   A - returns the randomly generated value   
;===============================================================================
Random:
        lda Rand8
        lsr
        bcc noeor
        eor #$B4
noeor:
        sta Rand8
        rts   
        
  
EnemyAIDel:
    ldx enType
    lda EnemyAIH,x
    pha
    lda EnemyAIL,x
    pha
    rts
    
NextDir: SUBROUTINE
    jsr Random
    and #3
    tax
.nextLoop
    lda enBlockDir
    and Lazy8,x
    beq .end
    inx
    bpl .nextLoop
.end
    txa
    and #3
    sta enDir
    rts
    
DarknutAI: SUBROUTINE
; update stun/recoil timers
    lda enRecoil
    cmp #1
    adc #0
    sta enRecoil
    lda enStun
    cmp #1
    adc #0
    sta enStun
    asl
    asl
    adc #COLOR_DARKNUT_RED
    sta enColor
    
.setBlockedDir
    lda enBlockDir
    and #$F0
    ldx enX
    cpx #EnBoardXR
    bne .setBlockedL
    ora #1
.setBlockedL
    cpx #EnBoardXL
    bne .setBlockedD
    ora #2
.setBlockedD
    ldx enY
    cpx #EnBoardYD
    bne .setBlockedU
    ora #4
.setBlockedU
    cpx #EnBoardYU
    bne .setBlockedEnd
    ora #8
.setBlockedEnd
    sta enBlockDir
    
.checkPFHit    
    lda enRecoil
    bne .endCheckPFHit
    lda CXP1FB
    bpl .endCheckPFHit
    ; set blocked dir
    ldx enDir
    lda enBlockDir
    ora Bit8,x
    sta enBlockDir
.endCheckPFHit
    
.checkHit
; if collided with weapon && stun == 0,   
    lda CXM0P
    bpl .endCheckHit
    lda enStun
    bne .endCheckHit
    lda #-32
    sta enStun
    lda #-16
    sta enRecoil
.endCheckHit

.checkBlocked
    lda enBlockDir
    ldx enDir
    and Lazy8,x
    beq .endCheckBlocked
    jsr NextDir
    jmp .move
.endCheckBlocked

.randDir
    lda enX
    and #3
    bne .move
    lda enY
    and #3
    bne .move
    lda Frame
    eor enBlockDir
    and #$20
    beq .move
    eor enBlockDir
    sta enBlockDir
    jsr NextDir

.move
    lda enDir
    tax
    ldy Mul8,x
    sty enSpr
    
    lda Frame
    and #1
    beq .return
    txa
    
    cmp #0
    beq DarknutRightAI
    cmp #1
    beq DarknutLeftAI
    cmp #2
    beq DarknutDownAI
    cmp #3
    beq DarknutUpAI
.return
    rts


DarknutRightAI: SUBROUTINE
    inc enX
    rts

DarknutLeftAI: SUBROUTINE
    dec enX
    rts
    
DarknutDownAI: SUBROUTINE
    dec enY
    rts
    
DarknutUpAI: SUBROUTINE
    inc enY
    rts
    
    LOG_SIZE "EnemyAI", EnemyAIDel
    
    LOG_SIZE "-CODE-", ENTRY
    
DataStart
    INCLUDE "ptr.asm"
    
    align 16
Mul8:
    .byte 0x00, 0x08, 0x10, 0x18
Lazy8:
    .byte 0x01, 0x02, 0x04, 0x08
Bit8:
    .byte 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80
    
SwordWidth4:
    .byte $20, $20, $10, $10
SwordWidth8:
    .byte $30, $30, $10, $10
SwordHeight4:
    .byte 1, 1, 3, 3
SwordHeight8:
    .byte 1, 1, 7, 7
SwordOff4X:
    .byte 7, -1, 4, 4
SwordOff8X:
    .byte 7, -5, 4, 4
SwordOff4Y:
    .byte 3, 3, -2, 6
SwordOff8Y:
    .byte 3, 3, -6, 6
    
    LOG_SIZE "-DATA-", DataStart
  
	ORG $3FFC
	RORG $FFFC
	.word ENTRY
	.byte "07"
    END