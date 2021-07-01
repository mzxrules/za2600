;==============================================================================
; mzxrules 2021
;==============================================================================
INIT:
    ; set player colors
    lda #COLOR_PLAYER_00
    sta COLUP0

    lda #%00110001 ; ball size 8, reflect playfield
    sta CTRLPF
    sta VDELBL
    
    ; seed RNG
    ; lda INTIM
    ; sta Rand8
    ; eor #$FF
    sta Rand16
    
    ; set ball
    lda #$60
    sta blY
    
    ; set player stats
    lda #$18
    sta plHealthMax
    
    jsr RESPAWN

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
    ; disable VDEL for HUD drawing
    sta VDELP0
    sta VDELP1
    ;sta PF0     ; blank the playfield
    ;sta PF1
    ;sta PF2
    ;sta GRP0    ; blanks player0 if VDELP0 was off
    ;sta GRP1    ; blanks player0 if VDELP0 was on, player1 if VDELP1 was off
    ;sta GRP0    ; blanks                           player1 if VDELP1 was on
    sta WSYNC
    sta VSYNC

VERTICAL_BLANK: SUBROUTINE ; 37 SCANLINES
    lda roomFlags
    and #~RF_LOADED_EV
    sta roomFlags
    bpl .skipLoadRoom
    ora #RF_LOADED_EV
    and #~[RF_LOAD_EV + RF_NO_ENCLEAR + RF_CLEAR]
    sta roomFlags
    lda #-$18
    sta roomTimer
    lda #$22
    sta plState
    jsr LoadRoom
    lda #EN_NONE
    sta enType
    sta blType
    sta blTemp
    sta KernelId
.skipLoadRoom

    lda BANK_ROM + 6
    bit roomFlags
    bvs .roomLoadCpuSkip
    jsr ProcessInput_B6
    jsr Random
    jsr PlayerItem_B6
.roomLoadCpuSkip

; room setup
    jsr KeydoorCheck_B6
    jsr UpdateDoors_B6
    lda BANK_ROM + 5
    jsr UpdateAudio_B5
    jsr EntityDel
    
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
    sec
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
    
.enemy_missile_setup
    lda #40
    sta m1DY
    
.ball_sprite_setup
; ball draw height
    lda Spr8WorldOff,y;#(ROOM_HEIGHT+1)
    sec
    sbc blY
    sta blDY
    
.minimap_setup
; map color and sprite id
    ldx worldId
    ldy #COLOR_MINIMAP
    cpx #2
    bmi .setMinimapColor
    lda Bit8-2,x
    and itemMaps
    bne .setMinimapColor
    ldx #0
    ldy #2
.setMinimapColor
    sty COLUP1

; sprite setup
    lda #<(MINIMAP) ; Sprite + height-1
    clc
    adc Mul8,x
    sta mapSpr
    lda #>(MINIMAP)
    sta mapSpr+1
; double width map if on overworld
    ldx #5
    lda worldId
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
.PRE_HUD:
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
    
    lda rFgColor
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
    lda #1
    sta VDELP0
    
    jsr rKERNEL ; JUMP WORLD KERNEL
    
; Post Kernel
    lda rFgColor
    sta COLUBK
    lda #0
    sta PF1
    sta PF2
    sta GRP1
    sta GRP0
    sta ENAM0
    sta PF0
    
OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer
; reset world kernel vars
    lda #7
    sta wENH
    
; update player stun timer
    lda plStun
    cmp #1
    adc #0
    sta plStun
    
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
    beq .endSwapRoom
    lda #RF_LOAD_EV
    ora roomFlags
    sta roomFlags
.endSwapRoom
  
; Phase player through walls if flag set
.PlayerWallPass
    lda plState
    and #$20
    beq .skipPlayerWallPass
    bit CXP0FB ; if player collided with playfield, keep moving through wall
    bmi .playerWallPassCont
    lda #$00
    sta plState
    .bpl .skipPlayerWallPass
    
.playerWallPassCont
    ldx plDir
    jsr PlMoveDirDel
    jmp .skipCollisionPosReset
    
.skipPlayerWallPass
    bit roomFlags
    bmi .skipCollisionPosReset
    ldx #1
.posResetLoop
    lda CXP0FB,x
    jsr TestCollisionReset
    dex
    bpl .posResetLoop
.skipCollisionPosReset
    
    lda BANK_ROM + 4
.EnSystem:
    jsr EnSystem
    
.RoomScript:   
    jsr RoomScriptDel
    
.BallScript:
    ldx blType
    jsr BallDel
    
; Update Room Flags
    lda #RF_NO_ENCLEAR
    bit roomFlags
    bvs .endUpdateRoomFlags
    bne .endUpdateRoomFlags
    lda roomENCount
    bne .endUpdateRoomFlags
    lda roomFlags
    ora #RF_CLEAR
    sta roomFlags
.endUpdateRoomFlags
    
; Update Shutter Doors
.RoomOpenShutterDoor
    lda worldId
    beq .endOpenShutterDoor
    lda roomTimer
    cmp #1
    adc #0
    sta roomTimer
    bmi .endOpenShutterDoor
    lda roomFlags
    and #RF_CLEAR
    beq .endOpenShutterDoor
    lda roomDoors
    asl ; keydoor/walls have lsb 1, shift to msb to keep high bit
    ora #%01010101 ; always keep low bit 
    and roomDoors
    cmp roomDoors
    sta roomDoors
    beq .endOpenShutterDoor
    lda #SFX_BOMB
    sta SfxFlags
.endOpenShutterDoor

; Game Over check
    ldy plHealth
    bne .skipGameOver
    jsr RsGameOver
.skipGameOver

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
    and #$C0
    beq .SkipPFCollision
    
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

LoadRoom: SUBROUTINE
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
    sta wFgColor
    lda WORLD_COLOR,y
    lsr
    lsr
    lsr
    lsr
    tax
    lda WorldColors,x
    sta wBgColor
    
    ; PF1 Right
    lda WORLD_T_PF1R,y
    tax
    and #$F0
    sta Temp4
    txa
    and #$01
    ora #$F0
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
    ora #$F0
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
    ora #$F0
    sta Temp3
    txa
    and #$0C
    asl
    ora roomDoors
    sta roomDoors
    
; set OR mask for the room sides    
    lda worldId
    beq .WorldRoomOrSides
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
    lda Rand16 + 0
    lsr
    rol Rand16 + 1
    bcc noeor
    eor #$B4
noeor:
    sta Rand16 + 0
    eor Rand16 + 1
    rts

EntityDel:
    lda BANK_ROM + 4
    ldx enType
    lda EntityH,x
    pha
    lda EntityL,x
    pha
    rts
    
PlMoveDirDel:
    lda PlMoveDirH,x
    pha
    lda PlMoveDirL,x
    pha
    rts

PlDirU:
    inc plY
    rts
PlDirD:
    dec plY
    rts

PlDirR:
    inc plX
    rts
PlDirL:
    dec plX
    rts

    ;align 16
Mul8:
    .byte 0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38, 0x40, 0x48, 0x50, 0x58
Lazy8:
    .byte 0x01, 0x02, 0x04, 0x08
Bit8:
    .byte 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80
    
WORLD_ENT: ; Initial room spawns for worlds 0-9
    .byte $77, $73, $00, $00, $00, $00, $F3, $00, $00, $00
    
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
    .byte 8, -2, 4, 4
SwordOff8X:
    .byte 8, -6, 4, 4
SwordOff4Y:
    .byte 3, 3, -3, 7
SwordOff8Y:
    .byte 3, 3, -7, 7
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
    
    INCLUDE "gen/PlMoveDir.asm"
    
;==============================================================================
; UPDATE_PL_HEALTH
;----------
; Changes player health
; A = amount to change health by
;==============================================================================
UPDATE_PL_HEALTH: SUBROUTINE
    ldy #SFX_PL_HEAL
    cmp #0
    bpl .playSfx
    bit plStun
    bmi .rts
    ldx #-24
    stx plStun
    ldy #SFX_PL_DAMAGE
.playSfx
    sty SfxFlags
    clc
    adc plHealth
    bpl .cont
    lda #0
.cont
    cmp plHealthMax
    bmi .setHp
    lda plHealthMax
.setHp
    sta plHealth
.rts
    rts
    
RESPAWN: SUBROUTINE
    lda #$18
    sta plHealth
SPAWN_AT_DEFAULT: SUBROUTINE
    lda #0
    sta plState
    lda #MS_PLAY_RSEQ
    sta SeqFlags
    
    lda #$40
    sta plX
    lda #$10
    sta plY
    
    ldy worldId
    lda WORLD_ENT,y
    sta roomId
    lda #RF_LOAD_EV
    sta roomFlags
    rts

KERNEL_WORLD: SUBROUTINE ; rKERNEL
    VKERNEL1 BgColor
    lda #COLOR_PATH
    sta COLUBK
    VKERNEL1 FgColor
    lda #COLOR_GREEN_ROCK
    sta COLUPF
    lda enColor
    sta COLUP1
    
    ldx NUSIZ1_T
    stx NUSIZ1
    lda NUSIZ0_T
    sta NUSIZ0
    
    lda #0
    tax
    
    sta WSYNC       ; 3
    sta CXCLR       ; 3
KERNEL_LOOP: SUBROUTINE ; 76 cycles per scanline
    sta ENAM0       ; 3
    stx GRP1        ; 3

    ldx roomSpr     ; 3
    lda rPF1RoomL,x ; 4
    sta PF1         ; 3
    lda rPF2Room,x  ; 4
    sta PF2         ; 3
    
; Player            ;    CYCLE 15
    lda #7          ; 2 player height
    dcp plDY        ; 5
    bcs .DrawP0     ; 2/3
    lda #0          ; 2
    .byte $2C       ; 4-5 BIT compare hack to skip 2 byte op
.DrawP0:
    lda (plSpr),y   ; 5
    
    sta GRP0        ; 3
; PF1R first line   
    lda rPF1RoomR,x ; 4
    sta PF1         ; 3
    
; Ball
    VKERNEL1 BLH
    lda #7          ; 2 ball height
    dcp blDY        ; 5
    lda #1          ; 2
    adc #0          ; 2
    sta ENABL       ; 3
    
; Enemy Missile     ;    CYCLE 15
    VKERNEL1 M1H
    lda #7          ; 3 enM height
    dcp m1DY        ; 5
    ;sta WSYNC
    lda #1          ; 2
    adc #0          ; 2
    sta ENAM1       ; 3

    lda rPF1RoomL,x ; 4
    sta PF1         ; 3
    lda rPF1RoomR,x ; 4
    pha             ; 3

; Enemy             ;    CYCLE 15
    VKERNEL1 ENH
    lda #7          ; 2     enemy height
    dcp enDY        ; 5
    bcs .DrawE0     ; 2/3
    lda #0          ; 2
    .byte $2C       ; 4-5   BIT compare hack to skip 2 byte op
.DrawE0:
    lda (enSpr),y   ; 5
    tax             ; 2
    
    pla             ; 4
    sta PF1         ; 3
; Playfield
    tya             ; 2
    and #3          ; 2
    beq .PFDec      ; 2/3
    .byte $2C       ; 4-5
.PFDec
    dec roomSpr     ; 5
    
; Player Missile    ;    CYCLE 15
    VKERNEL1 M0H
    lda #7          ; 2 plM height
    dcp m0DY        ; 5
    lda #1          ; 2
    adc #0          ; 2
    
    dey             ; 2
    sta WSYNC       ; 3
    bpl KERNEL_LOOP ; 3/2
    rts

    LOG_SIZE "-KERNEL WORLD-", KERNEL_WORLD
        
BANK_7_FREE:
    ORG $3FE0-$51
    RORG $FFE0-$51
        LOG_SIZE "-BANK 7- FREE", BANK_7_FREE
        
;==============================================================================
; PosWorldObjects
;----------
; Sets X position for all TIA objects within the world view
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
;==============================================================================
; PosHudObjects
;----------
; Positions all HUD elements within a single scanline
;----------
; Timing Notes: 
; $18 2 iter (9) + 15 = 24
; $18
; $60 7 iter (34) + 15 = 49
;==============================================================================
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