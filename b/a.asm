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
    ; sta Rand16+1
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
    lda #SLOT_ROOM
    sta BANK_SLOT
    jsr RoomUpdate


    bit roomFlags
    bvs .roomLoadCpuSkip
    lda #SLOT_PL_A
    sta BANK_SLOT
    lda #SLOT_PL_B
    sta BANK_SLOT
    jsr PlayerInput
    jsr Random
    jsr PlayerItem
.roomLoadCpuSkip

; room setup
    lda #SLOT_ROOM
    sta BANK_SLOT
    jsr KeydoorCheck
    jsr UpdateDoors

    lda #SLOT_AU_A
    sta BANK_SLOT
    lda #SLOT_AU_B
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_EN_A
    sta BANK_SLOT
    jsr EntityDel
    
;==============================================================================
; Pre-Position Sprites and Draw Frame
;==============================================================================

    lda #SLOT_DRAW
    sta BANK_SLOT
    jsr POSITION_SPRITES
    
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
    
    lda #SLOT_EN_A
    sta BANK_SLOT
    lda #SLOT_EN_B
    sta BANK_SLOT
.ClearDropSystem:
    jsr ClearDropSystem
    
.EnSystem:
    jsr EnSystem
    
.RoomScript:
    lda #SLOT_RS_A
    sta BANK_SLOT
    lda #SLOT_RS_B
    sta BANK_SLOT
    jsr RoomScriptDel
    
.BallScript:
    lda #SLOT_EN_A
    sta BANK_SLOT
    lda #SLOT_EN_B
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
    lda #SLOT_RS_A
    sta BANK_SLOT
    lda #SLOT_RS_B
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
    .byte $77, $73, $79, $00, $00, $00, $73, $00, $00, $7E

    ;align 16
HealthPattern:
    .byte $00, $01, $03, $07, $0F, $1F, $3F, $7F, $FF 

Spr8WorldOff:
    .byte (ROOM_HEIGHT+8), (TEXT_ROOM_HEIGHT+8), (SHOP_ROOM_HEIGHT+8)
Spr1WorldOff: 
    .byte (ROOM_HEIGHT+1), (TEXT_ROOM_HEIGHT+1), (SHOP_ROOM_HEIGHT+1)
RoomWorldOff:
    .byte (ROOM_PX_HEIGHT-1), (TEXT_ROOM_PX_HEIGHT-1), (SHOP_ROOM_PX_HEIGHT-1)
    
    INCLUDE "gen/PlMoveDir.asm"
    
;==============================================================================
; UPDATE_PL_HEALTH
;----------
; Changes player health
; A = amount to change health by
;==============================================================================
UPDATE_PL_HEALTH: SUBROUTINE
    cmp #0
    bpl .heal

; damage
    bit plStun
    bmi .rts
    ldx #-48
    stx plStun
    ldy #SFX_PL_DAMAGE
    clc
    adc plHealth
    bpl .setHp
    lda #0
    beq .setHp

.heal
    beq .rts
    ldy #SFX_PL_HEAL
    clc
    adc plHealth
    cmp plHealthMax
    bcc .setHp
    lda plHealthMax
.setHp
    sta plHealth
    sty SfxFlags
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
    .byte COLOR_BLACK           ; GiNone
    .byte COLOR_DARKNUT_RED     ; GiRecoverHeart
    .byte COLOR_DARKNUT_RED     ; GiFairy
    .byte COLOR_DARKNUT_BLUE    ; GiBomb

    .byte COLOR_TRIFORCE        ; GiRupee
    .byte COLOR_DARKNUT_BLUE    ; GiRupee5
    .byte COLOR_TRIFORCE        ; GiTriforce
    .byte COLOR_DARKNUT_RED     ; GiHeart

    .byte COLOR_TRIFORCE        ; GiKey
    .byte COLOR_TRIFORCE        ; GiMasterKey
    .byte $06                   ; GiSword2
    .byte $0E                   ; GiSword3

    .byte COLOR_CHOCOLATE       ; GiBow
    .byte COLOR_CHOCOLATE       ; GiRaft
    .byte $0E                   ; GiBoots
    .byte COLOR_TRIFORCE        ; GiFlute

    .byte COLOR_DARKNUT_RED     ; GiFireMagic
    .byte COLOR_DARKNUT_RED     ; GiBracelet
    .byte COLOR_DARKNUT_RED     ; GiMeat
    .byte COLOR_DARKNUT_BLUE    ; GiNote
    
    .byte COLOR_TRIFORCE        ; GiArrows
    .byte $0E                   ; GiArrowsSilver
    .byte COLOR_DARKNUT_BLUE    ; GiRingBlue
    .byte COLOR_DARKNUT_RED     ; GiRingRed
    .byte COLOR_DARKNUT_BLUE    ; GiPotionBlue
    .byte COLOR_DARKNUT_RED     ; GiPotionRed
    .byte COLOR_DARKNUT_BLUE    ; GiCandleBlue
    .byte COLOR_DARKNUT_RED     ; GiCandleRed

    .byte COLOR_TRIFORCE        ; GiMap
        
EnItem:; SUBROUTINE
    ldy roomEX
EnItemDraw: SUBROUTINE ; y == itemDraw
    lda #>SprItem0
    sta enSpr+1
    lda GiItemColors,y
    tax
    cpy #GI_TRIFORCE+1
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

EnClearDrop:
    lda #SLOT_SH
    sta BANK_SLOT
    jmp EnClearDrop_
EnStairs:
    lda #SLOT_SH
    sta BANK_SLOT
    jmp EnStairs_

EnShopkeeper
    lda #SLOT_SH
    sta BANK_SLOT
    jmp EnShopkeeper_

    INCLUDE "gen/mesg_digits.asm"
    
    LOG_SIZE "a", INIT
    ORG BANK_ALWAYS_ROM + $400 - $1E-1
    RORG $FFFF-($1E-1)-1
    
;==============================================================================
; PosWorldObjects
;----------
; Sets X position for all TIA objects within the world view
; X position must be between 0-134 ($00 to $86)
; Higher values will waste an extra scanline
; Does not touch Y register
;==============================================================================
PosWorldObjects: SUBROUTINE
    ldx #4
PosWorldObjects_X: SUBROUTINE
    sec            ; 2
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