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
    sta m1Y
    
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
    lda #SLOT_B7_D
    sta BANK_SLOT
    jsr LoadRoom
    lda #EN_NONE
    sta enType
    sta blType
    sta blTemp
    sta plItemTimer
    sta KernelId
.skipLoadRoom

    ;lda BANK-ROM + 6
    lda #SLOT_B6_A
    sta BANK_SLOT
    lda #SLOT_B6_B
    sta BANK_SLOT

    bit roomFlags
    bvs .roomLoadCpuSkip
    jsr ProcessInput_B6
    jsr Random
    jsr PlayerItem_B6
.roomLoadCpuSkip

; room setup
    jsr KeydoorCheck_B6
    jsr UpdateDoors_B6
    lda #SLOT_B5_A
    sta BANK_SLOT
    lda #SLOT_B5_B
    sta BANK_SLOT
    jsr UpdateAudio_B5
    jsr EntityDel
    
;==============================================================================
; Pre-Position Sprites
;==============================================================================

    lda #SLOT_B7_C
    sta BANK_SLOT
    jmp POSITION_SPRITES

; ===================================================
; Kernel Main
; ===================================================
KERNEL_MAIN: SUBROUTINE ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN
    sta VBLANK

KERNEL_HUD: SUBROUTINE
    ldy #7 ; Draw Height
    lda #0
    sta WSYNC
    beq .loop
;=========== Scanline 1A ==============
.hudScanline1A
    ldx #3
    sta WSYNC
    sta GRP0
    sta PF1
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
    lda #0
    cpy #5
    beq .hudScanline1A
    cpy #2
    beq .hudScanline1A
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
    lda #85
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
    lda #SLOT_B3_A
    sta BANK_SLOT
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
    
    lda #SLOT_B0_B
    sta BANK_SLOT

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
    lda #0
    sta NUSIZ1_T
    
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
    
    lda #SLOT_B4_A
    sta BANK_SLOT
    lda #SLOT_B4_B
    sta BANK_SLOT
.ClearDropSystem:
    jsr ClearDropSystem
    
.EnSystem:
    jsr EnSystem
    
.RoomScript:
    lda #SLOT_B6_A
    sta BANK_SLOT
    lda #SLOT_B6_B
    sta BANK_SLOT
    jsr RoomScriptDel
    
.BallScript:
    lda #SLOT_B4_A
    sta BANK_SLOT
    lda #SLOT_B4_B
    sta BANK_SLOT
    ldx blType
    jsr BallDel
    
; Update Room Flags
    lda #RF_NO_ENCLEAR
    bit roomFlags
    bvs .endUpdateRoomFlags ; RF_LOADED_EV
    bne .endUpdateRoomFlags ; RF_NO_ENCLEAR
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
    lda #SLOT_B6_A
    sta BANK_SLOT
    lda #SLOT_B6_B
    sta BANK_SLOT

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
    lda #SLOT_B4_A
    sta BANK_SLOT

    lda #SLOT_B4_B
    sta BANK_SLOT
    jmp ENTITY_DEL_CONT
    
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
    .byte $77, $73, $79, $00, $00, $00, $F3, $00, $00, $FE

    ;align 16
WorldColors:
    .byte $00, COLOR_DARK_BLUE, $00, COLOR_LIGHT_BLUE-2, $42, $7A, COLOR_PATH, $06, $02, COLOR_LIGHT_BLUE-2, COLOR_GREEN_ROCK, COLOR_LIGHT_WATER, $00, COLOR_CHOCOLATE, COLOR_GOLDEN, $0E
HealthPattern:
    .byte $00, $01, $03, $07, $0F, $1F, $3F, $7F, $FF 

Spr8WorldOff:
    .byte (ROOM_HEIGHT+8), (TEXT_ROOM_HEIGHT+8), (TEXT_ROOM_HEIGHT+8)
Spr1WorldOff: 
    .byte (ROOM_HEIGHT+1), (TEXT_ROOM_HEIGHT+1)
RoomWorldOff:
    .byte (ROOM_PX_HEIGHT-1), (TEXT_ROOM_PX_HEIGHT-1), (TEXT_ROOM_PX_HEIGHT-1)
    
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
    ldx #-48
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

GiItemColors:
    .byte COLOR_DARKNUT_RED     ; GiRecoverHeart
    .byte COLOR_DARKNUT_RED     ; GiFairy
    .byte COLOR_DARKNUT_BLUE    ; GiBomb
    .byte COLOR_TRIFORCE        ; GiRupee5

    .byte COLOR_TRIFORCE        ; GiTriforce
    .byte COLOR_DARKNUT_RED     ; GiHeart
    .byte COLOR_TRIFORCE        ; GiKey
    .byte COLOR_TRIFORCE        ; GiMasterKey

    .byte $06                   ; GiSword2
    .byte $0E                   ; GiSword3
    .byte COLOR_DARKNUT_BLUE    ; GiCandle
    .byte COLOR_DARKNUT_RED     ; GiMeat

    .byte $0E                   ; GiBoots
    .byte COLOR_DARKNUT_RED     ; GiRing
    .byte COLOR_DARKNUT_BLUE    ; GiPotion
    .byte $F0                   ; GiRaft
    
    .byte COLOR_TRIFORCE        ; GiFlute
    .byte COLOR_DARKNUT_RED     ; GiFireMagic
    .byte $F0                   ; GiBow
    .byte COLOR_TRIFORCE        ; GiArrows

    .byte COLOR_DARKNUT_RED     ; GiBracelet
    .byte COLOR_TRIFORCE        ; GiMap
        
EnItem:; SUBROUTINE
    ldy roomEX
EnItemDraw: SUBROUTINE ; y == itemDraw
    lda #>SprItem0
    sta enSpr+1
    lda GiItemColors,y
    tax
    cpy #5
    bpl .skipItemColor
    lda Frame
    and #$10
    beq .skipItemColor
    ldx #COLOR_LIGHT_BLUE
.skipItemColor
    stx enColor
    tya
    asl
    asl
    asl
    clc
    adc #<SprItem0
    sta enSpr
.rts
    rts

    INCLUDE "gen/mesg_digits.asm"
    
;BANK_7_FREE:
;    ORG $07E0-$51
;    RORG $FFE0-$51
;        LOG_SIZE "-BANK 7- FREE", BANK_7_FREE
    
;==============================================================================
; PosWorldObjects
;----------
; Sets X position for all TIA objects within the world view
; X position must be between 0-134 ($00 to $86)
; Higher values will waste an extra scanline
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
