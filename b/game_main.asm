;==============================================================================
; mzxrules 2021
;==============================================================================
MAIN_ENTRY:

;TOP_FRAME ;3 37 192 30
MAIN_VERTICAL_SYNC: ; 3 SCANLINES
    jsr Random ; 35 cycles
    lda #$80
    sta m1Y
    jsr VERTICAL_SYNC

VERTICAL_BLANK: SUBROUTINE ; 37 SCANLINES
    lda #SLOT_F0_ROOM
    sta BANK_SLOT
    jsr RoomUpdate

.Missile:
    lda #SLOT_F0_MISSILE
    sta BANK_SLOT
    jsr MiSystem

    lda #SLOT_F0_PL
    sta BANK_SLOT
    jsr PlayerPause
PAUSE_RETURN:
    jsr PlayerInput
    lda #SLOT_F4_PL2
    sta BANK_SLOT
    jsr PlayerItem

; room setup
    lda worldId
    bmi .skipRoomChecks
    lda #SLOT_F0_ROOM
    sta BANK_SLOT
    jsr DoorCheck
    jsr UpdateDoors
.skipRoomChecks
ROOMSCROLL_RETURN:  ; .roomLoadCpuSkip

    lda #SLOT_F4_AU1
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_F0_ENDRAW
    sta BANK_SLOT
    jsr EnDraw_Del

;==============================================================================
; Pre-Position Sprites and Draw Frame
;==============================================================================

    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    jsr POSITION_SPRITES

OVERSCAN: SUBROUTINE ; 30 scanlines
; reset world kernel vars
    lda #7
    sta wENH
    lda #0
    sta wNUSIZ1_T
    sta wREFP1_T

    sta WSYNC
    lda #2
    sta VBLANK
    lda #36
    sta TIM64T ; 30 scanline timer
    sta wHaltVState

; update player stun timer
    lda plStun
    bpl .end_plStun_inc
    clc
    adc #4
    sta plStun
.end_plStun_inc

; test player board bounds
    ldy #4
    lda plY
    cmp #BoardYD-1
    beq .swapRoom
    dey
    cmp #BoardYU+1
    beq .swapRoom
    dey
    lda plX
    cmp #BoardXR+1
    beq .swapRoom
    dey
    cmp #BoardXL-1
    bne .endSwapRoom
.swapRoom
    sty wHaltType
    lda #RF_EV_LOAD
    ora roomFlags
    sta roomFlags
    ldx ObjXYAddr-1,y
    lda PlayerXYRoomPos-1,y
    sta OBJ_PL,x
    lda roomIdNext
    clc
    adc RoomScrollNext-1,y
    sta roomIdNext
.endSwapRoom

;==============================================================================
; Perform Player PF Collision Detection
;==============================================================================

; Check Warp in
    lda plState3
    and #PS_ACTIVE_ITEM2
    cmp #PLAYER_FLUTE_FX
    bne .runCollision
    bit plItem2Dir ; PS_CATCH_WIND
    bpl .runCollision
    jmp endPFCollision
.runCollision

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
    ldy plDir
    ldx ObjXYAddr,y
    lda OBJ_PL,x
    clc
    adc PlayerXYDist1,y
    sta OBJ_PL,x
; Skip player PFCollision
    jmp endPFCollision

.completePlayerWallPass
    lda #$00
    sta plState

.skipPlayerWallPass

PFCollision: SUBROUTINE

    ; Check RF_PF_IGNORE
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


    ; Check if RF_PF_AXIS should be in effect for the player
    and #RF_PF_AXIS
    beq .SkipPFCollision ; branch on RF_PF_IGNORE
    bit CXP0FB
    bpl .collisionPosReset
    lda #ITEMF_BOOTS
    bit ITEMV_BOOTS
    beq .collisionPosReset
    lda plState
    ora #PS_LOCK_AXIS
    sta plState
    bne .SkipPFCollision ; branch always

.collisionPosReset
    lda CXP0FB
    and #$C0
    beq .SkipPFCollision

    lda plXL
    sta plX
    lda plYL
    sta plY
.SkipPFCollision:
    lda plX
    sta plXL
    lda plY
    sta plYL
endPFCollision

    lda #SLOT_F0_EN
    sta BANK_SLOT
.EnSystem:
    jsr EnSystem

.RoomScript:
    jsr Rs_Del

.Entity
    ldx #1
    stx enNum

.EntityLoop
    ldx enNum
    jsr En_Del
    lda plState2
    eor #EN_LAST_DRAWN
    sta plState2
    dec enNum
    bpl .EntityLoop

    lda #SLOT_F0_EN
    sta BANK_SLOT
    jsr EnSysCleanShift

.BallScript:
    lda #SLOT_F0_PU
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

; Update Room Clear
    bit roomFlags
    bpl .end_roomclear_update
    ldy roomId
    bmi .end_roomclear_update
    lda roomENCount
    sta wWorldRoomENCount,y
.end_roomclear_update

; Update Shutter Doors
.RoomOpenShutterDoor
    lda worldId
    bmi .endOpenShutterDoor
    lda roomTimer
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
    lda #SFX_SHUTTER_DOOR
    sta SfxFlags
.endOpenShutterDoor

; Game Over check
    ldy plHealth
    bne .skipGameOver
    lda #SLOT_F0_RS0
    sta BANK_SLOT
    lda #SLOT_F4_RS1
    sta BANK_SLOT

    jsr Rs_GameOver
.skipGameOver

OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne OVERSCAN_WAIT

    lda #SLOT_F0_PU
    sta BANK_SLOT
    jmp UpdateRoomPush
;   sta WSYNC
;   jmp MAIN_VERTICAL_SYNC

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

ObjXYAddr:
    .byte plX, plX, plY, plY

PlayerXYDist1:
    .byte -1, 1, 1, -1

PlayerXYRoomPos:  ; For repositioning player falling off board in dir
    .byte #BoardXR, #BoardXL, #BoardYD, #BoardYU

RoomScrollNext:  ; For repositioning player falling off board in dir
    .byte -1, 1, $F0, $10

WorldData_Entrance:  ; Initial room spawns for worlds 0-9
    .byte $73, $77 ; LV 1
    .byte $7D, $79 ; LV 2
    .byte $7C, $75 ; LV 3
    .byte $71, $7D ; LV 4
    .byte $76, $72 ; LV 5
    .byte $79, $74 ; LV 6
    .byte $71, $71 ; LV 7
    .byte $76, $77 ; LV 8
    .byte $7E, $7C ; LV 9
    .byte $77, $77

;==============================================================================
; UPDATE_PL_HEALTH
;----------
; Changes player health
; A = amount to change health by
; X untouched
;==============================================================================
UPDATE_PL_HEALTH: SUBROUTINE
    cmp #0
    bpl .heal

; damage
    bit plStun
    bmi .rts
    tay
    clc
    lda #PL_STUN_TIME
    adc plDir
    sta plStun
    tya
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
    lda WorldData_Entrance-#LV_MIN,y
    sta roomIdNext
    lda #RF_EV_LOAD
    sta roomFlags
    rts

; X, Y is return world X/Y
ENTER_CAVE:
    lda roomId
    sta worldSR
    ora #$80
    sta roomIdNext

    stx worldSX
    sty worldSY

    lda roomFlags
    ora #RF_EV_LOAD
    sta roomFlags
    rts

; A = SeqFlags
RETURN_WORLD: SUBROUTINE
    sta SeqFlags
    lda worldSX
    sta plX
    lda worldSY
    sta plY
    lda worldSR
    sta roomIdNext
    lda worldId
    and #1
    ora #$80
    sta worldId
    lda roomFlags
    ora #RF_EV_LOAD
    sta roomFlags
    lda plState
    and #~#PS_LOCK_ALL
    sta plState
    lda plState2
    and #~#PS_HOLD_ITEM
    sta plState2
    lda #PL_DIR_D
    sta plDir
    rts

En_Zora:
En_Pols:
En_BossGhini:
En_BossDig:
En_BossPatra:
En_BossGanon:
    jmp EnSys_KillEnemyA

En_Del:
    lda #SLOT_F0_EN
    sta BANK_SLOT
    ldy enType,x
    lda EnH,y
    pha
    lda EnL,y
    pha
    lda En_BankLUT,y
    sta BANK_SLOT
    rts

Rs_Del:
    lda #SLOT_F0_RS0
    sta BANK_SLOT
    lda #SLOT_F4_RS1
    sta BANK_SLOT
    ldx roomRS
    lda RsH,x
    pha
    lda RsL,x
    pha
Rs_None:
Rs_BlockCenter:
Rs_FairyFountain:
Rs_BAD_CAVE:
Rs_BAD_HIDDEN_CAVE:
    rts