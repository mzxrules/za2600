;==============================================================================
; mzxrules 2021
;==============================================================================
    processor 6502
TIA_BASE_ADDRESS = $00
    INCLUDE "vcs.h"
    INCLUDE "macro.h"
    INCLUDE "zmacros.asm"
    INCLUDE "vars.asm"
    INCLUDE "gen/const.asm"

; ****************************************
; *               BANK 0                 *
; ****************************************
    SEG Bank0
    ORG $0000
    RORG $F000

    .byte #'T, #'J, #'3, #'E
    INCLUDE "b/game_entry.asm"
    LOG_BANK_SIZE "-BANK 0- ENTRY", ENTRY

    ORG $03FC
    RORG $FFFC
    .word (ENTRY + $C00)
    .word (ENTRY + $C00)

; ****************************************
; *               BANK 1                 *
; ****************************************
    SEG Bank1
    ORG $0400
    RORG $FC00

BANK_1
    INCLUDE "c/always.asm"
    LOG_BANK_SIZE "Always", BANK_1
    INCLUDE "b/game_main.asm"
    LOG_BANK_SIZE_M1 "-BANK 1- Main Game", BANK_1

; ****************************************
; *               BANK 2                 *
; ****************************************
    SEG Bank2
    ORG $0800
    RORG $FC00

BANK_2
    INCLUDE "c/always.asm"
    INCLUDE "b/game_pause.asm"
    LOG_BANK_SIZE_M1 "-BANK 2- Pause Game", BANK_2

; ****************************************
; *               BANK 3                 *
; ****************************************

    SEG Bank3
    ORG $0C00
    RORG $FC00
BANK_3
    INCLUDE "c/always.asm"
    INCLUDE "b/game_halt.asm"
    LOG_BANK_SIZE "-BANK 3- Halt Game", BANK_3

; ****************************************
; *               BANK 4                 *
; ****************************************
    SEG Bank4
    ORG $1000,0
    RORG $F400

BANK_4
MesgAL
MesgAH = MesgAL + $40
    INCLUDE "gen/mesg_data_lut.asm"
MesgData
    INCLUDE "gen/mesg_data_0A.asm"
    LOG_BANK_SIZE "-BANK 4/7- Mesg Data", BANK_4

    ORG $1400
    RORG $F400
    INCLUDE "gen/mesg_data_lut.asm"
    INCLUDE "gen/mesg_data_0B.asm"

    ORG $1800
    RORG $F400
    INCLUDE "gen/mesg_data_lut.asm"
    INCLUDE "gen/mesg_data_1A.asm"

    ORG $1C00
    RORG $F400
    INCLUDE "gen/mesg_data_lut.asm"
    INCLUDE "gen/mesg_data_1B.asm"

    ORG $1FFF
    .byte $00

; ****************************************
; *               BANK 8                 *
; ****************************************
    SEG Bank8
    ORG $2000
    RORG $F400

BANK_8
    INCLUDE "b/draw.asm"
    LOG_BANK_SIZE "-BANK 8- Draw", BANK_8

; ****************************************
; *               BANK 9                 *
; ****************************************
    SEG Bank9
    ORG $2400
    RORG $F000

BANK_9
    INCLUDE "b/tx.asm"
    LOG_BANK_SIZE "tx.asm break", BANK_9
    align 256
left_text
    INCLUDE "gen/text_left.asm"
right_text
    INCLUDE "gen/text_right.asm"
    LOG_BANK_SIZE "-BANK 9- Text Kernel", BANK_9

; ****************************************
; *               BANK 10                *
; ****************************************
    SEG Bank10
    ORG $2800
    RORG $F000

BANK_10
    INCLUDE "b/sh.asm"
    INCLUDE "gen/ItemId_DelLUT.asm"
    LOG_BANK_SIZE "-BANK 10- Shops and Get Items", BANK_10

; ****************************************
; *               BANK 11                *
; ****************************************
    SEG Bank11
    ORG $2C00
    RORG $F000

BANK_11
    INCLUDE "b/room.asm"
    LOG_BANK_SIZE "-BANK 11- Room Code", BANK_11

; ****************************************
; *               BANK 12                *
; ****************************************
    SEG Bank12
    ORG $3000
    RORG $F400

BANK_12
BANK_PF
    INCLUDE "spr/spr_room_pf1.asm"
    INCLUDE "spr/spr_room_pf2.asm"
    LOG_BANK_SIZE "-BANK 12- Sprites World PF", BANK_12

; ****************************************
; *               BANK 13                *
; ****************************************
    SEG Bank13
    ORG $3400
    RORG $F400

BANK_13
    INCLUDE "spr/spr_room_pf1B.asm"
    INCLUDE "spr/spr_room_pf2B.asm"
    LOG_BANK_SIZE "-BANK 13- Sprites Dung PF", BANK_13

; ****************************************
; *               BANK 14                *
; ****************************************
    SEG Bank14
    ORG $3800
    RORG $F000

BANK_14
    INCLUDE "spr/spr_item.asm"
    align $100
    INCLUDE "spr/spr_en0.asm"
    align $100

    align $20
    INCLUDE "spr/spr_pl.asm"
    INCLUDE "spr/spr_rock.asm"
    INCLUDE "spr/spr_sh.asm"
    INCLUDE "spr/spr_waterfall.asm"

    LOG_BANK_SIZE "-BANK 14- Sprites World", BANK_14

; ****************************************
; *               BANK 15                *
; ****************************************
    SEG Bank15
    ORG $3C00
    RORG $F000

BANK_15
    INCLUDE "spr/spr_item.asm"
    align $100
    INCLUDE "spr/spr_en1.asm"
    align $100

    align $20
    INCLUDE "spr/spr_pl.asm"
    INCLUDE "spr/spr_rock.asm"
    INCLUDE "spr/spr_sh.asm"
    INCLUDE "spr/spr_gohma.asm"
    INCLUDE "spr/spr_aqua.asm"
    align $20
    INCLUDE "spr/spr_manhandla.asm"

    LOG_BANK_SIZE "-BANK 15- Sprites Dung", BANK_15


; ****************************************
; *               BANK 16                *
; ****************************************
    SEG Bank16
    ORG $4000
    RORG $F000

BANK_16
    LOG_BANK_SIZE "-BANK 16- Sprites Boss", BANK_16


; ****************************************
; *               BANK 17                *
; ****************************************
    SEG Bank17
    ORG $4400
    RORG $F000

BANK_17
MINIMAP
    INCLUDE "spr/spr_map.asm"
    .align $80
    INCLUDE "spr/spr_num_l.asm"
    .byte $0
    .align $80
    INCLUDE "spr/spr_num_r.asm"
    LOG_BANK_SIZE "-BANK 17- Sprites HUD", BANK_17

; ****************************************
; *               BANK 18                *
; ****************************************
    SEG Bank18
    ORG $4800
    RORG $F400

BANK_18
    INCLUDE "gen/world/b0world.asm"
    INCBIN "gen/world/b0wa.bin"
    INCBIN "gen/world/b0co.bin"
    INCBIN "world/w0rs.bin"
    INCBIN "world/w0ex.bin"
    INCBIN "gen/world/b0en.bin"

    LOG_BANK_SIZE "-BANK 18- Q1 World 0", BANK_18

; ****************************************
; *               BANK 19                *
; ****************************************
    SEG Bank19
    ORG $4C00
    RORG $F400

BANK_19
    INCLUDE "gen/world/b1world.asm"
    INCBIN "gen/world/b1wa.bin"
    INCBIN "gen/world/b1co.bin"
    INCBIN "world/w1rs.bin"
    INCBIN "world/w1ex.bin"
    INCBIN "gen/world/b1en.bin"
    LOG_BANK_SIZE "-BANK 19- Q1 Dungeon 1", BANK_19

; ****************************************
; *               BANK 20                *
; ****************************************
    SEG Bank20
    ORG $5000
    RORG $F400

BANK_20
    INCLUDE "gen/world/b2world.asm"
    INCBIN "gen/world/b2wa.bin"
    INCBIN "gen/world/b2co.bin"
    INCBIN "world/w2rs.bin"
    INCBIN "world/w2ex.bin"
    INCBIN "gen/world/b2en.bin"
    LOG_BANK_SIZE "-BANK 20- Q1 Dungeon 2", BANK_20

; ****************************************
; *               BANK 21                *
; ****************************************
    SEG Bank21
    ORG $5400
    RORG $F400

BANK_21
    LOG_BANK_SIZE "-BANK 21- Q2 World 0", BANK_21

; ****************************************
; *               BANK 22                *
; ****************************************
    SEG Bank22
    ORG $5800
    RORG $F400

BANK_22
    LOG_BANK_SIZE "-BANK 22- Q2 Dungeon 1", BANK_22

; ****************************************
; *               BANK 23                *
; ****************************************
    SEG Bank23
    ORG $5C00
    RORG $F400

BANK_23
    LOG_BANK_SIZE "-BANK 13- Q2 Dungeon 2", BANK_23

; ****************************************
; *               BANK 24                *
; ****************************************
    SEG Bank24
    ORG $6000
    RORG $F400

BANK_24
DRAW_PAUSE_MENU_TRI: BHA_BANK_FALL #SLOT_F4_PAUSE_DRAW_MENU2
    INCLUDE "c/draw_pause_world.asm"
    INCLUDE "c/draw_pause_menu.asm"
    LOG_BANK_SIZE "-BANK 24- Pause Draw World/Menu 1", BANK_24

; ****************************************
; *               BANK 25                *
; ****************************************
    SEG Bank25
    ORG $6400
    RORG $F400

BANK_25
    INCLUDE "c/draw_pause_menu_tri.asm"
    LOG_BANK_SIZE "-BANK 25- Pause Draw Menu 2", BANK_25

; ****************************************
; *               BANK 26                *
; ****************************************
    SEG Bank26
    ORG $6800
    RORG $F000

BANK_26
    INCLUDE "b/pause_menu_map.asm"
    RORG [. & $3FF] + $F400
Pause_MapPlot:
    lda #SLOT_RW_F0_DUNG_MAP
    sta BANK_SLOT_RAM
    INCLUDE "gen/pause_map.asm"
    RORG [. & $3FF] + $F000
    LOG_BANK_SIZE "-BANK 26- Pause Map generator", BANK_26

; ****************************************
; *               BANK 27                *
; ****************************************
    SEG Bank27
    ORG $6C00
    RORG $F000

BANK_27
    LOG_BANK_SIZE "-BANK 27- Halt Reserve 1", BANK_27

; ****************************************
; *               BANK 28                *
; ****************************************
    SEG Bank28
    ORG $7000
    RORG $F000

BANK_28
    LOG_BANK_SIZE "-BANK 28- Halt Reserve 2", BANK_28

; ****************************************
; *               BANK 29                *
; ****************************************
    SEG Bank29
    ORG $7400
    RORG $F000

BANK_29
    INCLUDE "c/player_input.asm"

    LOG_BANK_SIZE "-BANK 29- Player", BANK_29

; ****************************************
; *               BANK 30                *
; ****************************************
    SEG Bank30
    ORG $7800
    RORG $F400

BANK_30
    INCLUDE "gen/PlUseItem_DelLUT.asm"
    INCLUDE "gen/PlUpdateItem_DelLUT.asm"
    INCLUDE "gen/PlDrawItem_DelLUT.asm"
    INCLUDE "c/player_item.asm"
    LOG_BANK_SIZE "-BANK 30- Player RESERVE", BANK_30

; ****************************************
; *               BANK 31                *
; ****************************************
    SEG Bank31
    ORG $7C00
    RORG $F000

BANK_31
    INCLUDE "b/EnMove_Common.asm"
    INCLUDE "gen/En_DelLUT.asm"
    INCLUDE "gen/En_DelBankLUT.asm"
    INCLUDE "b/en.asm"
    INCLUDE "gen/EnSysEncounter.asm"
    LOG_BANK_SIZE "-BANK 31- Entity Common", BANK_31

; ****************************************
; *               BANK 32                *
; ****************************************
    SEG Bank32
    ORG $8000
    RORG $F000

BANK_32
    INCLUDE "en/EnDraw_Del.asm"
    INCLUDE "b/EnDraw_Common.asm"
    INCLUDE "gen/EnDraw_DelLUT.asm"
    INCLUDE "gen/EnDraw_DelBankLUT.asm"
    INCLUDE "gen/Ball_DelLUT.asm"
    INCLUDE "b/pushblock.asm"
    LOG_BANK_SIZE "-BANK 32- EnDraw/PushSystem", BANK_32

; ****************************************
; *               BANK 33                *
; ****************************************
    SEG Bank33
    ORG $8400
    RORG $F000

BANK_33
    INCLUDE "gen/RsInit_DelLUT.asm"
    INCLUDE "rs/RsInit_Del.asm"
    INCLUDE "rs/RsInit_None.asm"
    INCLUDE "rs/RsInit_BlockCenter.asm"
    INCLUDE "rs/RsInit_BlockLeftStairs.asm"
    INCLUDE "rs/RsInit_BlockDiamondStairs.asm"
    INCLUDE "rs/RsInit_BlockSpiral.asm"
    INCLUDE "rs/RsInit_BlockPathStairs.asm"
    INCLUDE "rs/RsInit_EntCaveWallLeftBlocked.asm"
    INCLUDE "rs/RsInit_EntCaveWallCenterBlocked.asm"
    INCLUDE "rs/RsInit_EntCaveWallRightBlocked.asm"
    INCLUDE "rs/RsInit_FairyFountain.asm"
    INCLUDE "rs/RsInit_EntDungFlute.asm"
    INCLUDE "rs/RsInit_EntDungBush.asm"
    INCLUDE "rs/RsInit_SpectacleRock.asm"
    INCLUDE "rs/RsInit_Waterfall.asm"

    LOG_BANK_SIZE "-BANK 33- RoomScriptInit", BANK_33

; ****************************************
; *               BANK 34                *
; ****************************************
    SEG Bank34
    ORG $8800
    RORG $F000

BANK_34
    INCLUDE "gen/Rs_DelLUT.asm"
    INCLUDE "gen/CaveType_DelLUT.asm"
    INCLUDE "b/rs.asm"
    INCLUDE "rs/Rs_GameOver.asm"
    INCLUDE "rs/Rs_Maze.asm"
    INCLUDE "rs/Rs_RaftSpot.asm"
    INCLUDE "rs/Rs_ShoreItem.asm"
    INCLUDE "rs/Rs_Waterfall.asm"
    LOG_BANK_SIZE "-BANK 34/35- Engine", BANK_34

; ****************************************
; *               BANK 36                *
; ****************************************
    SEG Bank36
    ORG $9000
    RORG $F000

BANK_36
    INCLUDE "gen/ms_dung0_note.asm"
    INCLUDE "gen/ms_dung0_dur.asm"
    INCLUDE "gen/ms_dung1_note.asm"
    INCLUDE "gen/ms_gi0_note.asm"
    INCLUDE "gen/ms_gi0_dur.asm"
    INCLUDE "gen/ms_gi1_note.asm"
    INCLUDE "gen/ms_gi1_dur.asm"
    INCLUDE "gen/ms_over0_note.asm"
    INCLUDE "gen/ms_over0_dur.asm"
    INCLUDE "gen/ms_over1_note.asm"
    INCLUDE "gen/ms_over1_dur.asm"
    INCLUDE "gen/ms_intro0_note.asm"
    INCLUDE "gen/ms_world0_note.asm"
    INCLUDE "gen/ms_intro0_dur.asm"
    INCLUDE "gen/ms_world0_dur.asm"
    INCLUDE "gen/ms_intro1_note.asm"
    INCLUDE "gen/ms_world1_note.asm"
    INCLUDE "gen/ms_intro1_dur.asm"
    INCLUDE "gen/ms_world1_dur.asm"
    INCLUDE "gen/ms_final0_note.asm"
    INCLUDE "gen/ms_final0_dur.asm"
    INCLUDE "gen/ms_final1_note.asm"
    INCLUDE "gen/ms_tri0_note.asm"
    INCLUDE "gen/ms_tri0_dur.asm"
    INCLUDE "gen/ms_tri1_note.asm"
    INCLUDE "gen/ms_tri1_dur.asm"

    align 16
    INCLUDE "gen/ms_header.asm"
    INCLUDE "gen/MusicSeq_DelLUT.asm"
    INCLUDE "b/au.asm"
    LOG_BANK_SIZE "-BANK 36/37- Audio", BANK_36

; ****************************************
; *               BANK 38                *
; ****************************************
    SEG Bank38
    ORG $9800
    RORG $F000

BANK_38
    INCLUDE "gen/Sfx_DelLUT.asm"
    INCLUDE "gen/ms_warp0_note.asm"
    INCLUDE "b/au_sfx.asm"
    LOG_BANK_SIZE "-BANK 38- AudioSfx", BANK_38

; ****************************************
; *               BANK 39                *
; ****************************************
    SEG Bank39
    ORG $9C00
    RORG $F000

BANK_39
    INCLUDE "b/battle.asm"
    LOG_BANK_SIZE "-BANK 39- Battle System", BANK_39

; ****************************************
; *               BANK 40                *
; ****************************************
    SEG Bank40
    ORG $A000
    RORG $F000

BANK_40
    INCLUDE "b/EnMove_Common.asm"
    INCLUDE "b/EnMove.asm"
    INCLUDE "gen/EnMove_SeekDirLUT.asm"
    INCLUDE "gen/EnMove_BallBlockedLUT.asm"
    align 128
    INCLUDE "gen/EnMove_OffgridLUT.asm"
    LOG_BANK_SIZE "-BANK 40- Entity Movement", BANK_40

; ****************************************
; *               BANK 41                *
; ****************************************
    SEG Bank41
    ORG $A400
    RORG $F000

BANK_41
    INCLUDE "gen/atan2.asm"
    INCLUDE "gen/hitbox2_info.asm"
    INCLUDE "gen/MiType_DelLUT.asm"
    INCLUDE "c/mi_system.asm"
    INCLUDE "c/atan2.asm"
    LOG_BANK_SIZE "-BANK 41- MiSystem", BANK_41

; ****************************************
; *               BANK 42                *
; ****************************************
    SEG Bank42
    ORG $A800
    RORG $F400

BANK_42
    INCLUDE "en/EnDraw_None.asm"
    INCLUDE "en/EnDraw_ClearDrop.asm"
    INCLUDE "en/EnDraw_ItemGet.asm"
    INCLUDE "en/EnDraw_Darknut.asm"
    INCLUDE "en/EnDraw_LikeLike.asm"
    INCLUDE "en/EnDraw_Wallmaster.asm"
    INCLUDE "en/EnDraw_Octorok.asm"
    INCLUDE "en/EnDraw_Rope.asm"
    INCLUDE "en/EnDraw_Stalfos.asm"
    INCLUDE "en/EnDraw_Gibdo.asm"
    INCLUDE "en/EnDraw_Goriya.asm"
    INCLUDE "en/EnDraw_TestColor.asm"
    INCLUDE "en/EnDraw_Tektite.asm"
    INCLUDE "en/EnDraw_Leever.asm"
    INCLUDE "en/EnDraw_Moblin.asm"
    INCLUDE "en/EnDraw_Peehat.asm"
    INCLUDE "en/EnDraw_Vire.asm"
    INCLUDE "en/EnDraw_Wizrobe.asm"
    INCLUDE "en/Endraw_Zol.asm"
    INCLUDE "en/Endraw_Gel.asm"

    INCLUDE "gen/mesg_digits.asm"
    INCLUDE "en/EnDraw_Npc.asm"
    INCLUDE "en/EnDraw_NpcPath.asm"
    INCLUDE "en/EnDraw_NpcShop.asm"
    LOG_BANK_SIZE "-BANK 42-", BANK_42

; ****************************************
; *               BANK 43                *
; ****************************************
    SEG Bank43
    ORG $AC00
    RORG $F400

BANK_43
    INCLUDE "en/En_Darknut.asm"
    INCLUDE "en/En_LikeLike.asm"
    INCLUDE "en/En_Octorok.asm"
    INCLUDE "en/En_Rope.asm"
    LOG_BANK_SIZE "-BANK 43-", BANK_43

; ****************************************
; *               BANK 44                *
; ****************************************
    SEG Bank44
    ORG $B000
    RORG $F400

BANK_44
    INCLUDE "en/En_NpcPath.asm"
    INCLUDE "en/En_GreatFairy.asm"
    INCLUDE "en/En_ItemGet.asm"
    INCLUDE "en/En_Wallmaster.asm"
    INCLUDE "en/En_Test.asm"
    INCLUDE "en/En_TestMissile.asm"
    INCLUDE "en/En_BossGohma.asm"
    INCLUDE "en/En_BossGlock.asm"
    INCLUDE "en/En_BossGlockHead.asm"
    LOG_BANK_SIZE "-BANK 44-", BANK_44

; ****************************************
; *               BANK 45                *
; ****************************************
    SEG Bank45
    ORG $B400
    RORG $F400

BANK_45
    INCLUDE "en/En_Npc.asm"
    INCLUDE "en/En_RollingRock.asm"
    INCLUDE "en/En_Appear.asm"
    INCLUDE "en/En_Stalfos.asm"
    INCLUDE "en/En_Keese.asm"
    INCLUDE "en/EnDraw_Keese.asm"
    LOG_BANK_SIZE "-BANK 45-", BANK_45

; ****************************************
; *               BANK 46                *
; ****************************************
    SEG Bank46
    ORG $B800
    RORG $F400

BANK_46
    INCLUDE "en/EnDraw_BossGohma.asm"
    INCLUDE "en/EnDraw_GreatFairy.asm"
    INCLUDE "en/EnDraw_BossGlock.asm"
    INCLUDE "en/EnDraw_BossGlockHead.asm"
    INCLUDE "en/EnDraw_TestMissile.asm"
    INCLUDE "en/EnDraw_Waterfall.asm"
    INCLUDE "en/EnDraw_RollingRock.asm"
    INCLUDE "en/EnDraw_Appear.asm"
    INCLUDE "en/EnDraw_BossAqua.asm"
    INCLUDE "en/EnDraw_BossManhandla.asm"
    LOG_BANK_SIZE "-BANK 46-", BANK_46

; ****************************************
; *               BANK 47                *
; ****************************************
    SEG Bank47
    ORG $BC00
    RORG $F400

BANK_47
    INCLUDE "en/En_Lynel.asm"
    INCLUDE "en/En_Goriya.asm"
    ; INCLUDE "en/En_TestColor.asm"
    INCLUDE "en/En_BossAqua.asm"
    INCLUDE "en/En_BossManhandla.asm"
    LOG_BANK_SIZE "-BANK 47-", BANK_47

; ****************************************
; *               BANK 48                *
; ****************************************
    SEG Bank48
    ORG $C000
    RORG $F400

BANK_48
    INCLUDE "en/En_NpcGiveOne.asm"
    INCLUDE "en/EnDraw_NpcGiveOne.asm"
    INCLUDE "en/En_NpcShop.asm"
    INCLUDE "en/En_NpcShop1.asm"
    INCLUDE "en/En_NpcAppear.asm"
    INCLUDE "en/En_NpcGame.asm"
    INCLUDE "en/En_NpcDoorRepair.asm"
    LOG_BANK_SIZE "-BANK 48-", BANK_48

; ****************************************
; *               BANK 49                *
; ****************************************
    SEG Bank49
    ORG $C400
    RORG $F400

BANK_49
    INCLUDE "en/En_Tektite.asm"
    INCLUDE "en/En_Leever.asm"
    INCLUDE "en/En_Moblin.asm"
    INCLUDE "en/En_Gibdo.asm"
    INCLUDE "en/En_Peehat.asm"
    INCLUDE "en/En_Vire.asm"
    INCLUDE "en/En_Wizrobe.asm"
    INCLUDE "en/En_Zol.asm"
    LOG_BANK_SIZE "-BANK 49-", BANK_49

; ****************************************
; *               BANK 50                *
; ****************************************
    SEG Bank50
    ORG $C800
    RORG $F400

BANK_50
    INCLUDE "en/En_Gel.asm"
    LOG_BANK_SIZE "-BANK 50-", BANK_50

; End

    ORG $FFFF
    RORG $FFFF
    .byte 0