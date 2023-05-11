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
Rs_BlockCentral:
Rs_FairyFountain:
    rts

Cv_Del:
    ldx roomEX
    cpx CV_DOOR_REPAIR+1
    bpl .rts
    lda CaveTypeH,x
    pha
    lda CaveTypeL,x
    pha

Cv_Path1:
Cv_Path2:
Cv_Path3:
Cv_Path4:
Cv_MoneyGame:
Cv_GiveHeartPotion:
Cv_TakeHeartRupee:
Cv_Rupees:
Cv_DoorRepair:
.rts
    rts


Cv_Sword1:
Cv_Sword2:
Cv_Sword3:
Cv_Note:
    lda #EN_NPC_GIVE_ONE
    sta enType
    rts


Cv_Potion:
Cv_Shop1:
Cv_Shop2:
Cv_Shop3:
Cv_Shop4:
    lda #EN_SHOPKEEPER
    sta enType
    rts

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

Rs_EntCaveCenterWall: SUBROUTINE
    ldx #$40
    cpx plX
    bne .rts
    ldy #$3C
    cpy plY
    bne .rts
    ldy #$38
    jmp EnterCave
.rts
    rts

Rs_EntCaveMid: SUBROUTINE
    ldx #$40
    cpx plX
    bne .rts
    ldy #$28
    cpy plY
    bne .rts
    ldy #$20
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
    jmp Cv_Del
.skipInit

    lda #$30
    cmp plY
    bpl .skipSetPos
    sta plY
.skipSetPos

    lda plY
    cmp #$08
    bne .rts
    lda #MS_PLAY_THEME_L
    jmp ReturnWorld

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

Rs_EntDungMid: SUBROUTINE
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
    cpy #ITEM_ANIM_BOMB_BREAKWALL
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

Rs_Stairs: SUBROUTINE
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
