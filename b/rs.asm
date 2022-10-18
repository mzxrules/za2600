;==============================================================================
; mzxrules 2021
;==============================================================================
RoomScriptDel:
    ldx roomRS
    lda RoomScriptH,x
    pha
    lda RoomScriptL,x
    pha
RsNone:
    rts
    
RsFairyFountain: SUBROUTINE
    ldy plY
    cpy #$1C
    bmi .rts
    lda plState
    ldy plHealthMax
    cpy plHealth
    beq .unlock
    ora #PS_LOCK_ALL
    sta plState
    lda #$07
    and Frame
    bne .rts

    lda #$8
    jmp UPDATE_PL_HEALTH
.unlock
    and #~PS_LOCK_ALL
    sta plState
.rts
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
    bit roomFlags ; check RF_EV_LOAD
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
    lda #SFX_SOLVE
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
    ora #RF_EV_LOAD
    sta roomFlags
    lda roomId
    ora #$80
    sta roomId
    rts

RsCave: SUBROUTINE
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    and #RF_EV_LOADED
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
    and #RF_EV_LOAD
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
    bmi .rts ; RF_SV_ITEM_GET ;.NoLoad

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
    ora #RF_EV_LOAD
    sta roomFlags
    rts
    
RsDiamondBlockStairs: SUBROUTINE
    lda #RF_NO_ENCLEAR
    ora roomFlags
    sta roomFlags
    lda #0
    sta wPF2Room + 13
    sta wPF2Room + 14
    ldx #$40
    ldy #$2C
    cpx plX
    bne .initBl
    cpy plY
    beq .skipPushBlock

.initBl
    inx
    stx blX
    lda #$3C
    sta blY
    lda #BL_PUSH_BLOCK
    sta blType
.skipPushBlock
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
    and #RF_EV_CLEAR
    beq .rts
    lda #$40
    sta cdAX
    lda #$2C
    sta cdAY
    lda #EN_STAIRS
    sta cdAType
.rts
    rts
