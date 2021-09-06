;==============================================================================
; mzxrules 2021
;==============================================================================
RoomUpdate: SUBROUTINE
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
    jsr LoadRoom
    lda #0      ;EN_NONE
    sta enType
    sta blType
    sta blTemp
    sta plItemTimer
    sta KernelId
.skipLoadRoom
    rts

LoadRoom: SUBROUTINE
    ; load world bank
    lda #SLOT_W0
    ldx #SLOT_RW0
    ldy worldId
    beq .worldBankSet
    lda #SLOT_W2
    ldx #SLOT_RW2
    cpy #8
    bpl .worldBankSet
    lda #SLOT_W1
    ldx #SLOT_RW1
.worldBankSet

    sta BANK_SLOT
    stx BANK_SLOT_RAM
    lda roomId
    and #$7F
    sta roomId
    tay
    lda WORLD_RS,y
    sta roomRS
    lda WORLD_EX,y
    sta roomEX
    lda WORLD_EN,y
    sta roomEN
    lda WORLD_WA,y
    sta roomWA
    
    ; set fg/bg color
    lda WORLD_COLOR,y
    and #$0F
    tax
    lda WorldColors,x
    sta wFgColor
    lda WORLD_COLOR,y
    lsr
    lsr
    lsr
    lsr
    tax
    lda WorldColors,x
    sta wBgColor
    
    ; PF1 Right
    lda WORLD_T_PF1R,y
    tax
    and #$F0
    sta Temp4
    txa
    and #$01
    ora #>BANK_PF
    sta Temp5
    txa
    and #$0E
    asl
    asl
    asl
    asl
    sta roomDoors
    
    ; PF1 Left
    lda WORLD_T_PF1L,y
    tax
    and #$F0
    sta Temp0
    txa
    and #$01
    ora #>BANK_PF
    sta Temp1
    txa
    and #$0E
    lsr
    ora roomDoors
    sta roomDoors
    
    ; PF2
    lda WORLD_T_PF2,y
    tax
    and #$F0
    sta Temp2
    txa
    and #$03
    ora #>BANK_PF
    sta Temp3
    txa
    and #$0C
    asl
    ora roomDoors
    sta roomDoors
    
; set OR mask for the room sides    
    lda worldId
    beq .WorldRoomOrSides
    lda #$C0
    .byte $2C
.WorldRoomOrSides
    lda #$00
    sta Temp6
    
    ldy #ROOM_SPR_HEIGHT-1
.roomInitMem
    lda #SLOT_PF_A
    sta BANK_SLOT

.roomInitMemLoop
    lda (Temp0),y ; PF1L
    ora Temp6
    sta wPF1RoomL+2,y
    lda (Temp4),y ; PF1R
    ora Temp6
    sta wPF1RoomR+2,y
    lda (Temp2),y ; PF2
    sta wPF2Room+2,y
    dey
    bpl .roomInitMemLoop

; All room sprite data has been read

; set OR mask for the room top/bottom
    lda worldId
    beq .WorldRoomOrTop
    
; sneak in opportunity to update roomDoors
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
    
UpdateDoors: SUBROUTINE
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
   
KeydoorCheck: SUBROUTINE
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
    
WorldColors:
    .byte COLOR_BLACK, COLOR_DARK_BLUE, $00, COLOR_LIGHT_BLUE2
    .byte $42, $7A, COLOR_PATH, $06
    .byte $02, COLOR_LIGHT_BLUE2, COLOR_GREEN_ROCK, COLOR_LIGHT_WATER
    .byte $00, COLOR_CHOCOLATE, COLOR_GOLDEN, $0E