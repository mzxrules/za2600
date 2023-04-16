;==============================================================================
; mzxrules 2022
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

PlayerArrow: SUBROUTINE
    bit plState
    bvc .skipSpawnArrow ;PS_USE_ITEM
    lda itemRupees
    beq .skipSpawnArrow
    sed
    sec
    sbc #1
    cld
    sta itemRupees
    lda #-32
    sta plItemTimer
    ldy plDir
    sty plItemDir
    ; Spawn Arrow
    lda #SFX_ARROW
    sta SfxFlags
    lda ArrowWidth8,y
    sta wNUSIZ0_T
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
    beq .endArrow
    lda m0X
    cmp #BoardXL
    bmi .offScreen
    cmp #BoardXR
    bpl .offScreen
    lda m0Y
    cmp #BoardYD
    bmi .offScreen
    cmp #BoardYU
    bpl .offScreen
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
.endArrow
    lda itemRupees
    bne .offScreen
    lda plState2
    and #~PS_ACTIVE_ITEM ; Equip Sword
    sta plState2
.offScreen
    lda #$80
    sta m0Y
    rts

ArrowDeltaX:
    .byte 2, -2
ArrowDeltaY:
    .byte 0, 0, -2, 2

PlayerFire: SUBROUTINE
    bit plState
    bvc .skipSpawnFire ;PS_USE_ITEM
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
    sta wNUSIZ0_T
    lda #0
    sta wM0H
.skipSpawnFire
    ldy plItemTimer
    bne .drawFire
    lda #$80
    sta m0Y
    rts
.drawFire
    tya
    and #3
    sta wM0H
.rts
    rts


PlayerBomb: SUBROUTINE
    bit plState
    bvc .skipDropBomb ;PS_USE_ITEM
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
    sta wNUSIZ0_T
    lda #3
    sta wM0H
.skipDropBomb
    ldy plItemTimer
    bne .drawBomb
; Handle end of Bomb behavior
    lda itemBombs
    bne .skipEquipSword
    lda plState2
    and #~PS_ACTIVE_ITEM
    sta plState2
.skipEquipSword
    lda #$80
    sta m0Y
    rts
.drawBomb
    cpy #ITEM_ANIM_BOMB_DETONATE
    bmi .rts
    bne .skipDetonateEffect
    lda #7
    sta wM0H
    lda #$30
    sta wNUSIZ0_T
    lda #SFX_BOMB
    sta SfxFlags

.skipDetonateEffect
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
    ; update player item timer
    lda plItemTimer
    cmp #1
    adc #0
    sta plItemTimer

    lda plState2
    and #PS_ACTIVE_ITEM
    tax
    lda PlItemH,x
    pha
    lda PlItemL,x
    pha
    rts

PlayerWand:
PlayerMeat:
PlayerPotion:
PlayerSword: SUBROUTINE
; If Item Button, use item
    lda ITEMV_SWORD1
    and #[ITEMF_SWORD1 | ITEMF_SWORD2 | ITEMF_SWORD3]
    beq .skipSlashSword
    bit plState
    bvc .skipSlashSword ;PS_USE_ITEM
    lda #<-9
    sta plItemTimer
    lda plDir
    sta plItemDir
; Sfx
    lda #SFX_STAB
    sta SfxFlags
.skipSlashSword
    ldy plItemTimer
    bne .drawSword
    lda #$80
    sta m0Y
    rts

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
    sta wNUSIZ0_T
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

PlayerFlute: SUBROUTINE
    lda plItemTimer
    bne .drawTornado
    bit plItemDir
    bvs .ContinueTornado ;from transition
    bmi .SpawnPlayer
    bit plState
    bvs .SpawnTornado ;PS_USE_ITEM
.noDraw
    lda #$80
    sta m0Y
    rts
.SpawnPlayer
    lda plState
    and #~PS_LOCK_ALL
    sta plState
    lda plItemDir
    and #~$C0
    sta plItemDir
    lda #$40
    sta plX
    lda #$10
    sta plY
    bpl .noDraw ; jmp

.ContinueTornado
    lda plState
    ora #PS_LOCK_ALL
    sta plState
    lda plItemDir
    and #~$40
    sta plItemDir
    lda #$10
    sta m0Y
    lda #0
    sta m0X
    lda #-40
    sta plItemTimer
    bmi .drawTornado ; jmp

.SpawnTornado
    lda plY
    sta m0Y
    lda #0
    sta m0X
    lda #-84
    sta plItemTimer

.drawTornado
    cmp #-1
    beq .lastFrame
    and #3
    tax
    bne .contDraw
    inc plItemTimer
    inx
.contDraw
    lda m0Y
    clc
    adc .tornadoAnimDeltaY-1,x
    sta m0Y
    lda .tornadoAnimWidth-1,x
    sta wNUSIZ0_T
    lda .tornadoAnimHeight-1,x
    sta wM0H
    lda m0X
    clc
    adc .tornadoAnimDeltaX-1,x
    sta m0X
; Check player collision
; Have fun analyzing this one
    ; x
    sbc plX
    adc #7
    bmi .rts
    cmp #14
    bpl .rts
    ; y
    lda m0Y
    adc .tornadoHitDeltaY,x
    sbc plY
    adc #2
    bmi .rts
    cmp #9
    bpl .rts
    lda plState
    ora #PS_LOCK_ALL
    sta plState
    lda #$40
    sta plX
    lda #$C0
    sta plY
    ora plItemDir
    sta plItemDir
.rts
    rts
.lastFrame
    bit plItemDir
    bvc .rts
.warp
    lda #$77
    ldx itemTri
    beq .NoDest
    lda plItemDir
    and #7
    tax
.loop

    lda Bit8,x
    and itemTri
    bne .foundDest
    inx
    cpx #8
    bne .loop
    ldx #0
    beq .loop

.foundDest
    lda .tornadoDest,x
.NoDest
    sta roomId
    inx
    txa
    and #7
    sta Temp0
    lda plItemDir
    and #$F0
    ora Temp0
    sta plItemDir
    lda #RF_EV_LOAD
    ora roomFlags
    sta roomFlags
    rts

.tornadoDest:
    .byte $37, $3C, $74, $45, $0B, $22, $42, $5C

.tornadoAnimDeltaX:
    .byte 2 + 2, 2 - 2, 2

.tornadoAnimDeltaY:
    .byte 2, 2, -4

.tornadoHitDeltaY:
    .byte -2, -4, 0

.tornadoAnimHeight:
    .byte 2, 2, 1

.tornadoAnimWidth:
    .byte $20, $30, $10

PlayerInput: SUBROUTINE
    bit INPT1
    bmi .skipCheckForPause
    lda plItemTimer
    bmi .skipCheckForPause
; Check Flute Warp in
    lda plState2
    and #PS_ACTIVE_ITEM
    cmp #PLAYER_FLUTE
    bne .noWarpIn
    bit plItemDir
    bmi .skipCheckForPause
.noWarpIn
; Check death
    ldx plHealth
    dex
    bmi .skipCheckForPause
    lda #SLOT_PAUSE
    sta BANK_SLOT
    lda #<(PAUSE_ENTRY - 1)
    sta PauseSp
    lda #>(PAUSE_ENTRY - 1)
    sta PauseSp+1
    rts ; jmp PAUSE_ENTRY
.skipCheckForPause
    ; test if player locked
    lda #PS_LOCK_ALL
    bit plState
    beq .InputContinue
    lda plState
    and #~PS_USE_ITEM
    sta plState
    lda plState2
    and #PS_ACTIVE_ITEM
    bne .rts
    sta plItemTimer
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
    and #PS_LOCK_MOVE
    bne .rts

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