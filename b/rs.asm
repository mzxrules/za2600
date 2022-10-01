;==============================================================================
; mzxrules 2021
;==============================================================================
    INCLUDE "gen/PlItem.asm"
FireOffX:
BombOffX:
    .byte 10, -4, 3, 3
FireOffY:
BombOffY:
    .byte 2, 2, -5, 9 
    
    .byte -2,  4, -8, 8, -8, 4,  4, -8, 8, -8, 4
BombAnimDeltaX:
    .byte -2, -4,  8, 0, -8, 4, -4,  8, 0, -8, 4
BombAnimDeltaY:

;==============================================================================
; MiSysUpdatePos
;----------
; Updates Missile Position
; Y = Missile Index
;==============================================================================
MiSysUpdatePos: SUBROUTINE
    lda mADir,y
    sta MiSysDir
    and #$3F
    tax
    lda Atan2X,x
    sta MiSysDX
    lda Atan2Y,x
    sta MiSysDY

    ldx #1
; Update X
.addDouble
    lda mAxf,y
    bit MiSysDir
    bmi .subX
    clc
    adc MiSysDX
    sta mAxf,y
    lda mAx,y
    adc #0
    sta mAx,y
    jmp .addY
.subX
    sec
    sbc MiSysDX
    sta mAxf,y
    lda mAx,y
    sbc #0
    sta mAx,y

; Update Y
.addY
    lda mAyf,y
    bit MiSysDir
    bvs .subY
    clc
    adc MiSysDY
    sta mAyf,y
    lda mAy,y
    adc #0
    sta mAy,y
    jmp .checkAddY
.subY
    sec
    sbc MiSysDY
    sta mAyf,y
    lda mAy,y
    sbc #0
    sta mAy,y
.checkAddY
    dex
    bpl .addDouble
    rts

MiSystem: SUBROUTINE
    ldy #1
.loop 
    lda mAType,y
    beq .cont
    jsr MiSysUpdatePos
.cont
    dey
    bpl .loop
    
; Select Missile Draw
    ldy #1
    lda mAType
    beq .draw
    dey
    lda mAType+1
    beq .draw
    lda Frame
    and #1
    tay
    
.draw
    lda NUSIZ1_T
    ora #$20
    sta NUSIZ1_T
    lda #3
    sta wM1H

    lda mAx,y
    sta m1X
    tax
    lda mAy,y
    sta m1Y

    cpx #EnBoardXL
    bmi .kill
    cpx #EnBoardXR+1 + 3
    bpl .kill
    cmp #EnBoardYU+1 + 2
    bpl .kill
    cmp #EnBoardYD - 2
    bmi .kill

.rts
    rts
.kill
    lda #0
    sta mAType,y
    lda #$80
    sta m1Y
    rts

PlayerArrow: SUBROUTINE
; ARROW
    bit plState
    bvc .skipSpawnArrow
    ; implement arrow check
    lda #-32
    sta plItemTimer
    ldy plDir
    sty plItemDir
    ; Spawn Arrow
    lda #SFX_ARROW
    sta SfxFlags
    lda ArrowWidth8,y
    sta NUSIZ0_T
    lda ArrowHeight8,y
    sta wM0H
    lda ArrowOff8X,y
    clc
    adc plX
    sta m0X
    lda ArrowOff8Y,y
    clc
    adc plY
    sta m0Y
    rts
    
.skipSpawnArrow
    ldy plItemTimer
    beq .offScreen
    lda m0X
    cmp #BoardXL
    bmi .offScreen
    cmp #BoardXR
    bpl .offScreen
    lda m0Y
    cmp #BoardYD
    bmi .offScreen
    cmp #BoardYU
    bmi .drawArrow
.offScreen
    lda #$80
    sta m0Y
    bmi .rts
.drawArrow
    ldy plItemDir
    lda ArrowDeltaX,y
    clc
    adc m0X
    sta m0X
    lda ArrowDeltaY,y
    clc
    adc m0Y
    sta m0Y
.rts
    rts

ArrowDeltaX:
    .byte 2, -2
ArrowDeltaY: 
    .byte 0, 0, -2, 2

PlayerFire: SUBROUTINE
; FIRE
    bit plState
    bvc .skipSpawnFire
    ; implement fire check
    lda #-32
    sta plItemTimer
    ldx plDir
    stx plItemDir
    clc
    lda FireOffX,x
    adc plX
    sta m0X
    clc
    lda FireOffY,x
    adc plY
    sta m0Y
    lda #$20
    sta NUSIZ0_T
    lda #0
    sta wM0H
.skipSpawnFire
    ldy plItemTimer
    bne .drawFire
    lda #$80
    sta m0Y
    bmi .rts
.drawFire
    tya
    and #3
    sta wM0H
.rts
    rts
    
    
PlayerBomb: SUBROUTINE
; Bombs
    bit plState
    bvc .skipDropBomb
    lda itemBombs
    beq .skipDropBomb
    sed
    sec
    sbc #1
    cld
    sta itemBombs
    lda #-32
    sta plItemTimer
    ldx plDir
    stx plItemDir
    clc
    lda BombOffX,x
    adc plX
    sta m0X
    clc
    lda BombOffY,x
    adc plY
    sta m0Y
    lda #$20
    sta NUSIZ0_T
    lda #3
    sta wM0H
.skipDropBomb
    ldy plItemTimer
    bne .drawBomb
    lda #$80
    sta m0Y
    bmi .rts
.drawBomb
    cpy #-11
    bmi .rts
    bne .skipDetonate
    lda #7
    sta wM0H
    lda #$30
    sta NUSIZ0_T
    lda #SFX_BOMB
    sta SfxFlags
    
.skipDetonate
    clc
    lda BombAnimDeltaX-$100,y
    adc m0X
    sta m0X
    clc
    lda BombAnimDeltaY-$100,y
    adc m0Y
    sta m0Y
.rts
    rts
    
    
    ;align 4
ArrowWidth4:
SwordWidth4:
    .byte $20, $20, $10, $10
ArrowWidth8:
SwordWidth8:
    .byte $30, $30, $10, $10
ArrowHeight4:
SwordHeight4:
    .byte 1, 1, 3, 3
ArrowHeight8:
SwordHeight8:
    .byte 1, 1, 7, 7
ArrowOff4X:
SwordOff4X:
    .byte 8, -2, 4, 4
ArrowOff8X:
SwordOff8X:
    .byte 8, -6, 4, 4
ArrowOff4Y:
SwordOff4Y:
    .byte 3, 3, -3, 7
ArrowOff8Y:
SwordOff8Y:
    .byte 3, 3, -7, 7

PlayerItem: SUBROUTINE
    lda plState2
    and #3
    tax
    lda PlItemH,x
    pha
    lda PlItemL,x
    pha
    rts

PlayerSword: SUBROUTINE
; If Item Button, use item
    bit plState
    bvc .skipSlashSword
    lda #ItemTimerSword
    sta plItemTimer
; Sfx
    lda #SFX_STAB
    sta SfxFlags
.skipSlashSword
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
    lda #4 ; Draw Sword 8
.drawSword4
    clc
    adc plDir
    tay
    lda SwordWidth4,y
    sta NUSIZ0_T
    lda SwordHeight4,y
    sta wM0H
    lda SwordOff4X,y
    clc
    adc plX
    sta m0X
    lda SwordOff4Y,y
    clc
    adc plY
    sta m0Y
.endSword
    rts

PlayerInput: SUBROUTINE
    bit INPT1
    bmi .skipTest
    inc itemKeys
    inc itemBombs
    inc itemRupees
.skipTest
    ; test if player locked
    lda #PS_LOCK_ALL
    bit plState
    beq .InputContinue
    rts
.InputContinue
    ; Test and update fire button state and related flags
    lda plState
    cmp #INPT_FIRE_PREV ; Test if fire pressed last frame, store in carry
    and #~[INPT_FIRE_PREV + PS_USE_ITEM] ; mask out button held and use current item event
    ora #$80 ; INPT_FIRE_PREV
    bit INPT4
    bmi .FireNotHit ; Button not pressed
    eor #$80 ; invert flag
    bcc .FireNotHit ; Button held down
    ldx plItemTimer
    bne .FireNotHit ; Item in use
    ora #PS_USE_ITEM
.FireNotHit
    sta plState

    ; update player item timer
    lda plItemTimer
    cmp #1
    adc #0
    sta plItemTimer
    
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
    LOG_SIZE "Input", PlayerInput

RsNone:
RsFairyFountain:
    rts

RsMaze: SUBROUTINE
    ldy roomEX
    lda RsMaze_Type,y
    tax
    cmp worldSR
    beq .skipInit
    sta worldSR ; room
    sty worldSY ; check state
.skipInit
    bit roomFlags ; check RF_LOAD_EV
    bpl .rts
    lda roomId
    cmp RsMaze_Exit,y 
    bne .checkPattern
; exit maze without finding hidden area
    sta worldSR
.rts
    rts
.checkPattern
    inc worldSY
    inc worldSY
    ldy worldSY
    lda RsMaze_Pattern-2,y
    cmp roomId
    bne .failStep
    cpy #8
    bmi .roomLoop
; maze complete
    dec worldSR ; force reset
; play some fanfare?
    lda #SFX_SURF
    sta SfxFlags
    rts
    
.failStep
    sta worldSR
.roomLoop
    stx roomId
    rts

RsMaze_Type: 
    .byte ROOM_MAZE_1, ROOM_MAZE_2
RsMaze_Exit
    .byte <(ROOM_MAZE_1 - #$1), <(ROOM_MAZE_2 + #$1)
RsMaze_Pattern:
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 - #$10)
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 - #$1)
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 + #$10)
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 - #$1)
    
RsLeftCaveEnt: SUBROUTINE
    ldx #$14
    cpx plX
    bne .rts
    ldy #$3C
    cpy plY
    bne .rts
    ldy #$38
    jmp EnterCave
.rts
    rts
    
RsRightCaveEnt: SUBROUTINE
    ldx #$6C
    cpx plX
    bne .rts
    ldy #$3C
    cpy plY
    bne .rts
    ldy #$38
    jmp EnterCave
.rts
    rts

; X, Y is return world X/Y
EnterCave:
    lda roomId
    sta worldSR
    stx worldSX
    sty worldSY

    ldx #$40
    ldy #$10
    stx plX
    sty plY

    lda roomFlags
    ora #RF_LOAD_EV
    sta roomFlags
    lda roomId
    ora #$80
    sta roomId
    rts

RsCave: SUBROUTINE
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    and #RF_LOADED_EV
    beq .skipInit
    lda #EN_SHOPKEEPER
    sta enType
.skipInit
    lda plY
    cmp #$08
    bne .rts
    lda #MS_PLAY_THEME_L
    jmp ReturnWorld

.rts
    rts
    
RsRaftSpot: SUBROUTINE
    lda plState
    and #$20
    bne .fixPos
; If item not obtained
    lda #ITEMF_RAFT
    and ITEMV_RAFT
    beq .rts
; If not touching water surface
    bit CXP0FB
    bpl .rts
    ldy plY
    cpy #$40
    bne .rts
    ldx plX
    cpx #$40
    bne .rts
    iny
    sty plY
    lda #PL_DIR_U
    sta plDir
    lda plState
    ora #$22
    sta plState
    lda #SFX_SURF
    sta SfxFlags
.fixPos
    lda #$40
    sta plX
.rts
RsNeedTriforce_rts
    rts
    
RsNeedTriforce: SUBROUTINE
    ldy #7
    cpy itemTri
    bmi RsNeedTriforce_rts
    
    lda #RF_NO_ENCLEAR
    ora roomFlags
    sta roomFlags
    and #RF_LOAD_EV
    bne .skipSetPos
    lda #$30
    cmp plY
    bpl .skipSetPos
    sta plY
.skipSetPos
    lda #MESG_NEED_TRIFORCE
    sta roomEX

RsOldMan: SUBROUTINE
    lda #EN_OLD_MAN
    sta enType
RsText: SUBROUTINE
    lda roomEX
EnableText: SUBROUTINE ; A = messageId
    sta mesgId
    lda #1
    sta KernelId
    rts

RsShoreItem: SUBROUTINE
    lda #RF_PF_AXIS
    ora roomFlags
    sta roomFlags
    lda #44
    cmp plX
    bmi .skipWallback
    sta plX
.skipWallback
    ; check if item should appear
    lda enType
    cmp #EN_CLEAR_DROP
    bne .rts
    ldx roomId
    lda rRoomFlag,x
    bmi .rts ;.NoLoad

    lda #$6C
    sta cdAX
    lda #$2C
    sta cdAY
    lda #EN_ITEM
    sta cdAType
.rts
    rts
    
RsItem: SUBROUTINE
    lda enType
    cmp #EN_CLEAR_DROP
    bne .rts
    ldx roomId
    lda rRoomFlag,x
    bmi .NoLoad
    
    lda #$40
    sta cdAX
    lda #$2C
    sta cdAY
    lda #EN_ITEM
    sta cdAType
.NoLoad
    lda #RS_NONE
    sta roomRS
.rts
    rts

RsGameOver: SUBROUTINE
    lda enInputDelay ; replaced if init taken
    ldx plHealth
    bne .skipInit
    dec plHealth
    stx wBgColor
    stx wFgColor
    stx enType
    stx roomFlags
    stx mesgId
    inx
    stx KernelId
    inx
    stx plState
    
    ldx #RS_GAME_OVER
    stx roomRS
    ldx #$80
    stx plY
    
    ldx #MS_PLAY_OVER
    stx SeqFlags
    lda #-$20 ; input delay timer
.skipInit
    cmp #1
    adc #0
    sta enInputDelay
    bne .rts
    bit INPT4
    bmi .rts
    jsr RESPAWN
.rts
    rts

RsWorldMidEnt:  
RsDungMidEnt: SUBROUTINE
    lda plX
    cmp #$40
    bne .rts
    lda plY
    cmp #$28
    bne .rts
    lda #$40
    sta worldSX
    lda #$20
    sta worldSY
    lda roomId
    sta worldSR
    
    ldy roomEX
    sty worldId
    jmp SPAWN_AT_DEFAULT
.rts
    rts
    
RsDungExit: SUBROUTINE
    bit roomFlags
    bmi .rts
    lda plY
    cmp #BoardYD
    bne .rts
    lda #MS_PLAY_THEME_L
    jmp ReturnWorld
.rts
    rts

; A = SeqFlags
ReturnWorld: SUBROUTINE
    sta SeqFlags
    lda worldSX
    sta plX
    lda worldSY
    sta plY
    lda worldSR
    sta roomId
    lda #0
    sta worldId
    lda roomFlags
    ora #RF_LOAD_EV
    sta roomFlags
    rts
    
RsDiamondBlockStairs: SUBROUTINE
    lda #RF_NO_ENCLEAR
    ora roomFlags
    sta roomFlags
    lda #0
    sta wPF2Room + 13
    sta wPF2Room + 14
    lda #$41
    sta blX
    lda #$3C
    sta blY
    lda #BL_PUSH_BLOCK
    sta blType
    lda #RS_STAIRS
    sta roomRS
    rts

RsCentralBlock: SUBROUTINE
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    ldx #$40+1
    stx blX
    ldx #$2C
    stx blY
    lda #BL_PUSH_BLOCK
    sta blType
    ldy #1
.loop
    lda rPF2Room+9,y
    and #$7F
    sta wPF2Room+9,y
    dey
    bpl .loop
    lda #RS_NONE
    sta roomRS
    rts
    
RsStairs:
    lda roomFlags
    and #RF_CLEAR
    beq .rts
    lda #$40
    sta cdAX
    lda #$2C
    sta cdAY
    lda #EN_STAIRS
    sta cdAType
.rts
    rts
    
RoomScriptDel:
    ldx roomRS
    lda RoomScriptH,x
    pha
    lda RoomScriptL,x
    pha
    rts