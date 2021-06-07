;==============================================================================
; mzxrules 2021
;==============================================================================
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
    
    lda #%00110001 ; ball size 8, reflect playfield
    sta CTRLPF
    
    ; seed RNG
    lda #$2C
    sta Rand8
    lda #$20
    ldx #10-1
INIT_POS:
    sta plX,x
    dex
    bpl INIT_POS
    
    ; set ball
    ;lda #$60
    ;sta blX
    ;sta blY
    
    ; set player stats
    lda #$18
    sta plHealth
    sta plHealthMax
    
    lda #MS_PLAY_THEME
    sta SeqFlags
    
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
    lda #0
    sta VDELP0
    sta VDELP1
    
    lda roomFlags
    and #$BF
    sta roomFlags
    bpl .skipLoadRoom
    ora #$40
    sta roomFlags
    jsr LoadRoom
    lda #0
    sta enType
    sta KernelId
.skipLoadRoom

    bit roomFlags
    bvs .roomLoadCpuSkip
    jsr ProcessInput
    jsr Random
    lda BANK_ROM + 6
    jsr PlayerItem_B6
.roomLoadCpuSkip

; room setup
    lda BANK_ROM + 6
    jsr KeydoorCheck_B6
    jsr UpdateDoors_B6
    lda BANK_ROM + 5
    jsr UpdateAudio
    jsr EnemyAIDel
    
;==============================================================================
; Pre-Position Sprites
;==============================================================================

; room draw start
    ldy KernelId
    lda RoomWorldOff,y
    sta roomSpr
    
; player draw height
    lda Spr8WorldOff,y;#(ROOM_HEIGHT+8)
    sec
    sbc plY
    sta plDY

; player sword draw height
    lda Spr8WorldOff,y;#(ROOM_HEIGHT+8)
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
    lda Spr8WorldOff,y;#(ROOM_HEIGHT+8)
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
    
.ball_sprite_setup
    lda #7
    sta blH
; ball draw height
    lda Spr1WorldOff,y;#(ROOM_HEIGHT+1)
    sec
    sbc blY
    sta blDY
    
.minimap_setup
; sprite setup
    lda #<(MINIMAP) ; Sprite + height-1
    clc
    ldx worldId
    adc Mul8,x
    sta mapSpr
    lda #>(MINIMAP)
    sta mapSpr+1
; double width map if on overworld
    ldx #5
    bit worldId
    beq .minimap_16
    ldx #$00
.minimap_16
    stx NUSIZ1 ; double minimap size if world 0
    lda #0
    sta COLUBK
    sta NUSIZ0 ; clean sword from previous frame
    
    lda BANK_ROM + 0
.hud_sprite_setup
; rupee display
    lda itemRupees
    and #$0F
    asl
    asl
    asl
    clc
    adc #7
    sta THudDigits+5
    lda itemRupees
    and #$F0
    lsr
    clc
    adc #7
    sta THudDigits+4
; key display
    ldx itemKeys
    bmi .hud_all_keys
    cpx #9
    bmi .hud_key_digit
    ldx #9
    .byte $2C
.hud_all_keys
    ldx #10
.hud_key_digit
    lda Mul8,x
    clc
    adc #7
    sta THudDigits+3
    lda #<SprN10 - #<SprN0 +7
    sta THudDigits+2
; bomb display    
    lda itemBombs
    cmp #10
    bpl .hud_bomb_digit
    lda #<SprN11 - #<SprN0 +7
    .byte $2C
.hud_bomb_digit
    lda #<SprN1+7
    sta THudDigits+0 
    lda itemBombs
    and #$0F
    asl
    asl
    asl
    clc
    adc #7
    sta THudDigits+1

    jsr PosHudObjects
    
; ===================================================    
;    Pre HUD
; ===================================================
    lda roomId
    lsr
    lsr
    lsr
    lsr
    eor #$7
    and #$7
    sta TMapPosY
    lda plHealth
    clc
    adc #7
    lsr
    lsr
    lsr
    sta THudHealthL
    sec
    sbc #8
    bcs .skipHealthHighClampMin
    lda #0
.skipHealthHighClampMin
    tax
    lda HealthPattern,x
    sta THudHealthH
    beq .skipHealthClamp
    lda #8
    sta THudHealthL
.skipHealthClamp
    ldx THudHealthL
    lda HealthPattern,x
    sta THudHealthL
    lda #0
    
    lda #COLOR_MINIMAP
    sta COLUP1
    lda #COLOR_PLAYER_02
    sta COLUPF

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
    lda #0
    sta WSYNC
    beq .loop
;=========== Scanline 1A ==============
.hudScanline1A
    sta WSYNC
    lda #0
    sta GRP0
    sta PF1
    ldx #3
.hudShiftDigitLoop
    lda THudDigits,x
    sta THudDigits+2,x
    dex
    bpl .hudShiftDigitLoop
    lda THudHealthL
    sta THudHealthH
    dey
    lda #0
    sta THudHealthL
    nop ;sta WSYNC
KERNEL_HUD_LOOP:
.loop:

;=========== Scanline 0 ==============
    cpy TMapPosY ; 3
    bne .skip ; 2/3
    lda #2    ; 2
.skip
    sta ENAM0 ; 3
    lda (mapSpr),y ; 5
    sta GRP1 ; 3
    
    ldx THudDigits+4 ; 3
    lda SprN0,x  ; 4
    and #$F0     ; 2
    sta THudTemp    ; 3 
    ldx THudDigits+5; 3
    lda SprN0,x ; 4
    and #$0F  ; 2
    ora THudTemp ; 3
    sta GRP0 ; 3
    lda THudHealthH
    sta PF1
    cpy #5
    beq .hudScanline1A
    cpy #2
    beq .hudScanline1A
    lda #0
    sta WSYNC
    sta PF1
;=========== Scanline 1 ==============
    dec THudDigits+4 ; 5
    dec THudDigits+5 ; 5
    
    ldx THudDigits+4 ; 3
    lda SprN0,x  ; 4
    and #$F0     ; 2
    sta THudTemp    ; 3 
    ldx THudDigits+5; 3
    lda SprN0,x ; 4
    and #$0F  ; 2
    ora THudTemp ; 3
    sta GRP0 ; 3
    lda THudHealthH
    sta PF1
    dec THudDigits+4
    dec THudDigits+5
    lda #0
    dey
    sta WSYNC
    sta PF1
;=========== Scanline 0 ==============
    bpl .loop
; HUD LOOP End
    lda #85;#76 
    sta TIM8T ; Delay 8 scanlines
    lda #0
    sta ENAM0
    sta GRP1
    
    ldx THudDigits+4 ; 3
    lda SprN0,x  ; 4
    and #$F0     ; 2
    sta THudTemp    ; 3 
    ldx THudDigits+5; 3
    lda SprN0,x ; 4
    and #$0F  ; 2
    ora THudTemp ; 3
    sta GRP0 ; 3
    
    lda fgColor
    sta COLUPF
    
    ldx #0
    stx GRP0
    stx GRP1
    LOG_SIZE "-HUD KERNEL-", KERNEL_HUD
    lda KernelId
    beq .defaultWorldKernel
    lda BANK_ROM + 3
    jmp TextKernel
    
.defaultWorldKernel
; HMOVE setup
    jsr PosWorldObjects

.waitTimerLoop
    lda INTIM
    bne .waitTimerLoop
    sta WSYNC
    
    ldy #ROOM_HEIGHT
KERNEL_WORLD_RESUME:
    
    lda BANK_ROM + 0
    lda #$FF
    sta PF0
    sta PF1
    sta PF2

    lda bgColor
    sta COLUBK
    lda fgColor
    sta COLUPF
    lda enColor
    sta COLUP1
    
    lda #1
    ldx #0
    sta VDELP1
    stx NUSIZ1
    lda NUSIZ0_T
    sta NUSIZ0
    
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
    sta GRP1        ; 3
    lda rPF1RoomR,x ; 4
    sta PF1         ; 3
    
; Ball
    lda blH         ; 3 ball height
    dcp blDY        ; 5
    lda #1          ; 2
    adc #0          ; 2
    sta WSYNC       ; 3  34-35 cycles, not counting WSYNC (can save cycle by fixing bcs)
    sta ENABL

    ldx roomSpr     ; 3
    lda rPF1RoomL,x ; 4
    sta PF1         ; 3

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
    adc #0          ; 2

    sta WSYNC
    dey
    bpl KERNEL_LOOP
    lda fgColor
    sta COLUBK
    lda #0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1
    sta ENAM0
    sta PF0
    LOG_SIZE "-KERNEL WORLD-", KERNEL_LOOP

OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer
    
; test player board bounds
    ldy roomId
    lda plX
    cmp #BoardXR+1
    bne .plXRSkip
    ldx #BoardXL
    stx plX
    inc roomId
.plXRSkip
    cmp #BoardXL-1
    bne .plXLSkip
    ldx #BoardXR
    stx plX
    dec roomId
.plXLSkip
    lda plY
    cmp #BoardYU+1
    bne .plYUSkip
    ldx #BoardYD
    stx plY
    clc
    lda roomId
    adc #$F0
    sta roomId
    lda plY
.plYUSkip
    cmp #BoardYD-1
    bne .plYDSkip
    ldx #BoardYU
    stx plY
    clc
    lda roomId
    adc #$10
    sta roomId
.plYDSkip

    cpy roomId
    beq .skipSwapRoom
    lda #$80
    ora roomFlags
    sta roomFlags
.skipSwapRoom
    bit roomFlags
    bmi .skipCollisionPosReset
    ldx #1
.posResetLoop
    lda CXP0FB,x
    jsr TestCollisionReset
    dex
    bpl .posResetLoop
.skipCollisionPosReset
   
.RoomScript:   
    jsr RoomScriptDel
    
.EnSystem:
    jsr EnSystem

OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne OVERSCAN_WAIT

    jmp VERTICAL_SYNC


;==============================================================================
; CollisionReset
;----------
; N = reset collision
; x = Player (0), Enemy (1)
;==============================================================================
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

    ; load world bank
    ldy worldId
    beq .worldBankSet
    ldy #1
.worldBankSet
    sty worldBank
    lda BANK_ROM + 1,y

    ldy roomId
    lda WORLD_RS,y
    sta roomRS
    lda WORLD_EX,y
    sta roomEX
    lda WORLD_EN,y
    sta roomEN
    lda WORLD_WA,y
    sta roomWA
    
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
    
; set OR mask for the room sides    
    lda worldId
    beq .WorldRoomOrSides
; sneak in opportunity to update roomDoors
    ldx worldBank
    lda BANK_RAM + 1,x
    ldy roomId
    lda rRoomFlag,y
    and #%01010101
    sta Temp6
    asl
    clc
    adc Temp6
    eor #$FF
    and roomDoors
    sta roomDoors
    lda BANK_RAM
    
    lda #$C0
    .byte $2C
.WorldRoomOrSides
    lda #$00
    sta Temp6
    
    ldy #ROOM_SPR_HEIGHT-1
.roomInitMem
    lda BANK_ROM + 0
.roomInitMemLoop
    lda (Temp0),y ; PF1L
    ora Temp6
    sta wPF1RoomL+2,y
    lda (Temp4),y ; PF1R
    ora Temp6
    sta wPF1RoomR+2,y
    lda (Temp2),y ; PF2
    sta wPF2Room+2,y
    dey
    bpl .roomInitMemLoop

; All room sprite data has been read, we can now switch banks to
; conserve Bank 7 space
    lda BANK_ROM + 6
    jmp LoadRoom_B6
    LOG_SIZE "Room Load", LoadRoom
        
;==============================================================================
; Generate Random Number
;-----------------------
;   A - returns the randomly generated value
;   Cycles = 23 per call
;==============================================================================
Random:
        lda Rand8
        lsr
        bcc noeor
        eor #$B4
noeor:
        sta Rand8
        rts

RoomScriptDel:
    lda BANK_ROM + 4
    ldx roomRS
    lda RoomScriptH,x
    pha
    lda RoomScriptL,x
    pha
    rts

EnemyAIDel:
    lda BANK_ROM + 4
    ldx enType
    lda EnemyAIH,x
    pha
    lda EnemyAIL,x
    pha
    rts

    LOG_SIZE "-CODE-", ENTRY

DataStart

    ;align 16
Mul8:
    .byte 0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38, 0x40, 0x48, 0x50, 0x58
Lazy8:
    .byte 0x01, 0x02, 0x04, 0x08
Bit8:
    .byte 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80
    
    
    ;align 4 

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
    ;align 16
WorldColors:
    .byte $00, COLOR_DARK_BLUE, $00, COLOR_LIGHT_BLUE, $42, $7A, COLOR_PATH, $06, $02, COLOR_LIGHT_BLUE, COLOR_GREEN_ROCK, COLOR_LIGHT_WATER, $00, COLOR_CHOCOLATE, COLOR_GOLDEN, $0E
HealthPattern:
    .byte $00, $01, $03, $07, $0F, $1F, $3F, $7F, $FF 

Spr8WorldOff:
    .byte (ROOM_HEIGHT+8), (TEXT_ROOM_HEIGHT+8)
Spr1WorldOff: 
    .byte (ROOM_HEIGHT+1), (TEXT_ROOM_HEIGHT+1)
RoomWorldOff:
    .byte (ROOM_PX_HEIGHT-1), (TEXT_ROOM_PX_HEIGHT-1)

    LOG_SIZE "-DATA-", DataStart

;==============================================================================
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
;==============================================================================
/*
PosObject: SUBROUTINE
        sec
        sta WSYNC
.DivideLoop
        sbc #15        ; 2  2 - each time thru this loop takes 5 cycles, which is
        bcs .DivideLoop; 2  4 - the same amount of time it takes to draw 15 pixels
        eor #7         ; 2  6 - The EOR & ASL statements convert the remainder
        asl            ; 2  8 - of position/15 to the value needed to fine tune
        asl            ; 2 10 - the X position
        asl            ; 2 12
        asl            ; 2 14
        sta.wx HMP0,X  ; 5 19 - store fine tuning of X
        sta RESP0,X    ; 4 23 - set coarse X position of object
        rts            ; 6 29
*/
        
;==============================================================================
; PosWorldObjects
;----------
; Sets X position for all TIA objects
; X position must be between 0-134 ($00 to $86)
; Higher values will cause an extra cycle
;==============================================================================
PosWorldObjects: SUBROUTINE
    sec            ; 2
    ldx #4
.Loop
    sta WSYNC      ; 3
    lda plX,x      ; 4
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
; scn cycle 67
    dex ; 69
    bpl .Loop ; 72
        
    sta WSYNC
    sta HMOVE
    rts

; $18 2 iter (9) + 15 = 24
; $18
; $60 7 iter (34) + 15 = 49
PosHudObjects: SUBROUTINE
    sta WSYNC
    ; 26 cycles start
    
    lda worldId         ; 3
    ; 7 cycle start
    bne .dungeon        ; 2/3
    lda #$F             ; 2
    bne .roomIdMask     ; 3
.dungeon
    lda #$7             ; 2
    nop                 ; 2
.roomIdMask
    ; 7 cycle end
    
    and roomId          ; 3
    eor #7              ; 2
    asl                 ; 2
    asl                 ; 2
    asl                 ; 2
    asl                 ; 2
    sta HMM0            ; 3
    ; 26 cycles end
    sta RESP1           ; 3 - Map Sprite
    sta RESM0           ; 3 - Player Dot
    ; 18 cycles start
    lda worldId         ; 3
    bne .MapShift       ; 2/3
    lda #0              ; 2
    beq .SetMapShift    ; 3
.MapShift
    lda #$F0            ; 2
    nop                 ; 2
.SetMapShift
    sta HMP1            ; 3
    lda #0              ; 2
    sta HMP0            ; 3
    ; 18 cycles end
    sta RESP0           ;  - Inventory Sprites
    
    sta WSYNC
    sta HMOVE
    rts