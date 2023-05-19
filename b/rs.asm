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

Cv_MoneyGame:
Cv_GiveHeartPotion:
Cv_TakeHeartRupee:
Cv_Rupees:
Cv_DoorRepair:
.rts
    rts


Cv_Path1:
Cv_Path2:
Cv_Path3:
Cv_Path4:
    lda #EN_NPC_PATH
    sta enType
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

Rs_EntCaveWallLeft: SUBROUTINE
    ldx #$14
    cpx plX
    bne .rts
    ldy #$3C
    cpy plY
    bne .rts
    ldy #$38
    jmp EnterCave

Rs_EntCaveWallRight:
    ldx #$6C
    cpx plX
    bne .rts
    ldy #$3C
    cpy plY
    bne .rts
    ldy #$38
    jmp EnterCave

Rs_EntCaveWallCenter:
    ldx #$40
    cpx plX
    bne .rts
    ldy #$3C
    cpy plY
    bne .rts
    ldy #$38
    jmp EnterCave

Rs_EntCaveMid:
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

Rs_BlockDiamondStairs: SUBROUTINE
    lda #RS_STAIRS
    sta roomRS
    rts

Rs_EntCaveWallCenterBlocked: SUBROUTINE
    ldx #RS_ENT_CAVE_WALL_CENTER
    bne .main
Rs_EntCaveWallLeftBlocked:
    ldx #RS_ENT_CAVE_WALL_LEFT
    bne .main
Rs_EntCaveWallRightBlocked:
    ldx #RS_ENT_CAVE_WALL_RIGHT
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
    cpx #RS_ENT_CAVE_WALL_LEFT
    beq .left
    cpx #RS_ENT_CAVE_WALL_RIGHT
    beq .right
    lda #$7F

    sta wPF2Room + 12
    sta wPF2Room + 13
    sta wPF2Room + 14
    rts

.left
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

Rs_BlockPathStairs: SUBROUTINE
    lda roomFlags
    and #RF_EV_CLEAR
    beq .rts
    lda #$18
    sta cdAX
    lda #$34
    sta cdAY
    lda #EN_STAIRS
    sta cdAType
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
