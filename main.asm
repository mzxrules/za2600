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

    LOG_BANK_SIZE "-BANK 3- Reserved", BANK_3

; ****************************************
; *               BANK 4                 *
; ****************************************
    SEG Bank4
    ORG $1000
    RORG $F400

BANK_4
BANK_PF
    INCLUDE "spr/spr_room_pf1.asm"
    INCLUDE "spr/spr_room_pf2.asm"
    LOG_BANK_SIZE "-BANK 4- Sprites PF 0", BANK_4

; ****************************************
; *               BANK 5                 *
; ****************************************
    SEG Bank5
    ORG $1400
    RORG $F400

BANK_5
    ;INCLUDE "spr/spr_room_pf1.asm"
    ;INCLUDE "spr/spr_room_pf2.asm"
    LOG_BANK_SIZE "-BANK 5- Sprites PF 1", BANK_5

; ****************************************
; *               BANK 6                 *
; ****************************************
    SEG Bank6
    ORG $1800
    RORG $F000

BANK_6
    INCLUDE "spr/spr_item.asm"
    align $100
    INCLUDE "spr/spr_en.asm"
    align $100
MINIMAP
    INCLUDE "spr/spr_map.asm"
    align $20
    INCLUDE "spr/spr_pl.asm"
    INCLUDE "spr/spr_sh.asm"
    INCLUDE "spr/spr_num.asm"
    INCLUDE "spr/spr_gohma.asm"

    LOG_BANK_SIZE "-BANK 6- Sprites", BANK_6

; ****************************************
; *               BANK 7                 *
; ****************************************
    SEG Bank7
    ORG $1C00
    RORG $F000

BANK_7
    LOG_BANK_SIZE "-BANK 7- RESERVED", BANK_7

; ****************************************
; *               BANK 8                 *
; ****************************************
    SEG Bank8
    ORG $2000,0
    RORG $F400

BANK_8
MesgAL
MesgAH = MesgAL + $40
    INCLUDE "gen/mesg_data_lut.asm"
MesgData
    INCLUDE "gen/mesg_data_0A.asm"
    LOG_BANK_SIZE "-BANK 8/11- Mesg Data", BANK_8

    ORG $2400
    RORG $F400
    INCLUDE "gen/mesg_data_lut.asm"
    INCLUDE "gen/mesg_data_0B.asm"

    ORG $2800
    RORG $F400
    INCLUDE "gen/mesg_data_lut.asm"
    INCLUDE "gen/mesg_data_1A.asm"

    ORG $2C00
    RORG $F400
    INCLUDE "gen/mesg_data_lut.asm"
    INCLUDE "gen/mesg_data_1B.asm"

    ORG $2FFF
    .byte $00

; ****************************************
; *               BANK 12                *
; ****************************************
    SEG Bank12
    ORG $3000
    RORG $F400

BANK_12
    INCLUDE "gen/world/b0world.asm"
    INCBIN "gen/world/b0wa.bin"
    INCBIN "world/w0co.bin"
    INCBIN "world/w0rs.bin"
    INCBIN "world/w0ex.bin"

    repeat 0x77
    .byte $01
    repend
    .byte $06
    repeat 0x8
    .byte $01
    repend
    LOG_BANK_SIZE "-BANK 12- World 0", BANK_12

; ****************************************
; *               BANK 13                *
; ****************************************
    SEG Bank13
    ORG $3400
    RORG $F400

BANK_13
    INCLUDE "gen/world/b1world.asm"
    INCBIN "gen/world/b1wa.bin"
    INCBIN "world/w1co.bin"
    INCBIN "world/w1rs.bin"
    INCBIN "world/w1ex.bin"

    repeat 0x80
    .byte $02
    repend

    LOG_BANK_SIZE "-BANK 13- Dungeon 1", BANK_13

; ****************************************
; *               BANK 14                *
; ****************************************
    SEG Bank14
    ORG $3800
    RORG $F400

BANK_14
    INCLUDE "gen/world/b2world.asm"
    INCBIN "gen/world/b2wa.bin"
    INCBIN "world/w2co.bin"
    INCBIN "world/w2rs.bin"
    INCBIN "world/w2ex.bin"

    repeat 0x80
    .byte $01
    repend

    LOG_BANK_SIZE "-BANK 14- Dungeon 2", BANK_14

; ****************************************
; *               BANK 15                *
; ****************************************
    SEG Bank15
    ORG $3C00
    RORG $F400

BANK_15
    LOG_BANK_SIZE "-BANK 15- RESERVED", BANK_15

; ****************************************
; *               BANK 16                *
; ****************************************
    SEG Bank15
    ORG $4000
    RORG $F400

BANK_16
    LOG_BANK_SIZE "-BANK 16- RESERVED", BANK_16

; ****************************************
; *               BANK 17                *
; ****************************************
    SEG Bank17
    ORG $4400
    RORG $F400

BANK_17
    LOG_BANK_SIZE "-BANK 17- RESERVED", BANK_17

; ****************************************
; *               BANK 18                *
; ****************************************
    SEG Bank18
    ORG $4800
    RORG $F000

BANK_18
    INCLUDE "b/sh.asm"
    INCLUDE "gen/ItemId.asm"
    LOG_BANK_SIZE "-BANK 18- Shops and Get Items", BANK_18

; ****************************************
; *               BANK 19                *
; ****************************************
    SEG Bank19
    ORG $4C00
    RORG $F400

BANK_19
    INCLUDE "b/draw.asm"
    LOG_BANK_SIZE "-BANK 19- Draw", BANK_19

    SEG Bank1
    ORG $0C00
    RORG $F000

; ****************************************
; *               BANK 20                *
; ****************************************
    SEG Bank20
    ORG $5000
    RORG $F000

BANK_20
    INCLUDE "b/tx.asm"
    LOG_BANK_SIZE "tx.asm break", BANK_20
    align 256
left_text
    INCLUDE "gen/text_left.asm"
right_text
    INCLUDE "gen/text_right.asm"
    LOG_BANK_SIZE "-BANK 20- Text Kernel", BANK_20

; ****************************************
; *               BANK 21                *
; ****************************************
    SEG Bank21
    ORG $5400
    RORG $F000

BANK_21
    INCLUDE "b/room.asm"
    LOG_BANK_SIZE "-BANK 21- Room Code", BANK_21

; ****************************************
; *               BANK 22                *
; ****************************************
    SEG Bank22
    ORG $5800
    RORG $F000

BANK_22
    INCLUDE "gen/Entity.asm"
    INCLUDE "gen/EnMoveDir.asm"
    INCLUDE "b/en.asm"

    INCLUDE "en/En_Darknut.asm"
    INCLUDE "en/En_LikeLike.asm"
    INCLUDE "en/En_Octorok.asm"
    INCLUDE "en/En_Rope.asm"
    INCLUDE "en/En_Wallmaster.asm"

    INCLUDE "en/En_BossGohma.asm"
    INCLUDE "en/EnBoss_Cucco.asm"

    INCLUDE "en/En_Oldman.asm"
    INCLUDE "en/En_ItemGet.asm"
    INCLUDE "en/EnSys_Damage.asm"

    LOG_BANK_SIZE "-BANK 22/23- EnemyAI", BANK_22


; ****************************************
; *               BANK 24                *
; ****************************************
    SEG Bank14
    ORG $6000
    RORG $F000

BANK_24
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
    INCLUDE "gen/MusicSeq.asm"
    INCLUDE "gen/Sfx.asm"
    INCLUDE "b/au.asm"

    LOG_BANK_SIZE "-BANK 24/25- Audio", BANK_24

; ****************************************
; *               BANK 26                *
; ****************************************
    SEG Bank26
    ORG $6800
    RORG $F000

BANK_26
    INCLUDE "gen/RoomScript.asm"
    INCLUDE "gen/CaveType.asm"
    INCLUDE "b/rs.asm"
    INCLUDE "rs/Rs_GameOver.asm"
    INCLUDE "rs/Rs_Maze.asm"
    INCLUDE "rs/Rs_RaftSpot.asm"
    INCLUDE "rs/Rs_ShoreItem.asm"
    INCLUDE "c/mi_system.asm"
    INCLUDE "gen/atan2.asm"
    INCLUDE "c/atan2.asm"
    LOG_BANK_SIZE "-BANK 26/27- Engine", BANK_26

; ****************************************
; *               BANK 28                *
; ****************************************
    SEG Bank28
    ORG $7000
    RORG $F000

BANK_28
    INCLUDE "gen/Ball.asm"
    INCLUDE "b/pu.asm"
    INCLUDE "gen/EntityDraw.asm"
    INCLUDE "en/EnDraw_Del.asm"
    INCLUDE "en/EnDraw_None.asm"
    INCLUDE "en/EnDraw_ClearDrop.asm"
    INCLUDE "en/EnDraw_ItemGet.asm"
    INCLUDE "en/EnDraw_Darknut.asm"
    INCLUDE "en/EnDraw_LikeLike.asm"
    INCLUDE "en/EnDraw_OldMan.asm"
    INCLUDE "en/EnDraw_Wallmaster.asm"
    INCLUDE "en/EnDraw_Octorok.asm"
    INCLUDE "en/EnDraw_Rope.asm"
    INCLUDE "en/EnDraw_Shopkeeper.asm"
    INCLUDE "en/EnDraw_NpcGiveOne.asm"
    INCLUDE "en/EnDraw_BossGohma.asm"

    LOG_BANK_SIZE "-BANK 28- PushSystem", BANK_28

; ****************************************
; *               BANK 29                *
; ****************************************
    SEG Bank28
    ORG $7400
    RORG $F000

BANK_29
    INCLUDE "gen/RoomScriptInit.asm"
    INCLUDE "rs/RsInit_Del.asm"
    INCLUDE "rs/RsInit_None.asm"
    INCLUDE "rs/RsInit_BlockCentral.asm"
    INCLUDE "rs/RsInit_BlockDiamondStairs.asm"
    INCLUDE "rs/RsInit_EntCaveLeftBlocked.asm"
    INCLUDE "rs/RsInit_EntCaveRightBlocked.asm"

    LOG_BANK_SIZE "-BANK 29- RoomScriptInit", BANK_29

; ****************************************
; *               BANK 30                *
; ****************************************
    SEG Bank30
    ORG $7800
    RORG $F000

BANK_30
    INCLUDE "c/player_input.asm"

    LOG_BANK_SIZE "-BANK 30- Player", BANK_30


; ****************************************
; *               BANK 31                *
; ****************************************
    SEG Bank31
    ORG $7C00
    RORG $F400

BANK_31
DRAW_PAUSE_MENU_TRI: BHA_BANK_FALL #SLOT_DRAW_PAUSE_2
    INCLUDE "c/draw_pause_world.asm"
    INCLUDE "c/draw_pause_menu.asm"
    LOG_BANK_SIZE "-BANK 31- Draw Paused World", BANK_31

; ****************************************
; *               BANK 32                *
; ****************************************
    SEG Bank32
    ORG $8000
    RORG $F400

BANK_32
    INCLUDE "c/draw_pause_menu_tri.asm"
    LOG_BANK_SIZE "-BANK 32- Draw Paused Tri", BANK_32