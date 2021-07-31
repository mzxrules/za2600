;==============================================================================
; mzxrules 2021
;==============================================================================
LoadRoom_B6: SUBROUTINE
; set OR mask for the room top/bottom
    lda worldId
    beq .WorldRoomOrTop
    
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
    
    lda #$FF
    .byte $2C
.WorldRoomOrTop
    lda #$00
    
    sta Temp6
    ldy #1
.roomUpDownBorder
    lda rPF1RoomL+2
    ora Temp6
    sta wPF1RoomL,y
    
    lda rPF2Room+2
    ora Temp6
    sta wPF2Room,y
    
    lda rPF1RoomR+2
    ora Temp6
    sta wPF1RoomR,y
    
    lda rPF1RoomL+ROOM_PX_HEIGHT-3
    ora Temp6
    sta wPF1RoomL+ROOM_PX_HEIGHT-2,y
    
    lda rPF1RoomR+ROOM_PX_HEIGHT-3
    ora Temp6
    sta wPF1RoomR+ROOM_PX_HEIGHT-2,y
    
    lda rPF2Room+ROOM_PX_HEIGHT-3
    ora Temp6
    sta wPF2Room+ROOM_PX_HEIGHT-2,y
    dey
    bpl .roomUpDownBorder
    lda worldId
    beq UpdateWorldDoors
    rts
    
UpdateWorldDoors: SUBROUTINE
    lda roomDoors
    and #3
    tax
    ldy #1
.Up
    lda WorldDoorPF2,x
    ora rPF2Room+ROOM_PX_HEIGHT-2,y
    sta wPF2Room+ROOM_PX_HEIGHT-2,y
    lda WorldDoorPF1Up,x
    ora rPF1RoomL+ROOM_PX_HEIGHT-2,y
    sta wPF1RoomL+ROOM_PX_HEIGHT-2,y
    lda WorldDoorPF1Up,x
    ora rPF1RoomR+ROOM_PX_HEIGHT-2,y
    sta wPF1RoomR+ROOM_PX_HEIGHT-2,y
    dey
    bpl .Up
    
    lda roomDoors
    lsr
    lsr
    pha
    and #3
    tax
    ldy #1
.Down
    lda WorldDoorPF2,x
    ora rPF2Room,y
    sta wPF2Room,y
    lda WorldDoorPF1Up,x
    ora rPF1RoomL,y
    sta wPF1RoomL,y
    lda WorldDoorPF1Up,x
    ora rPF1RoomR,y
    sta wPF1RoomR,y
    dey
    bpl .Down

.LeftRight
    pla
    lsr
    lsr
    tay
    and #3
    tax
    lda WorldDoorPF1A,x
    sta Temp1
    lda WorldDoorPF1B,x
    sta Temp3
    tya
    lsr
    lsr
    and #3
    tax
    lda WorldDoorPF1A,x
    sta Temp0
    lda WorldDoorPF1B,x
    sta Temp2
    
    ldy #5
.LeftRightWorldDoor
    lda rPF1RoomL+2,y
    ora Temp0
    sta wPF1RoomL+2,y
    
    lda rPF1RoomL+12,y
    ora Temp0
    sta wPF1RoomL+12,y
    
    lda rPF1RoomR+2,y
    ora Temp1
    sta wPF1RoomR+2,y
    
    lda rPF1RoomR+12,y
    ora Temp1
    sta wPF1RoomR+12,y
    dey
    bpl .LeftRightWorldDoor
    
    ldy #3
.LeftRightWorldDoor2
    lda rPF1RoomL+8,y
    ora Temp2
    sta wPF1RoomL+8,y
    
    lda rPF1RoomR+8,y
    ora Temp3
    sta wPF1RoomR+8,y
    dey
    bpl .LeftRightWorldDoor2
rts_UpdateDoors:
    rts
    
UpdateDoors_B6: SUBROUTINE
    lda worldId
    beq rts_UpdateDoors
    ldy #$3F
    ldx #$FF
    lda roomDoors

    lsr
    sty wPF2Room+ROOM_PX_HEIGHT-2
    bcc .skipDown0
    stx wPF2Room+ROOM_PX_HEIGHT-2

.skipDown0
    lsr
    sty wPF2Room+ROOM_PX_HEIGHT-1
    bcc .skipDown1
    stx wPF2Room+ROOM_PX_HEIGHT-1

.skipDown1
    lsr
    sty wPF2Room+1
    bcc .skipUp0
    stx wPF2Room+1

.skipUp0
    lsr
    sty wPF2Room+0
    bcc .skipUp1
    stx wPF2Room+0

.skipUp1
    lda roomDoors
    and #$C0
    sta Temp0
    lda roomDoors
    asl
    asl
    and #$C0
    sta Temp1

    ldy #3
.lrLoop
    lda rPF1RoomL+(ROOM_PX_HEIGHT/2)-2,y
    and #$3F
    ora Temp0
    sta wPF1RoomL+(ROOM_PX_HEIGHT/2)-2,y
    lda rPF1RoomR+(ROOM_PX_HEIGHT/2)-2,y
    and #$3F
    ora Temp1
    sta wPF1RoomR+(ROOM_PX_HEIGHT/2)-2,y
    dey
    bpl .lrLoop
    rts
   
KeydoorCheck_B6: SUBROUTINE
    lda worldId
    beq .rts1
    lda itemKeys
    beq .rts1
        
    lda plX
    ldy plY
    
; Up/Down check
    cmp #BoardKeydoorUDA
    ; continue if positive
    bmi .LRCheck
    cmp #BoardKeydoorUDA + $8+1
    bpl .LRCheck
    
    ldx #0
    cpy #BoardKeydoorUY
    beq .UnlockUp
    cpy #BoardKeydoorDY
    beq .UnlockDown
    
.LRCheck
    cpy #BoardKeydoorLRA
    bmi .rts1
    cpy #BoardKeydoorLRA + $8+1
    bpl .rts1
    
    ldx #2
    cmp #BoardKeydoorRX
    beq .UnlockRight
    cmp #BoardKeydoorLX
    beq .UnlockLeft
.rts1
    rts
.UnlockUp
.UnlockLeft
    inx
.UnlockDown
.UnlockRight
    lda roomDoors
    ; Verify that door is a "keydoor". This is done by toggling the keydoor bit
    ; And then masking out just the one door, thus if a is not 0, it's not a keydoor
    eor #%01010101
    and KeydoorMask,x
    bne .rts1
    lda KeydoorMask,x
    eor #$FF
    and roomDoors
    sta roomDoors
    dec itemKeys
    lda #SFX_STAB
    sta SfxFlags
    ; x = door dir, S/N/E/W
    
    ; load world bank (RAM)
    ldy worldBank
    lda BANK_RAM + 1,y
    
    ldy roomId
    lda KeydoorFlagA,x
    ora rRoomFlag,y
    sta wRoomFlag,y
    tya
    clc
    adc KeydoorRoomOff,x
    tay
    lda KeydoorFlagB,x
    ora rRoomFlag,y
    sta wRoomFlag,y
    lda BANK_RAM + 0
    rts

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
    
PlayerArrow_B6: SUBROUTINE
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

PlayerFire_B6: SUBROUTINE
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
    
    
PlayerBomb_B6: SUBROUTINE
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

PlayerItem_B6: SUBROUTINE
PlayerSword_B6: SUBROUTINE
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
    
    align 4
KeydoorMask:
    ; S/N/E/W
    .byte $0C, $03, $30, $C0
KeydoorFlagA:
    .byte $04, $01, $10, $40
KeydoorFlagB:
    .byte $01, $04, $40, $10
KeydoorRoomOff:
    .byte $10, $F0, $01, $FF
    
    align 4
WorldDoorPF1Up:
    .byte $C0, $C0, $FF, $FF
    
WorldDoorPF1A:
    .byte $00, $00, $C0, $C0
    
WorldDoorPF1B:
    .byte $00, $C0, $00, $C0
    
WorldDoorPF2:
    .byte $00, $FF, $3F, $FF

ProcessInput_B6: SUBROUTINE
    bit INPT1
    bmi .skipTest
    inc itemKeys
    inc itemBombs
.skipTest
    ; test if player locked
    lda #02
    bit plState
    beq .InputContinue
    rts
.InputContinue
    ; Test and update fire button state and related flags
    lda plState
    cmp #$80 ; Test if fire pressed last frame, store in carry
    and #$3F ; ~$80 + ~$40, button held and use current item event
    ora #$80
    bit INPT4
    bmi .FireNotHit ; Button not pressed
    eor #$80 ; invert flag
    bcc .FireNotHit ; Button held down
    ldx plItemTimer
    bne .FireNotHit ; Item in use
    ora #$40
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
    LOG_SIZE "Input", ProcessInput_B6