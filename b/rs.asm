;==============================================================================
; mzxrules 2021
;==============================================================================
Rs_Del:
    ldx roomRS
    lda RoomScriptH,x
    pha
    lda RoomScriptL,x
    pha
Rs_None:
    rts
    
Rs_FairyFountain: SUBROUTINE
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

Rs_Maze: SUBROUTINE
    ldy roomEX
    lda Rs_Maze_Type,y
    tax
    cmp worldSR
    beq .skipInit
    sta worldSR ; room
    sty worldSY ; check state
.skipInit
    bit roomFlags ; check RF_EV_LOAD
    bpl .rts
    lda roomId
    cmp Rs_Maze_Exit,y 
    bne .checkPattern
; exit maze without finding hidden area
    sta worldSR
.rts
    rts
.checkPattern
    inc worldSY
    inc worldSY
    ldy worldSY
    lda Rs_Maze_Pattern-2,y
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

Rs_Maze_Type: 
    .byte ROOM_MAZE_1, ROOM_MAZE_2
Rs_Maze_Exit
    .byte <(ROOM_MAZE_1 - #$1), <(ROOM_MAZE_2 + #$1)
Rs_Maze_Pattern:
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 - #$10)
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 - #$1)
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 + #$10)
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 - #$1)
    
Rs_EntCaveLeft: SUBROUTINE
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
    
Rs_EntCaveRight: SUBROUTINE
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

Rs_Cave: SUBROUTINE
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
    
Rs_RaftSpot: SUBROUTINE
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
    rts
    
Rs_NpcTriforce: SUBROUTINE
    ldy #$FF
    cpy itemTri
    beq .rts
    
    lda #RF_NO_ENCLEAR
    ora roomFlags
    sta roomFlags
    lda #MESG_NEED_TRIFORCE
    sta roomEX

Rs_Npc: ; SUBROUTINE
    lda #EN_OLD_MAN
    sta enType
Rs_Text: ; SUBROUTINE
    lda roomEX
EnableText: ; SUBROUTINE ; A = messageId
    sta mesgId
    lda #1
    sta KernelId
.rts
    rts

Rs_ShoreItem: SUBROUTINE
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
    
Rs_Item: SUBROUTINE
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

Rs_GameOver: SUBROUTINE
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
    stx plState ; PS_LOCK_ALL
    
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
    jmp RESPAWN
.rts
    rts

Rs_EntMidWorld:  
Rs_EntMidDung: SUBROUTINE
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
    
Rs_ExitDung: SUBROUTINE
    bit roomFlags
    bmi .rts ; RF_EV_LOAD
    lda plY
    cmp #BoardYD
    bne .rts
Rs_ExitDung2:
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
    lda plState
    and #~PS_LOCK_ALL
    sta plState
    lda plState2
    and #~PS_HOLD_ITEM
    sta plState2
    lda #PL_DIR_D
    sta plDir
    rts
    
Rs_BlockDiamondStairs: SUBROUTINE
    lda #RS_STAIRS
    sta roomRS
    rts

Rs_EntCaveLeftBlocked: SUBROUTINE
    ldx #RS_ENT_CAVE_LEFT
    bne .main
Rs_EntCaveRightBlocked:
    ldx #RS_ENT_CAVE_RIGHT
.main
    bit CXM0FB
    bvc .rts
    lda plState2
    and #PS_ACTIVE_ITEM
    cmp #PLAYER_BOMB
    bne .rts
    ldy plItemTimer
    cpy #-6
    bmi .rts
; opening destroyed
    stx roomRS
    lda #SFX_SOLVE
    sta SfxFlags
    ldy roomId
    lda rRoomFlag,y
    ora #RF_SV_DESTROY
    sta wRoomFlag,y
    lda #$80
    sta blY
    
    lda #$F3
    cpx #RS_ENT_CAVE_LEFT
    bne .right

    sta wPF1RoomL + 12
    sta wPF1RoomL + 13
    sta wPF1RoomL + 14
    rts
.right
    sta wPF1RoomR + 12
    sta wPF1RoomR + 13
    sta wPF1RoomR + 14

.rts
    rts

Rs_BlockCentral: SUBROUTINE
    rts
    
Rs_Stairs:
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
