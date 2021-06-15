;==============================================================================
; mzxrules 2021
;==============================================================================
LoadRoom_B6: SUBROUTINE
; set OR mask for the room top/bottom
    lda worldId
    beq .WorldRoomOrTop
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
    
; Up/Down check    
    lda plX
    sec
    sbc #BoardKeydoorUDA
    ; continue if positive
    bmi .LRCheck
    sbc #$8+1
    bpl .LRCheck
    
    ldx #0
    lda plY
    cmp #BoardKeydoorUY
    beq .UnlockUp
    cmp #BoardKeydoorDY
    beq .UnlockDown
    
.LRCheck
    lda plY
    sec
    sbc #BoardKeydoorLRA
    bmi .rts1
    sbc #$8+1
    bpl .rts1
    
    ldx #2
    lda plX
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

PlayerItem_B6: SUBROUTINE
; Sword
    bit plState
    bvc .skipSetItemTimer
; If Item Button, stab sword
    lda #ItemTimerSword
    sta plItemTimer
; Sfx
    lda #SFX_STAB
    sta SfxFlags
.skipSetItemTimer
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
    lda #4
.drawSword4
    clc
    adc plDir
    tay
    lda SwordWidth4,y
    sta NUSIZ0_T
    lda SwordHeight4,y
    sta m0H
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
    ; test if player locked
    lda #02
    bit plState
    beq .InputContinue
    rts
.InputContinue
    lda plState
    and #$BF
    sta plState
    bpl .FireNotHit
    lda INPT4
    bmi .FireNotHit
    lda plItemTimer
    bne .FireNotHit
    lda plState
    ora #$40
    sta plState
.FireNotHit
    lda plState
    and #$7F
    bit INPT4
    bpl .skipLastFire
    ora #$80
.skipLastFire
    sta plState

    lda plItemTimer
    cmp #1
    adc #0
    sta plItemTimer

    bmi .skipItemInput

.skipItemInput
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