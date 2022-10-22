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
; ARROW
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
    bmi .drawArrow
.endArrow
    lda itemRupees
    bne .offScreen
    lda plState2
    and #~3
    sta plState2
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
    sta NUSIZ0_T
    lda #3
    sta wM0H
.skipDropBomb
    ldy plItemTimer
    bne .drawBomb
    lda itemBombs
    bne .skipEquipSword
    lda plState2
    and #~3
    sta plState2
.skipEquipSword
    lda #$80
    sta m0Y
    bmi .rts
.drawBomb
    cpy #-11
    bmi .rts
    bne .skipDetonateEffect
    lda #7
    sta wM0H
    lda #$30
    sta NUSIZ0_T
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
    bmi .skipCheckForPause
    lda plItemTimer
    bmi .skipCheckForPause
    lda plHealth
    bmi .skipCheckForPause
    lda #SLOT_PAUSE
    sta BANK_SLOT
    lda #<(PAUSE_ENTRY - 1)
    sta PauseSp
    lda #>(PAUSE_ENTRY - 1)
    sta PauseSp+1
    rts
    ;inc itemKeys
    ;inc itemBombs
    ;inc itemRupees
.skipCheckForPause
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
    tax

    ; update player item timer
    lda plItemTimer
    cmp #1
    adc #0
    sta plItemTimer

    txa
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