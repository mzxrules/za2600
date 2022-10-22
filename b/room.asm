;==============================================================================
; mzxrules 2021
;==============================================================================
RoomUpdate: SUBROUTINE
    lda roomFlags
    and #~RF_EV_LOADED
    sta roomFlags
    bpl .skipLoadRoom
    ora #RF_EV_LOADED
    and #~[RF_EV_LOAD + RF_NO_ENCLEAR + RF_EV_CLEAR + RF_PF_IGNORE + RF_PF_AXIS + RF_PF_DARK]
    sta roomFlags
    lda #-$18
    sta roomTimer
    lda #[PS_GLIDE | PS_LOCK_ALL]
    sta plState
    jsr LoadRoom
    lda #0      ;EN_NONE
    sta enType
    sta enState
    sta blType
    sta roomPush
    sta plItemTimer
    sta KernelId
.skipLoadRoom
    rts

LoadCaveRoom: SUBROUTINE
    ; Don't overwrite room vars
    lda #COLOR_CHOCOLATE
    sta wFgColor
    lda #COLOR_BLACK
    sta wBgColor
    lda #RS_CAVE
    sta roomRS
    lda #$F3
    sta roomDoors
    lda #MS_PLAY_NONE
    sta SeqFlags

    lda #$FF
    ldy #1
.loadRoomSprite1
    sta wPF2Room + ROOM_PX_HEIGHT-2,y
    sta wPF1RoomL + ROOM_PX_HEIGHT-2,y
    sta wPF1RoomR + ROOM_PX_HEIGHT-2,y
    dey
    bpl .loadRoomSprite1

    lda #0
    ldy #ROOM_PX_HEIGHT-2 -1
.loadRoomSprite2
    sta wPF2Room,y
    dey
    bpl .loadRoomSprite2
    
    lda #$C0
    ldy #ROOM_PX_HEIGHT-2 -1
.loadRoomSprite3
    sta wPF1RoomL,y
    sta wPF1RoomR,y
    dey
    bpl .loadRoomSprite3
    rts

LoadRoom: SUBROUTINE
    ; load world bank
    lda #SLOT_W0
    ldx #SLOT_RW0
    ldy worldId
    beq .worldBankSet
    lda #SLOT_W2
    ldx #SLOT_RW2
    cpy #7
    bpl .worldBankSet
    lda #SLOT_W1
    ldx #SLOT_RW1

.worldBankSet
    sta BANK_SLOT
    stx BANK_SLOT_RAM
    ldy roomId
    bpl .skipCaveRoom
    jmp LoadCaveRoom
.skipCaveRoom
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
    sta Temp4+0
    txa
    and #$01
    ora #>BANK_PF
    sta Temp4+1
    txa
    and #%1110 ; Unpack door flags
    asl
    asl
    asl
    asl
    sta roomDoors
    
    ; PF1 Left
    lda WORLD_T_PF1L,y
    tax
    and #$F0
    sta Temp0+0
    txa
    and #$01
    ora #>BANK_PF
    sta Temp0+1
    txa
    and #%1110 ; Unpack door flags
    lsr
    ora roomDoors
    sta roomDoors
    
    ; PF2
    lda WORLD_T_PF2,y
    tax
; Set RF_PF_IGNORE if triforce floor
    and #$F3
    cmp #$32
    bne .skipPFIgnore
    lda roomFlags
    ora #RF_PF_IGNORE
    sta roomFlags
    txa
.skipPFIgnore
    and #$F0
    sta Temp2+0
    txa
    and #$03
    ora #>BANK_PF
    sta Temp2+1
    txa
    and #%1100 ; Unpack door flags
    asl
    ora roomDoors
    sta roomDoors
    
; Load playfield data
    ldy #ROOM_SPR_HEIGHT-1
    lda #SLOT_PF_A
    sta BANK_SLOT

    lda worldId
    bne .dungRoomInitMemLoop

; Load World Room Sprites
.worldRoomInitMem
    lda (Temp0),y ; PF1L
    sta wPF1RoomL+2,y
    lda (Temp4),y ; PF1R
    sta wPF1RoomR+2,y
    lda (Temp2),y ; PF2
    sta wPF2Room+2,y
    dey
    bpl .worldRoomInitMem

; Set room top/bottom exit walls

    lda rPF1RoomL+2
    sta wPF1RoomL+0
    sta wPF1RoomL+1
    
    lda rPF2Room+2
    sta wPF2Room+0
    sta wPF2Room+1
    
    lda rPF1RoomR+2
    sta wPF1RoomR+0
    sta wPF1RoomR+1

    lda rPF1RoomL+ROOM_PX_HEIGHT-3
    sta wPF1RoomL+ROOM_PX_HEIGHT-2
    sta wPF1RoomL+ROOM_PX_HEIGHT-1

    lda rPF1RoomR+ROOM_PX_HEIGHT-3
    sta wPF1RoomR+ROOM_PX_HEIGHT-2
    sta wPF1RoomR+ROOM_PX_HEIGHT-1

    lda rPF2Room+ROOM_PX_HEIGHT-3
    sta wPF2Room+ROOM_PX_HEIGHT-2
    sta wPF2Room+ROOM_PX_HEIGHT-1

    jmp UpdateWorldDoors

; Load Dung Room Sprites
.dungRoomInitMemLoop
    lda (Temp0),y ; PF1L
    ora #$C0
    sta wPF1RoomL+2,y
    lda (Temp4),y ; PF1R
    ora #$C0
    sta wPF1RoomR+2,y
    lda (Temp2),y ; PF2
    sta wPF2Room+2,y
    dey
    bpl .dungRoomInitMemLoop

; All room sprite data has been read
    
; Update Dungeon roomDoors
    ldy roomId
    lda rRoomFlag,y
    and #%01010101
    sta Temp0
    asl
    adc Temp0
    eor #$FF
    and roomDoors
    sta roomDoors
    
; set room top/bottom exit walls
    
    ldy #1
.dungRoomUpDownBorder
    lda rPF1RoomL+2
    ora #$FF
    sta wPF1RoomL,y
    
    lda rPF2Room+2
    ora #$FF
    sta wPF2Room,y
    
    lda rPF1RoomR+2
    ora #$FF
    sta wPF1RoomR,y
    
    lda rPF1RoomL+ROOM_PX_HEIGHT-3
    ora #$FF
    sta wPF1RoomL+ROOM_PX_HEIGHT-2,y
    
    lda rPF1RoomR+ROOM_PX_HEIGHT-3
    ora #$FF
    sta wPF1RoomR+ROOM_PX_HEIGHT-2,y
    
    lda rPF2Room+ROOM_PX_HEIGHT-3
    ora #$FF
    sta wPF2Room+ROOM_PX_HEIGHT-2,y
    dey
    bpl .dungRoomUpDownBorder
; RF_PF_AXIS test
    lda rFgColor
    cmp #COLOR_RED_ROCK
    beq .SetPFAxis
    cmp #COLOR_LIGHT_WATER
    bne .rts
.SetPFAxis
    lda roomFlags
    ora #RF_PF_AXIS
    sta roomFlags
.rts
    rts
    
UpdateWorldDoors: SUBROUTINE
    lda roomDoors
    asl
    and #6
    tax
    ldy #1
    lda roomWA
    and #$01
    beq .Up
    inx
.Up
    lda WorldDoorPF2Up,x
    ora rPF2Room+ROOM_PX_HEIGHT-2,y
    sta wPF2Room+ROOM_PX_HEIGHT-2,y
    lda WorldDoorPF1UpL,x
    ora rPF1RoomL+ROOM_PX_HEIGHT-2,y
    sta wPF1RoomL+ROOM_PX_HEIGHT-2,y
    lda WorldDoorPF1UpR,x
    ora rPF1RoomR+ROOM_PX_HEIGHT-2,y
    sta wPF1RoomR+ROOM_PX_HEIGHT-2,y
    dey
    bpl .Up
    
    lda roomDoors
    lsr
    pha
    and #6
    tax
    ldy #1
    lda roomWA
    and #$04
    beq .Down
    inx
.Down
    lda WorldDoorPF2Up,x
    ora rPF2Room,y
    sta wPF2Room,y
    lda WorldDoorPF1UpL,x
    ora rPF1RoomL,y
    sta wPF1RoomL,y
    lda WorldDoorPF1UpR,x
    ora rPF1RoomR,y
    sta wPF1RoomR,y
    dey
    bpl .Down

.LeftRight
    pla
    lsr
    lsr
    tay
    and #6
    tax
    lda roomWA
    and #$10
    beq .Right
    inx
.Right
    lda WorldDoorPF1A,x
    sta Temp1
    lda WorldDoorPF1B,x
    sta Temp3
    lda WorldDoorPF1C,X
    sta Temp5
    tya
    lsr
    lsr
    and #6
    tax
    lda roomWA
    and #$40
    beq .Left
    inx
.Left
    lda WorldDoorPF1A,x
    sta Temp0
    lda WorldDoorPF1B,x
    sta Temp2
    lda WorldDoorPF1C,x
    sta Temp4
    
    ldy #5
.LeftRightWorldDoor
    lda rPF1RoomL+2,y
    ora Temp4
    sta wPF1RoomL+2,y
    
    lda rPF1RoomL+12,y
    ora Temp0
    sta wPF1RoomL+12,y
    
    lda rPF1RoomR+2,y
    ora Temp5
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
    rts
    
;==============================================================================
; UpdateDoors
;----------
; Updates dungeon door state
;==============================================================================
UpdateDoors: SUBROUTINE
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

;==============================================================================
; DoorCheck
;----------
; Tests and applies keydoor, fake wall, bombwall behaviors on dungeon roomDoors
; If keydoor, unlocks it if they have a key
; If bombwall, unlocks if a bomb has detonated nearby
; If fakewall, push player through 
;==============================================================================
DoorCheck: SUBROUTINE
    lda plX
    ldy plY
    
; Up/Down check
    cmp #BoardDungDoorNSX
    ; continue if positive
    bmi .LRCheck
    cmp #BoardDungDoorNSX + $8+1
    bpl .LRCheck
    
    ldx #0
    cpy #BoardDungDoorNY
    beq .UnlockUp
    cpy #BoardDungDoorSY
    beq .UnlockDown
    
.LRCheck
    cpy #BoardDungDoorEWY
    bmi .rtsBreakwall
    cpy #BoardDungDoorEWY + $8+1
    bpl .rtsBreakwall
    
    ldx #2
    cmp #BoardDungDoorEX
    beq .UnlockRight
    cmp #BoardDungDoorWX
    beq .UnlockLeft
    bne .rtsBreakwall
    rts
.UnlockUp
.UnlockLeft
    inx
.UnlockDown
.UnlockRight
; DoorCheck passed, x stores door
; Fake Wall Check
    lda roomWA
    eor #$FF
    and DungDoorMask,x
    bne .keydoorCheck
    ; TODO: push check
    lda plState
    and #PS_GLIDE
    bne .rts
    lda #[PS_GLIDE | PS_LOCK_ALL]
    ora plState
    sta plState
    lda #SFX_SOLVE
    sta SfxFlags
    rts

.keydoorCheck
    lda itemKeys
    beq .rtsBreakwall

    lda roomDoors
    ; Verify that door is a "keydoor". This is done by toggling the keydoor bit
    ; And then masking out just the one door, thus if a is not 0, it's not a keydoor
    eor #%01010101
    and DungDoorMask,x
    bne .rtsBreakwall
    ; Spend a key to unlock a keydoor
    
    dec itemKeys
    lda #SFX_STAB
    sta SfxFlags

DoorOpen:
    ; x = door dir, S/N/E/W
    lda DungDoorMask,x
    eor #$FF
    and roomDoors
    sta roomDoors
    
    ldy roomId
    lda DungDoorFlagA,x
    ora rRoomFlag,y
    sta wRoomFlag,y
    tya
    clc
    adc DungDoorRoomOff,x
    tay
    lda DungDoorFlagB,x
    ora rRoomFlag,y
    sta wRoomFlag,y
.rts
    rts

.rtsBreakwall
    lda plState2
    and #3
    cmp #PLAYER_BOMB
    bne .rts
    ldy plItemTimer
    cpy #-6
    bne .rts
    
CheckBreakwall: SUBROUTINE
    lda m0X
    ldy m0Y
    
; Up/Down check
    cmp #BoardBreakwallNSX1
    bmi .LRCheck
    cmp #BoardBreakwallNSX2 + 1
    bpl .LRCheck
    
    ldx #0
    cpy #BoardBreakwallNY
    bpl .UnlockUp
    cpy #BoardBreakwallSY + 1
    bmi .UnlockDown
    
.LRCheck
    cpy #BoardBreakwallEWY1
    bmi .rts
    cpy #BoardBreakwallEWY2 + 1
    bpl .rts
    
    ldx #2
    cmp #BoardBreakwallEX
    bpl .UnlockRight
    cmp #BoardBreakwallWX + 1
    bmi .UnlockLeft
.rts
    rts
.UnlockUp
.UnlockLeft
    inx
.UnlockDown
.UnlockRight
    lda roomWA
    eor #%10101010
    and DungDoorMask,X
    beq DoorOpen
    rts

    align 4
DungDoorMask:
    ; S/N/E/W
    .byte $0C, $03, $30, $C0
DungDoorFlagA:
    .byte $04, $01, $10, $40
DungDoorFlagB:
    .byte $01, $04, $40, $10
DungDoorRoomOff:
    .byte $10, $F0, $01, $FF
    
    align 8
    ; wall types:
    ; none, central long, left-right long, full
    ; right long, left long, left-right short, invalid

WorldDoorPF2Up:
    .byte $00, $FF, $3F, $FF, $FF, $FF, $00, $AB

WorldDoorPF1UpL:
    .byte $C0, $C0, $FF, $FF, $C0, $FF, $FF, $AB

WorldDoorPF1UpR:
    .byte $C0, $C0, $FF, $FF, $FF, $C0, $FF, $AB
    
WorldDoorPF1A:
    ; Top
    .byte $00, $00, $C0, $C0, $00, $C0, $AB, $AB
    
WorldDoorPF1B:
    ; Mid
    .byte $00, $C0, $00, $C0, $C0, $C0, $AB, $AB

WorldDoorPF1C:
    ; Bottom
    .byte $00, $00, $C0, $C0, $C0, $00, $AB, $AB
    
    
WorldColors:
    /* 00 */ .byte COLOR_BLACK
    /* 01 */ .byte COLOR_DARK_GRAY
    /* 02 */ .byte COLOR_GRAY
    /* 03 */ .byte COLOR_DARK_BLUE
    /* 04 */ .byte COLOR_LIGHT_BLUE
    /* 05 */ .byte COLOR_LIGHT_WATER
    /* 06 */ .byte COLOR_DARK_TEAL
    /* 07 */ .byte COLOR_DARK_PURPLE
    /* 08 */ .byte COLOR_PURPLE
    /* 09 */ .byte COLOR_GREEN_ROCK
    /* 0A */ .byte COLOR_LIGHT_TEAL
    /* 0B */ .byte COLOR_CHOCOLATE
    /* 0C */ .byte COLOR_RED_ROCK
    /* 0D */ .byte COLOR_PATH
    /* 0E */ .byte COLOR_SACRED
    /* 0F */ .byte COLOR_WHITE