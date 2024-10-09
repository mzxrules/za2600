;==============================================================================
; mzxrules 2021
;==============================================================================

Cv_Del:
    ldx roomEX
    cpx #CV_MESG_HINT_TREE_AT_DEAD_END+1
    bpl .rts
    lda #EN_NPC_APPEAR
    sta enType
    lda CaveTypeH,x
    pha
    lda CaveTypeL,x
    pha
.rts
    rts

Cv_DoorRepair:
    lda #EN_NPC_DOOR_REPAIR
    sta npcType
    lda #NPC_SPR_MAN | #NPC_CAVE
    sta enState
    rts

Cv_Path1:
Cv_Path2:
Cv_Path3:
Cv_Path4:
    lda #EN_NPC_PATH
    sta npcType
    lda #NPC_SPR_MAN | #NPC_CAVE
    sta enState
    rts

Cv_Sword1:
Cv_Sword2:
Cv_Sword3:
Cv_Note:
    lda #EN_NPC_GIVE_ONE
    sta npcType
    lda #NPC_SPR_MAN | #NPC_CAVE
    sta enState
    rts

Cv_Rupees100:
Cv_Rupees30:
Cv_Rupees10:
    lda #EN_NPC_GIVE_ONE
    sta npcType
    lda #NPC_SPR_MONSTER | #NPC_CAVE
    sta enState
    rts

Cv_MoneyGame:
    lda #EN_NPC_GAME
    sta npcType
    lda #NPC_SPR_MAN | #NPC_CAVE
    sta enState
    rts

Cv_Shop1:
Cv_Shop2:
Cv_Shop3:
Cv_Shop4:
    lda #EN_NPC_SHOP
    sta npcType
    lda #NPC_SPR_SHOP | #NPC_CAVE
    sta enState
    rts

Cv_Potion:
    lda #EN_NPC_SHOP
    sta npcType
    lda #NPC_SPR_WOMAN | #NPC_CAVE
    sta enState
    rts

Rs_TakeHeartRupee:
    lda #EN_NPC_APPEAR
    sta enType
    lda #CV_TAKE_HEART_RUPEE
    sta roomEX
    lda #RS_NONE
    sta roomRS
Cv_TakeHeartRupee:
Cv_GiveHeartPotion:
    lda #EN_NPC_SHOP2
    sta npcType
    lda #NPC_SPR_MAN | #NPC_CAVE
    sta enState
    rts

Cv_MesgHintGrave: SUBROUTINE
Cv_MesgHintLostWoods:
Cv_MesgHintLostHills:
Cv_MesgHintTreeAtDeadEnd:
    lda #EN_NPC
    sta npcType
    lda #NPC_SPR_WOMAN | #NPC_CAVE
    sta enState
    rts

Rs_Npc:
    lda #EN_NPC_APPEAR
    sta enType
    lda #EN_NPC
    sta npcType
    lda #RS_NONE
    sta roomRS
    rts

Rs_NpcMonster:
    lda #EN_NPC_APPEAR
    sta enType
    lda #EN_NPC_MONSTER
    sta npcType
    lda #RS_NONE
    sta roomRS
    rts

Rs_EntCaveWallLeft: SUBROUTINE
    ldx #$14
    cpx plX
    bne .rts
    ldy #$3C
    cpy plY
    bne .rts
    ldy #$38
    jmp RS_ENTER_CAVE

Rs_EntCaveWallRight:
    ldx #$6C
    cpx plX
    bne .rts
    ldy #$3C
    cpy plY
    bne .rts
    ldy #$38
    jmp RS_ENTER_CAVE

Rs_EntCaveWallCenter:
    ldx #$40
    cpx plX
    bne .rts
    ldy #$3C
    cpy plY
    bne .rts
    ldy #$38
    jmp RS_ENTER_CAVE

Rs_EntCaveWall_P4820:
    ldx #$48
    cpx plX
    bne .rts
    ldy #$24
    cpy plY
    bne .rts
    ldy #$20
    jmp RS_ENTER_CAVE

Rs_EntCaveMidSecretNorth:
    lda plState
    and #PS_GLIDE
    bne .rts

    ldy plY
    cpy #48
    bcc Rs_EntCaveMid
    lda plX
    sbc #$3C
    cmp #$44+1 - #$3C
    bcs .rts
    bit CXP0FB
    bpl .rts
    lda plDir
    cmp #PL_DIR_U
    bne .rts
    iny
    sty plY
    lda plState
    ora #[#PS_GLIDE | #PS_LOCK_ALL]
    sta plState
    lda #SEQ_SOLVE_DUR
    sta SeqSolveCur
.rts
    rts

Rs_EntCaveMid:
    ldx #$40
    cpx plX
    bne .rts
    ldy #$28
    cpy plY
    bne .rts
    ldy #$20
RS_ENTER_CAVE:
    jsr ENTER_CAVE
    lda #SLOT_FC_HALT
    sta BANK_SLOT
    jmp HALT_ENTER_CAVE_ENTRY

Rs_Cave:
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    and #RF_EV_LOADED
    beq .skip_initcave
    jmp Cv_Del
.skip_initcave

    lda #$30
    cmp plY
    bpl .skip_cave_SetPos
    sta plY
.skip_cave_SetPos

    lda plY
    cmp #$08
    bne .rts
    lda #MS_PLAY_THEME_L
    jmp RETURN_WORLD


Rs_ItemKey: SUBROUTINE
Rs_Item: SUBROUTINE
    lda roomENCount
    bne .rts ; more enemies to kill
    lda roomId
    and #$7F
    tax
    lda rWorldRoomFlags,x
    bmi .NoLoad

    lda roomFlags
    and #RF_EV_ENCLEAR | #RF_EV_CLEAR
    beq .rts

; select entity slot for our permanent item
; if enType = EN_NONE, slot 0
; if enType = EN_ITEM, slot 1 if enType + 1 is > EN_ITEM, else slot 0
; if enType > EN_ITEM, slot 1 always as a failsafe
    ldx #0
    lda enType
    beq .set_item_slot ; slot 0 is free
    inx ; #1
    cmp #EN_ITEM+1
    bcs .set_item_slot ; force select slot 1
    lda enType+1
    cmp #EN_ITEM+1
    bcc .set_item_slot
    dex ; #0

.set_item_slot
    lda #EN_ITEM
    sta enType,x
    lda #EN_ITEM_PERMANENT
    sta enState,x

    lda roomRS
    cmp #RS_ITEM_KEY
    beq .pos_key

    lda roomEX
    sta cdItemType,x
    lda #$40
    sta en0X,x
    lda #$2C
    sta en0Y,x
.NoLoad
    lda #RS_NONE
    sta roomRS
.rts
    rts

.pos_key
    ; x range $0C to $74
    ; y range $10 to $48
    lda roomEX
    and #$F
    tay
    lda Rs_PosItem_X,y
    sta en0X,x
    lda roomEX
    and #$F0
    lsr
    lsr
    adc #$10
    sta en0Y,x
    lda #GI_KEY
    sta roomEX
    sta cdItemType,x
    bpl .NoLoad ;jmp

Rs_PosItem_X:
    .byte $0C, $14, $18, $20
    .byte $28, $30, $34, $38
    .byte $44, $48, $4C, $54
    .byte $5C, $64, $6C, $74


Rs_EntDungData_TestX:
    .byte #$40, #$40, #$58
Rs_EntDungData_TestY:
    .byte #$28, #$1C, #$24
Rs_EntDungData_RetX:
    .byte #$40, #$48, #$58
Rs_EntDungData_RetY:
    .byte #$20, #$1C, #$1C

Rs_EntDungBush: SUBROUTINE
    ldx #0
    lda enType
    beq .select_slot ; #EN_NONE
    inx
.select_slot
    lda #$40
    sta en0X,x
    lda #$1C
    sta en0Y,x
    lda #EN_STAIRS
    sta enType,x
    lda #EN_STAIRS_DISPLAY_ONLY
    sta cdStairType,x
    lda #RS_ENT_DUNG_STAIRS
    sta roomRS
    rts

Rs_EntDungMid: SUBROUTINE
Rs_EntDungStairs: SUBROUTINE
Rs_EntDungSpectacleRock:
    lda roomRS
    sec
    sbc #RS_ENT_DUNG_MID
    tax

    lda plX
    cmp Rs_EntDungData_TestX,x
    bne .rts
    lda plY
    cmp Rs_EntDungData_TestY,x
    bne .rts
    lda Rs_EntDungData_RetX,x
    sta worldSX
    lda Rs_EntDungData_RetY,x
    sta worldSY
    lda roomId
    sta worldSR

    ldy roomEX
    sty worldId
    lda #SLOT_FC_HALT
    sta BANK_SLOT
    jmp HALT_ENTER_DUNG_ENTRY ; SPAWN_AT_DEFAULT

Rs_ExitDung: ; SUBROUTINE
    bit roomFlags
    bmi .rts ; #RF_EV_LOAD
    lda plY
    cmp #BoardYD
    bne .rts
Rs_ExitDung2:
    lda #MS_PLAY_THEME_L
    jmp RETURN_WORLD

STAIR_POS_P402C = 0
STAIR_POS_P1834 = 1
STAIR_POS_P7448 = 2
STAIR_POS_P742C = 3
STAIR_POS_P2828 = 4

; Y = Stair Position LUT index
PlaceStairs: ; SUBROUTINE
    ldx #0
    lda enType
    cmp #EN_NONE
    beq .entity_index_set
    inx
.entity_index_set
    lda #EN_STAIRS
    cmp enType,x
    beq .rts
    sta enType,x
    lda #$80
    sta en0Y,x
    lda #EN_STAIRS_HIDE_IF_OBSCURED
    sta cdStairType,x
    sty cdStairPos,x
.rts
    rts

Rs_BlockPathStairs: ; SUBROUTINE
    lda roomFlags
    and #RF_EV_CLEAR
    beq .rts
    ldy #STAIR_POS_P1834
    bpl PlaceStairs ; jmp

Rs_BlockDiamondStairs: ; SUBROUTINE
Rs_Stairs: ;SUBROUTINE
    lda roomFlags
    and #RF_EV_CLEAR
    beq .rts
    ldy #STAIR_POS_P402C
    bpl PlaceStairs ; jmp

Rs_BlockLeftStairs: ; SUBROUTINE
    lda roomFlags
    and #RF_EV_CLEAR
    beq .rts
    ldy #STAIR_POS_P7448
    bpl PlaceStairs ; jmp

Rs_BlockSpiralStairs: ; SUBROUTINE
    lda roomFlags
    and #RF_EV_CLEAR
    beq .rts
    ldy #STAIR_POS_P2828
    bpl PlaceStairs ; jmp


Rs_EntCaveWallCenterBlocked: SUBROUTINE
    SET_WALL_DESTROY_XY 40, 38
Rs_EntCaveWallLeftBlocked:
    SET_WALL_DESTROY_XY 14, 38
Rs_EntCaveWallRightBlocked:
    SET_WALL_DESTROY_XY 6C, 38
Rs_EntCaveWallBlocked_P4820:
    SET_WALL_DESTROY_XY 48, 20
Rs_EntDungSpectacleRockBlocked:
    SET_WALL_DESTROY_XY 58, 20
Rs_EntCaveWallBlocked
    bit CXM0FB
    bvc .skip_rts
    lda plState2
    and #PS_ACTIVE_ITEM
    cmp #PLAYER_BOMB
    bne .skip_rts
    ldy plItemTimer
    cpy #ITEM_ANIM_BOMB_BREAKWALL
    bmi .skip_rts
; opening destroyed
    lda #SEQ_SOLVE_DUR
    sta SeqSolveCur
    ldy roomId
    lda rWorldRoomFlags,y
    ora #WRF_SV_DESTROY
    sta wWorldRoomFlags,y
    rts ; jmp RsInit_Wall
.skip_rts
    pla
    pla
.rts
    rts

Rs_EntDungBushBlocked: SUBROUTINE ; $40, $1C
    SET_BUSH_DESTROY_XY 40, 1C
Rs_EntCaveBushBlocked_P3428:
    SET_BUSH_DESTROY_XY 34, 28
Rs_EntCaveBushBlocked_P402C:
    SET_BUSH_DESTROY_XY 40, 2C
Rs_EntCaveBushBlocked_P5820:
    SET_BUSH_DESTROY_XY 58, 20
Rs_EntCaveBushBlocked_P6420:
    SET_BUSH_DESTROY_XY 64, 20
Rs_EntCaveBushBlocked_P6438:
    SET_BUSH_DESTROY_XY 64, 38
Rs_EntCaveBushBlocked_P6C18:
    SET_BUSH_DESTROY_XY 6C, 18

Rs_EntCaveBushBlocked
    ldy roomId
    lda rWorldRoomFlags,y
    and #WRF_SV_DESTROY
    bne Rs_EntCaveBushStairs

    bit CXM0FB
    bvc .skip_rts
    lda plState3
    and #PS_ACTIVE_ITEM2
    cmp #PLAYER_FIRE_FX
    bne .skip_rts
    lda plItem2Time
    cmp #ITEM_ANIM_FIRE_BURNBUSH
    bcc .skip_rts

; opening destroyed
    lda #SEQ_SOLVE_DUR
    sta SeqSolveCur
    ldy roomId
    lda rWorldRoomFlags,y
    ora #WRF_SV_DESTROY
    sta wWorldRoomFlags,y
    rts ; jmp RsInit_Bush
.skip_rts
    pla
    pla
.rts
    rts

Rs_EntCaveBushStairs:
    lda roomFlags
    and #RF_EV_CLEAR
    beq .rts
    lda roomRS
    sec
    sbc #RS_ENT_DUNG_BUSH_BLOCKED - (StairBushPosX - StairPosX)
    tay
    jmp PlaceStairs


Rs_EntDungFlute: SUBROUTINE
    ldy roomId
    lda rWorldRoomFlags,y
    and #WRF_SV_DESTROY
    bne .animate

; extra safety check
    lda roomFlags
    and #RF_EV_LOAD
    bne .rts

    lda plState2
    and #PS_ACTIVE_ITEM
    cmp #PLAYER_FLUTE
    bne .rts
    lda plItemTimer
    bpl .rts

; reveal dungeon
    lda plState
    ora #PS_LOCK_ALL
    sta plState

    lda #-$40
    sta roomTimer

    lda #$80
    sta m0Y

    ldy roomId
    lda rWorldRoomFlags,y
    ora #WRF_SV_DESTROY
    sta wWorldRoomFlags,y

    lda plState3
    and #PS_ACTIVE_ITEM2
    cmp #PLAYER_FLUTE_FX
    bne .rts
    lda #0
    sta plItem2Time
.rts
    rts

.animate
    lda #-8
    sta plItemTimer

    lda roomTimer
    beq .endAnimate

    ; negate
    eor #$FF
    sec
    adc #0

    tax ;temp
    lsr
    lsr
    lsr
    tay
    lda .LEVEL_7_PF2,y
    sta wPF2Room+7,y
    lda #$C0
    sta wPF1RoomL+7,y
    sta wPF1RoomR+7,y
    txa
    and #7
    eor #5
    bne .rts

    lda #SFX_QUAKE
    sta SfxFlags
    rts

.endAnimate
    lda plState
    and #~PS_LOCK_ALL
    sta plState

    lda #SEQ_SOLVE_DUR
    sta SeqSolveCur

    lda #RS_ENT_DUNG_MID
    sta roomRS
    rts

.LEVEL_7_PF2:
    .byte $68 ; |...X.XX.| mirrored
    .byte $74 ; |..X.XXX.| mirrored
    .byte $7E ; |.XXXXXX.| mirrored
    .byte $EE ; |.XXX.XXX| mirrored
    .byte $C6 ; |.XX...XX| mirrored
    .byte $93 ; |XX..X..X| mirrored
    .byte $C6 ; |.XX...XX| mirrored
    .byte $FC ; |..XXXXXX| mirrored