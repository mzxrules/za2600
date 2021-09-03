;==============================================================================
; mzxrules 2021
;==============================================================================
    processor 6502
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
BANK_0
    INCLUDE "spr/spr_room_pf1.asm"
    INCLUDE "spr/spr_room_pf2.asm"
    INCLUDE "spr/spr_en.asm"
    INCLUDE "spr/spr_item.asm"
MINIMAP
    INCLUDE "spr/spr_map.asm"
    align $20
    INCLUDE "spr/spr_pl.asm"
    INCLUDE "spr/spr_num.asm"

    LOG_SIZE "-BANK 0- Sprites", BANK_0

    SEG Bank1
    ORG $0800
    RORG $F000
BANK_1
    INCLUDE "gen/world/b1world.asm"
    INCBIN "world/w0co.bin"
    .byte $0F
    INCLUDE "kworld.asm"
    INCBIN "world/w0rs.bin"
    .byte #RS_NONE
    ORG $0800+0x500
    RORG $F000+0x500
    INCBIN "world/w0ex.bin"
    
    ORG $0800+0x600
    RORG $F000+0x600
    
	repeat 0x100
	.byte $01
	repend

	repeat 0x100
	.byte $00
	repend
    
    LOG_SIZE "-BANK 1- World", BANK_1

    SEG Bank2
    ORG $1000
    RORG $F000
BANK_2
    INCLUDE "gen/world/b2world.asm"
    INCBIN "world/w1co.bin"
    INCBIN "world/w2co.bin"
    INCBIN "world/w1rs.bin"
    INCBIN "world/w2rs.bin"
    INCBIN "world/w1ex.bin"
    INCBIN "world/w2ex.bin"
    
    repeat 8
        repeat 8
        .byte $01, $00
        repend
        repeat 8
        .byte $00, $01
        repend
    repend
    
	repeat 256
	.byte $00
	repend
    
    LOG_SIZE "-BANK 2- Dungeons", BANK_2

; ****************************************
; *               BANK 3                 *
; ****************************************

    SEG Bank3
    ORG $1800
    RORG $F000
BANK_3

left_text
    include "gen/text_left.asm"
right_text
    include "gen/text_right.asm"
    LOG_SIZE "text_chrset_size", left_text
    align 256
    include "gen/mesg_data.asm"
    include "b3.asm"
 
    LOG_SIZE "-BANK 3- Text Bank", BANK_3

; ****************************************
; *               BANK 4                 *
; ****************************************

    SEG Bank4
    ORG $2000
    RORG $F000
BANK_4
    INCLUDE "gen/Entity.asm"
    INCLUDE "gen/Ball.asm"
    INCLUDE "gen/ItemId.asm"
    INCLUDE "gen/EnMoveDir.asm"
    INCLUDE "en/darknut.asm"
    INCLUDE "en/wallmaster.asm"
    INCLUDE "en/octorok.asm"
    INCLUDE "en/likelike.asm"
    INCLUDE "en/bosscucco.asm"
    include "b4.asm"
    
    LOG_SIZE "-BANK 4- EnemyAI", BANK_4


; ****************************************
; *               BANK 5                 *
; ****************************************

    SEG Bank5
    ORG $2800
    RORG $F000
BANK_5
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
    INCLUDE "b5.asm"

    LOG_SIZE "-BANK 5- Audio", BANK_5

    SEG Bank6
    ORG $3000
    RORG $F000


; ****************************************
; *               BANK 6                 *
; ****************************************

BANK_6
    INCLUDE "gen/RoomScript.asm"
    INCLUDE "b6.asm"
    LOG_SIZE "-BANK 6- Engine", BANK_6

; ****************************************
; *               BANK 7                 *
; ****************************************

    SEG Bank7
    ORG $3800
    RORG $F800

	repeat 512
	.byte $00
	repend

ENTRY: SUBROUTINE
    CLEAN_START
    
    lda BANK_RAM7 ; MUST exist as LDA $1FE7 to pass E7 detection
    tya
.wipeRam2
    dex
    sta $f000,x
    bne .wipeRam2
    
    ; all registers 0
    ldy #3
.loRamLoop
    lda BANK_RAM,y
    txa
.wipeRam1
    dex
    sta wRAM_SEG,x
    bne .wipeRam1
    dey
    bpl .loRamLoop
    ; loRamBank = 0
    
    ; kernel transfer
    lda BANK_ROM+1
    ldy #KERNEL_LEN
.initWorldKernMem
    lda KERNEL_WORLD-1,y
    sta wKERNEL-1,y
    dey
    bne .initWorldKernMem
    LOG_SIZE "ENTRY", ENTRY
    INCLUDE "b7.asm"

    LOG_SIZE "-BANK 7-", ENTRY
        
    ORG $3FE0
    ; This space is reserved to prevent unintentional bank swaps
    .byte $0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $A, $B, $C, $D, $E, $F
    .byte $0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $A, $B
    
	ORG $3FFC
	RORG $FFFC
	.word ENTRY
	.byte "07"
    END