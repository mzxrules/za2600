;==============================================================================
; mzxrules 2021
;==============================================================================
MAIN_INIT:
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
MAIN_VERTICAL_SYNC: ; 3 SCANLINES
    jsr Random ; 35 cycles
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
    bvc .roomSkipInit
    lda #SLOT_RS_INIT
    sta BANK_SLOT
    jsr RsInit_Del
    lda #0
    beq .roomLoadCpuSkip
.roomSkipInit
    lda #SLOT_PL
    sta BANK_SLOT
    jsr PlayerInput
PAUSE_RETURN:
    jsr PlayerItem
.roomLoadCpuSkip

; room setup
    lda worldId
    beq .skipRoomChecks
    lda #SLOT_ROOM
    sta BANK_SLOT
    jsr DoorCheck
    jsr UpdateDoors
.skipRoomChecks

    lda #SLOT_AU_A
    sta BANK_SLOT
    lda #SLOT_AU_B
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_EN_D
    sta BANK_SLOT
    jsr EnDraw_Del

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
    sta wNUSIZ1_T

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
    lda #RF_EV_LOAD
    ora roomFlags
    sta roomFlags
.endSwapRoom

; Check Warp in
    lda plState2
    and #PS_ACTIVE_ITEM
    cmp #PLAYER_FLUTE
    bne .runCollision
    bit plItemDir
    bpl .runCollision
    jmp endPFCollision
.runCollision

;==============================================================================
; Perform PF Collision Detection
;==============================================================================
    ldy #0 ; PFCollision
    lda plState
    and #~PS_LOCK_AXIS
    sta plState

    bit roomFlags
    bmi endPFCollision ; RF_EV_LOAD

; Player Collision Detection
    and #PS_GLIDE
    beq .skipPlayerWallPass
; Check if player should be pushed through wall
    bit CXP0FB ; if player collided with playfield, keep moving through wall
    bpl .completePlayerWallPass
    ldx plDir
    jsr PlMoveDirDel
; Skip player PFCollision
    ldy #1
    bne PFCollision

.completePlayerWallPass
    lda #$00
    sta plState

.skipPlayerWallPass

;==============================================================================
; PFCollision
;----------
; y = Player (0), Enemy (1)
;==============================================================================
PFCollision: SUBROUTINE

    ; Check RF_PF_IGNORE
    lda RoomFlagPFCollision,y
    and roomFlags
    beq .collisionPosReset
    ldx plX,y
    cpx #EnBoardXL
    bmi .collisionPosReset
    cpx #EnBoardXR+1
    bpl .collisionPosReset
    ldx plY,y
    cpx #EnBoardYD
    bmi .collisionPosReset
    cpx #EnBoardYU+1
    bpl .collisionPosReset

    ; If entity, skip collision
    cpy #1
    beq .SkipPFCollision

    ; Else check if RF_PF_AXIS should be in effect for the player
    bit RF_PF_AXIS
    beq .SkipPFCollision ; branch on RF_PF_IGNORE
    bit CXP0FB
    bpl .collisionPosReset
    lda ITEMV_BOOTS
    bit ITEMF_BOOTS ; Is this a bug?
    beq .collisionPosReset
    lda plState
    ora PS_LOCK_AXIS
    sta plState
    bne .SkipPFCollision ; branch always

.collisionPosReset
    lda CXP0FB,y ; CXP1FB
    and #$C0
    beq .SkipPFCollision

    lda plXL,y
    sta plX,y
    lda plYL,y
    sta plY,y
.SkipPFCollision:
    lda plX,y
    sta plXL,y
    lda plY,y
    sta plYL,y

    iny
    cpy #2
    bmi PFCollision
endPFCollision

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
    jsr Rs_Del

.Entity
    lda #SLOT_EN_A
    sta BANK_SLOT
    jsr En_Del

.Missile:
    lda #SLOT_RS_A
    sta BANK_SLOT
    lda #SLOT_RS_B
    sta BANK_SLOT
    jsr MiSystem

.BallScript:
    lda #SLOT_PU_A
    sta BANK_SLOT
    jsr BlSystem

; Update Room Flags
    lda #RF_NO_ENCLEAR
    bit roomFlags
    bvs .endUpdateRoomFlags ; RF_EV_LOADED
    bne .endUpdateRoomFlags ; RF_NO_ENCLEAR
    lda roomENCount
    bne .endUpdateRoomFlags
    lda roomFlags
    ora #RF_EV_CLEAR
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
    and #RF_EV_CLEAR
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

    jsr Rs_GameOver
.skipGameOver

OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne OVERSCAN_WAIT
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC

    jmp MAIN_VERTICAL_SYNC

;==============================================================================
; Generate Random Number
;-----------------------
;   A - returns the randomly generated value
;   X, Y untouched
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

WORLD_ENT: ; Initial room spawns for worlds 0-9
    .byte $77, $73, $7D, $7C, $71, $76, $79, $71, $75, $7E

    INCLUDE "gen/PlMoveDir.asm"

RoomFlagPFCollision
    .byte #[RF_PF_IGNORE + RF_PF_AXIS], #[RF_PF_IGNORE]

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
    bit ITEMV_RING_RED
    bpl .checkBlueRing ; #ITEMF_RING_RED
    sec
    ror
    ;bit ITEMV_RING_BLUE
.checkBlueRing
    bvc .addDamage ; #ITEMF_RING_BLUE
    sec
    ror
.addDamage
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
    lda #RF_EV_LOAD
    sta roomFlags
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

EnNpcGiveOne:
    lda #SLOT_SH
    sta BANK_SLOT
    jmp EnNpcGiveOne_
