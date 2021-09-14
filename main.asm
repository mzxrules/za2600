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
    INCLUDE "b/0.asm"

    LOG_SIZE "-BANK 0- ENTRY", ENTRY

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
BANK_ALWAYS_ROM = $0400
    INCLUDE "b/a.asm"

    LOG_SIZE "-BANK 1- Always Loaded", BANK_1
    
; ****************************************
; *               BANK 2                 *
; ****************************************

    SEG Bank2
    ORG $0800
    RORG $F400
BANK_2

    INCLUDE "b/draw.asm"
    LOG_SIZE "-BANK 2-", BANK_2

; ****************************************
; *               BANK 3                 *
; ****************************************

    SEG Bank1
    ORG $0C00
    RORG $F000
BANK_3
    INCLUDE "b/room.asm"
    LOG_SIZE "-BANK 3- Room Code", BANK_3

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
    LOG_SIZE "-BANK 4- Sprites PF", BANK_4
    
; ****************************************
; *               BANK 5                 *
; ****************************************

    SEG Bank5
    ORG $1400
    RORG $F000
    
BANK_5
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
    
    LOG_SIZE "-BANK 5- Sprites", BANK_5
    
; ****************************************
; *               BANK 6                 *
; ****************************************

    SEG Bank6
    ORG $1800
    RORG $F400
BANK_6
    INCLUDE "gen/world/b0world.asm"
    INCBIN "world/w0co.bin"
    INCBIN "world/w0rs.bin"
    INCBIN "world/w0ex.bin"
    
    repeat 0x80
    .byte $01
    repend

    repeat 0x80
    .byte $00
    repend
    LOG_SIZE "-BANK 6- World 0", BANK_6
    
; ****************************************
; *               BANK 7                 *
; ****************************************
    
    ORG $1C00
    RORG $F400
BANK_7

    INCLUDE "gen/world/b1world.asm"
    INCBIN "world/w1co.bin"
    INCBIN "world/w1rs.bin"
    INCBIN "world/w1ex.bin"
    
    repeat 0x80
    .byte $01
    repend

    repeat 0x80
    .byte $00
    repend
    
    LOG_SIZE "-BANK 7- Dungeon 1", BANK_7
    
; ****************************************
; *               BANK 8                 *
; ****************************************

    SEG Bank8
    ORG $2000
    RORG $F400
BANK_8

    INCLUDE "gen/world/b2world.asm"
    INCBIN "world/w2co.bin"
    INCBIN "world/w2rs.bin"
    INCBIN "world/w2ex.bin"
    
    repeat 0x80
    .byte $01
    repend

    repeat 0x80
    .byte $00
    repend

    LOG_SIZE "-BANK 8- Dungeon 2", BANK_8

; ****************************************
; *               BANK 9                 *
; ****************************************

    SEG Bank9
    ORG $2400
    RORG $F000
BANK_9

    repeat 0x400
    .byte $00
    repend
    
    LOG_SIZE "-BANK 9- FREE", BANK_9

; ****************************************
; *               BANK 10                *
; ****************************************

    SEG Bank10
    ORG $2800
    RORG $F000
BANK_10

    include "b/tx.asm"
    LOG_SIZE "tx.asm break", BANK_10
    align 256
left_text
    include "gen/text_left.asm"
right_text
    include "gen/text_right.asm"
    LOG_SIZE "text_chrset_size", left_text
    include "gen/mesg_data.asm"
 
    LOG_SIZE "-BANK 10/11- Text Bank", BANK_10

; ****************************************
; *               BANK 12                *
; ****************************************

    SEG Bank12
    ORG $3000
    RORG $F000
BANK_12
    INCLUDE "gen/Entity.asm"
    INCLUDE "gen/Ball.asm"
    INCLUDE "gen/EnMoveDir.asm"
    INCLUDE "en/darknut.asm"
    INCLUDE "en/wallmaster.asm"
    INCLUDE "en/octorok.asm"
    INCLUDE "en/likelike.asm"
    INCLUDE "en/bosscucco.asm"
    include "b/en.asm"
    
    LOG_SIZE "-BANK 12/13- EnemyAI", BANK_12


; ****************************************
; *               BANK 14                *
; ****************************************

    SEG Bank14
    ORG $3800
    RORG $F000
BANK_14
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
    INCLUDE "gen/ms_myst0_note.asm"
    INCLUDE "gen/ms_myst0_dur.asm"
    INCLUDE "gen/ms_myst1_note.asm"
    INCLUDE "gen/ms_myst1_dur.asm"
    
    align 16
    INCLUDE "gen/ms_header.asm"
    INCLUDE "gen/MusicSeq.asm"
    INCLUDE "gen/Sfx.asm"
    INCLUDE "b/au.asm"

    LOG_SIZE "-BANK 14/15- Audio", BANK_14

; ****************************************
; *               BANK 16                *
; ****************************************

    SEG Bank16
    ORG $4000
    RORG $F000

BANK_16
    INCLUDE "gen/RoomScript.asm"
    INCLUDE "b/rs.asm"
    LOG_SIZE "-BANK 16/17- Engine", BANK_16
    
; ****************************************
; *               BANK 18                *
; ****************************************

    SEG Bank18
    ORG $4800
    RORG $F000

BANK_18
    INCLUDE "b/sh.asm"
    INCLUDE "gen/ItemId.asm"
    LOG_SIZE "-BANK 18- Shops and Get Items", BANK_18
