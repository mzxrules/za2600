    processor 6502
    INCLUDE "vcs.h"
    INCLUDE "macro.h"
    INCLUDE "vars.asm"

    SEG CODE

; ****************************************
; *               BANK 0                 *
; ****************************************
    ORG $0000
    RORG $F000
BANK_0
    INCLUDE "spr_room_pf1.asm"
    INCLUDE "spr_room_pf2.asm"
    INCLUDE "spr_en.asm"
    INCLUDE "spr_item.asm"
MINIMAP
    INCLUDE "spr_map.asm"
    align $20
    INCLUDE "spr_pl.asm"
    INCLUDE "spr_num.asm"

    LOG_SIZE "-BANK 0- Sprites", BANK_0

    ORG $0800
    RORG $F000
BANK_1
    INCLUDE "world/b1world.asm"
    INCLUDE "world/w0_w0co.asm"
    INCLUDE "world/w1_w2co.asm"
    INCLUDE "world/b1lock.asm"

    LOG_SIZE "-BANK 1- World | Level 1 2", BANK_1

    ORG $1000
    RORG $F000
BANK_2
    INCLUDE "world/b2world.asm"
    INCLUDE "world/w3_w4co.asm"
    INCLUDE "world/w5_w6co.asm"
    INCLUDE "world/b2lock.asm"

    LOG_SIZE "-BANK 2- Level 3 4 5 6", BANK_2

; ****************************************
; *               BANK 3                 *
; ****************************************

    ORG $1800
    RORG $F000
BANK_3
    INCLUDE "world/b3world.asm"
    INCLUDE "world/w7_w8co.asm"
    INCLUDE "world/w9_w9co.asm"
    INCLUDE "world/b3lock.asm"

    LOG_SIZE "-BANK 3- Level 7 8 9", BANK_3

; ****************************************
; *               BANK 4                 *
; ****************************************

    ORG $2000
    RORG $F000
BANK_4
    INCLUDE "ptr.asm"
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
NoAI:
    lda #$F0
    sta enSpr+1
    sta enY
    rts

TriforceAI: SUBROUTINE
    lda #>SprItem6
    sta enSpr+1
    lda #<SprItem6
    sta enSpr
    lda #$4C
    sta enX
    lda #$2C
    sta enY
    lda Frame
    and #$10
    bne .TriforceBlue

    lda #$2A
    .byte $2C
.TriforceBlue
    lda #$88
    sta enColor
    rts


SpectacleOpenAI: SUBROUTINE

    ldy #$6
    lda rPF2Room,y
    and #$F9
    sta wPF2Room,y
    sta wPF2Room+1,y
    lda #$64
    sta enX
    lda #$20
    sta enY
    lda fgColor
    sta enColor
    lda #(30*8)
    sta enSpr
    rts

BlockStairAI: SUBROUTINE
; diamond room
    ldy #$D
    lda rPF2Room,y
    and #$7F
    sta wPF2Room,y
    sta wPF2Room+1,y
    lda #$4C
    sta enX
    lda #$3C
    sta enY
    lda fgColor
    sta enColor
    lda #(30*8)
    sta enSpr
    rts

StairAI: SUBROUTINE
    lda #$4C
    sta enX
    lda #$2C
    sta enY
    lda fgColor
    sta enColor
    lda #<SprItem7
    sta enSpr
    lda #>SprItem7
    sta enSpr+1

    lda enX
    cmp plX
    bne .playerNotOnStairs
    lda enY
    cmp plY
    bne .playerNotOnStairs
    lda #01
    sta worldId
    lda #$F3
    sta roomId
    lda #0
    sta enType
    lda roomFlags
    ora #$80
    sta roomFlags

.playerNotOnStairs
    rts

DarknutAI: SUBROUTINE
    lda #>SprE0
    sta enSpr+1
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

    ldx enDir
    ldy Mul8,x
    sty enSpr

    lda Frame
    and #1
    beq .return
    txa

    cmp #0
    beq EnMoveRight
    cmp #1
    beq EnMoveLeft
    cmp #2
    beq EnMoveDown
    cmp #3
    beq EnMoveUp
.return
    rts


EnMoveRight: SUBROUTINE
    inc enX
    rts

EnMoveLeft: SUBROUTINE
    dec enX
    rts

EnMoveDown: SUBROUTINE
    dec enY
    rts

EnMoveUp: SUBROUTINE
    inc enY
    rts

    LOG_SIZE "-BANK 4- EnemyAI", BANK_4


; ****************************************
; *               BANK 5                 *
; ****************************************

    ORG $2800
    RORG $F000
BANK_5

    LOG_SIZE "-BANK 5-", BANK_5

    ORG $3000
    RORG $F000


; ****************************************
; *               BANK 6                 *
; ****************************************

BANK_6
    LOG_SIZE "-BANK 6-", BANK_6



; ****************************************
; *               BANK 7                 *
; ****************************************

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
    lda #$77
    sta roomId
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
    jsr ProcessInput
    jsr Random
    lda #1
    ;sta VDELP0
    sta VDELP1
    jsr EnemyAIDel

__EnemyAIReturn:
    bit roomFlags
    bmi .LoadRoom
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
    adc #$F0
    sta roomId
    lda plY
.plYUSkip
    cmp #BoardYD
    bne .plYDSkip
    ldx #BoardYU-1
    stx plY
    clc
    lda roomId
    adc #$10
    sta roomId
.plYDSkip
    cpy roomId
    beq .skipSwapRoom
; room setup
.LoadRoom
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

.player_sprite_setup
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

.enemy_sprite_setup
    lda enSpr; #<(SprE0 + 7)
    clc
    adc #7;enSpr
    sec
    sbc enY
    sta enSpr

    lda enSpr + 1;#>(SprE0 + 7)
    sbc #0
    sta enSpr + 1

.minimap_setup
; sprite setup
    lda #<(MINIMAP) ; Sprite + height-1
    clc
    ldx worldId
    adc Mul8,x
    sta mapSpr

    lda #>(MINIMAP)
    sta mapSpr+1


    ldx #1
    stx COLUBK
    lda #$18
    jsr PosObject ; minimap
    sec
    ldx #5
    lda #$F
    bit worldId
    beq .minimap_16
    ldx #$00
    lda #$7
    clc
.minimap_16
    and roomId
    adc #$18
    stx NUSIZ1
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
    lda #COLOR_MINIMAP
    sta COLUP1
    ;sta WSYNC
    lda roomId
    lsr
    lsr
    lsr
    lsr
    and #$7
    tax
.loop:
    lda (mapSpr),y
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
    stx NUSIZ1
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
    lda rPF2Room,x  ; 4
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
    lda rPF2Room,x  ; 4
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
    jsr TestCollisionReset
    dex
    bpl .posResetLoop

OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne OVERSCAN_WAIT

    jmp VERTICAL_SYNC


;===============================================================================
; CollisionReset
;----------
; N = reset collision
; x = Player (0), Enemy (1)
TestCollisionReset:
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
    rts


ProcessInput: SUBROUTINE
    ; test if player locked
    lda #02
    bit plState
    beq .InputContinue
    rts
.InputContinue
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
    lda plState
    lsr
    bcc .MovePlayerRightFr
    lda #2
    bit plDir
    bne .rts
.MovePlayerRightFr
    lda #$00
    sta plDir
    inc plX
.rts
    rts ;jmp ContFin

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
    lda plState
    lsr
    bcc .MovePlayerLeftFr
    lda #2
    bit plDir
    bne .rts
.MovePlayerLeftFr
    lda #$01
    sta plDir
    dec plX
    rts ;jmp ContFin

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
    lda plState
    lsr
    bcc .MovePlayerDownFr
    lda #2
    bit plDir
    beq .rts
.MovePlayerDownFr
    lda #$2
    sta plDir
    dec plY
    rts ;jmp ContFin

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
    lda plState
    lsr
    bcc .MovePlayerUpFr
    lda #2
    bit plDir
    beq .rts
.MovePlayerUpFr
    lda #$3
    sta plDir
    inc plY

ContFin:
    rts
    LOG_SIZE "Input", ProcessInput

LoadRoom: SUBROUTINE
    ; flush loadroom flag
    lda roomFlags
    and #$7F
    sta roomFlags

    ; calculate world bank
    ldy worldId
    iny
    tya
    lsr
    lsr
    tay
    lda $1FE1,y

    ldy roomId
    ; set fg/bg color
    lda WORLD_COLOR,y
    and #$0F
    tax
    lda WorldColors,x
    sta fgColor
    lda WORLD_COLOR,y
    lsr
    lsr
    lsr
    lsr
    tax
    lda WorldColors,x
    sta bgColor
    
    ; PF1 Right
    lda WORLD_T_PF1R,y
    tax
    and #$F0
    sta Temp4
    txa
    and #$01
    clc
    adc #$F0
    sta Temp5
    txa
    and #$0E
    asl
    asl
    asl
    asl
    sta roomDoors
    
    ; PF1 Left
    lda WORLD_T_PF1L,y
    tax
    and #$F0
    sta Temp0
    txa
    and #$01
    clc
    adc #$F0
    sta Temp1
    txa
    and #$0E
    lsr
    ora roomDoors
    sta roomDoors
    
    ; PF2
    lda WORLD_T_PF2,y
    tax
    and #$F0
    sta Temp2
    txa
    and #$03
    clc
    adc #$F0
    sta Temp3
    txa
    and #$0C
    asl
    ora roomDoors
    sta roomDoors

    ldy #ROOM_SPR_HEIGHT-1

.roomInitMem
    lda $1FE0
.roomInitMemLoop
    lda (Temp0),y ; PF1L
    ora #$C0
    sta wPF1RoomL+2,y
    lda (Temp4),y ; PF1R
    ora #$C0
    sta wPF1RoomR+2,y
    lda (Temp2),y ; PF2
    sta wPF2Room+2,y
    dey
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
    lda worldId
    beq UpdateWorldDoors
    rts
    
UpdateWorldDoors: SUBROUTINE
    lda roomDoors
    and #3
    tax
    ldy #1
.Up
    lda WorldDoorPF2,x
    sta wPF2Room+ROOM_PX_HEIGHT-2,y
    lda WorldDoorPF1Up,x
    sta wPF1RoomL+ROOM_PX_HEIGHT-2,y
    sta wPF1RoomR+ROOM_PX_HEIGHT-2,y
    dey
    bpl .Up
    
    lda roomDoors
    lsr
    lsr
    pha
    and #3
    tax
    ldy #1
.Down
    lda WorldDoorPF2,x
    sta wPF2Room,y
    lda WorldDoorPF1Up,x
    sta wPF1RoomL,y
    sta wPF1RoomR,y
    dey
    bpl .Down

.LeftRight
    pla
    lsr
    lsr
    tay
    and #3
    tax
    lda WorldDoorPF1A,x
    sta Temp1
    lda WorldDoorPF1B,x
    sta Temp3
    tya
    lsr
    lsr
    and #3
    tax
    lda WorldDoorPF1A,x
    sta Temp0
    lda WorldDoorPF1B,x
    sta Temp2
    
    ldy #5
.LeftRightWorldDoor
    lda rPF1RoomL+2,y
    and Temp0
    sta wPF1RoomL+2,y
    
    lda rPF1RoomL+12,y
    and Temp0
    sta wPF1RoomL+12,y
    
    lda rPF1RoomR+2,y
    and Temp1
    sta wPF1RoomR+2,y
    
    lda rPF1RoomR+12,y
    and Temp1
    sta wPF1RoomR+12,y
    dey
    bpl .LeftRightWorldDoor
    
    ldy #3
.LeftRightWorldDoor2
    lda rPF1RoomL+8,y
    and Temp2
    sta wPF1RoomL+8,y
    
    lda rPF1RoomR+8,y
    and Temp3
    sta wPF1RoomR+8,y
    dey
    bpl .LeftRightWorldDoor2
rts_UpdateDoors:
    rts
    
UpdateDoors: SUBROUTINE
    lda worldId
    beq rts_UpdateDoors
    ldy #$3F
    ldx #$FF
    lda roomDoors

    lsr
    sty wPF2Room+ROOM_PX_HEIGHT-2
    bcc .skipDown0
    stx wPF2Room+ROOM_PX_HEIGHT-2

.skipDown0
    lsr
    sty wPF2Room+ROOM_PX_HEIGHT-1
    bcc .skipDown1
    stx wPF2Room+ROOM_PX_HEIGHT-1

.skipDown1
    lsr
    sty wPF2Room+1
    bcc .skipUp0
    stx wPF2Room+1

.skipUp0
    lsr
    sty wPF2Room+0
    bcc .skipUp1
    stx wPF2Room+0

.skipUp1
    lda roomDoors
    and #$C0
    sta Temp0
    lda roomDoors
    asl
    asl
    and #$C0
    sta Temp1

    ldy #3
.lrLoop
    lda rPF1RoomL+(ROOM_PX_HEIGHT/2)-2,y
    and #$3F
    ora Temp0
    sta wPF1RoomL+(ROOM_PX_HEIGHT/2)-2,y
    lda rPF1RoomR+(ROOM_PX_HEIGHT/2)-2,y
    and #$3F
    ora Temp1
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
    lda $1FE4
    ldx enType
    lda EnemyAIH,x
    pha
    lda EnemyAIL,x
    pha
    rts

    LOG_SIZE "-CODE-", ENTRY

DataStart

    align 16
Mul8:
    .byte 0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38, 0x40, 0x48
Lazy8:
    .byte 0x01, 0x02, 0x04, 0x08
Bit8:
    .byte 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80
    
    
    align 4    
WorldDoorPF1Up:
    .byte $C0, $C0, $FF, $FF
    
WorldDoorPF1A:
    .byte $3F, $3F, $FF, $FF
    
WorldDoorPF1B:
    .byte $3F, $FF, $3F, $FF
    
WorldDoorPF2:
    .byte $00, $FF, $3F, $FF

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
    align 16
WorldColors:
    .byte $00, COLOR_DARK_BLUE, $00, COLOR_LIGHT_BLUE, $42, $00, COLOR_PATH, $06, $02, COLOR_LIGHT_BLUE, COLOR_GREEN_ROCK, COLOR_LIGHT_WATER, $00, COLOR_CHOCOLATE, COLOR_GOLDEN, $0E

    LOG_SIZE "-DATA-", DataStart

	ORG $3FFC
	RORG $FFFC
	.word ENTRY
	.byte "07"
    END