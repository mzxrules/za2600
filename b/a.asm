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
    lda worldId
    beq .skipRoomChecks
    lda #SLOT_ROOM
    sta BANK_SLOT
    jsr KeydoorCheck
    jsr UpdateDoors
.skipRoomChecks

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
  
; Perform PF Collision Detection
; Phase player through walls if flag set
.PlayerWallPass
    lda plState
    and #~PS_LOCK_AXIS
    sta plState
    and #PS_GLIDE
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

    ; Check PF Ignore
    lda roomFlags
    and #[RF_PF_IGNORE + RF_PF_AXIS]
    beq .collisionPosReset
    ldx plX
    cpx #EnBoardXL
    bmi .collisionPosReset
    cpx #EnBoardXR+1
    bpl .collisionPosReset
    ldx plY
    cpx #EnBoardYD
    bmi .collisionPosReset
    cpx #EnBoardYU+1
    bpl .collisionPosReset

    bit RF_PF_AXIS
    beq .collisionPosReset_SkipPl ; branch on RF_PF_IGNORE
    bit CXP0FB
    bpl .collisionPosReset
    lda ITEMV_BOOTS
    bit ITEMF_BOOTS
    beq .collisionPosReset
    lda plState
    ora PS_LOCK_AXIS
    sta plState
    bne .collisionPosReset_SkipPl ; branch always

.collisionPosReset
    ldx #0
    lda CXP0FB
    jsr TestCollisionReset

.collisionPosReset_SkipPl
    ldx plX
    stx plXL
    ldx plY
    stx plYL

    ldx #1
    lda CXP1FB
    jsr TestCollisionReset

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

.Missile:
    jsr MiSystem
    
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
; Open all shutter doors (bit pattern %10)
; lsb is used check if the msb should be preserved
; only the %10 case results in a change in the msb
; converting it to open (bit pattern %00)
    lda roomDoors
    asl
    ora #%01010101 ; keep low bit 
    and roomDoors
    cmp roomDoors ; if roomDoors changed, at least one shutter opened
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
    .byte $77, $73, $79, $00, $71, $76, $73, $00, $00, $7E

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
    beq .zeroHp
    bpl .setHp
.zeroHp
    lda #ITEMF_POTION_RED
    bit ITEMV_POTION_RED
    beq .testBluePotion
    eor ITEMV_POTION_RED
    sta ITEMV_POTION_RED
    lda #80
    bpl .heal
.testBluePotion
    lda #ITEMF_POTION_BLUE
    bit ITEMV_POTION_BLUE
    beq .die
    eor ITEMV_POTION_BLUE
    sta ITEMV_POTION_BLUE
    lda #80
    bpl .heal
.die
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
    .byte COLOR_GRAY            ; GiSword2
    .byte COLOR_WHITE           ; GiSword3

    .byte COLOR_CHOCOLATE       ; GiBow
    .byte COLOR_CHOCOLATE       ; GiRaft
    .byte COLOR_WHITE           ; GiBoots
    .byte COLOR_TRIFORCE        ; GiFlute

    .byte COLOR_DARKNUT_RED     ; GiFireMagic
    .byte COLOR_DARKNUT_RED     ; GiBracelet
    .byte COLOR_DARKNUT_RED     ; GiMeat
    .byte COLOR_DARKNUT_BLUE    ; GiNote
    
    .byte COLOR_TRIFORCE        ; GiArrows
    .byte COLOR_WHITE           ; GiArrowsSilver
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

EnShopkeeper:
    lda #SLOT_SH
    sta BANK_SLOT
    jmp EnShopkeeper_

    INCLUDE "gen/mesg_digits.asm"

MiSpawn2: SUBROUTINE
    lda plX
    sec
    sbc MiSysAddX
    tax
    lda plY
    sec
    sbc MiSysAddY
    tay
    jsr Atan2

MiSpawn: SUBROUTINE
    ldy #1
    ldx mBType
    beq .rtsMiSysNext
    dey
    ldx mAType
    beq .rtsMiSysNext
    dey
; Y returns next free missile index, or -1 if no slots available
.rtsMiSysNext

MiSpawnImpl: SUBROUTINE
    cpy #$FF
    beq .rts
.rockInit
    sta mADir,y
    lda MiSysAddType
    sta mAType,y
    lda MiSysAddX
    sta mAx,y
    lda MiSysAddY
    sta mAy,y
    lda #$80
    sta mAxf,y
    sta mAyf,y
.rts
    rts

;==============================================================================
; Atan2
;----------
; X = Delta X
; Y = Delta Y
; Returns bitpacked value:
; & $80 = Delta X Sign
; & $40 = Delta Y Sign
; & $3F = index to Atan2 tables
;==============================================================================
Atan2: SUBROUTINE
    lda #0
    sta atan2Temp
    txa
    bpl .testYSign
    eor #$FF
    sec
    adc #0
    tax
    lda #$80
    sta atan2Temp
.testYSign
    tya
    bpl .reduceTest
    eor #$FF
    sec
    adc #0
    tay
    lda atan2Temp
    ora #$40
    sta atan2Temp
.reduceTest
    cpx #8
    bpl .reduce
    cpy #8
    bmi .result
.reduce
    txa
    lsr
    tax
    tya
    lsr
    tay
    bpl .reduceTest ;always branch
.result
    lda Mul8,y
    clc
    adc atan2Temp
    sta atan2Temp
    txa
    adc atan2Temp
    rts

    LOG_SIZE "a", INIT
    ORG BANK_ALWAYS_ROM + $400 - $1E
    RORG $FFFF-($1E-1)
    
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
    lda plX,x      ; 4  4 - Offsets by 12 pixels
DivideLoop
    sbc #15        ; 2  6 - each time thru this loop takes 5 cycles, which is
    bcs DivideLoop ; 2  8 - the same amount of time it takes to draw 15 pixels
    eor #7         ; 2 10 - The EOR & ASL statements convert the remainder
    asl            ; 2 12 - of position/15 to the value needed to fine tune
    asl            ; 2 14 - the X position
    asl            ; 2 16
    asl            ; 2 18
    sta.wx HMP0,X  ; 5 23 - store fine tuning of X
    sta RESP0,X    ; 4 27 - set coarse X position of object
;                  ;   67, which is max supported scan cycle 
    dex            ; 2 69
    bpl .Loop      ; 3 72
    
    sta WSYNC
    sta HMOVE
    rts