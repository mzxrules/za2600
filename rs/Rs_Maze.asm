;==============================================================================
; mzxrules 2022
;==============================================================================
Rs_Maze: SUBROUTINE
    ldy roomEX
    lda .type,y
    tax
    cmp worldSR
    beq .skipInit
    sta worldSR ; room
    sty worldSY ; check state
.skipInit
    bit roomFlags ; check RF_EV_LOAD
    bpl .rts
    lda roomIdNext
    cmp .exit,y
    bne .checkPattern
; exit maze without finding hidden area
    sta worldSR
.rts
    rts
.checkPattern
    inc worldSY
    inc worldSY
    ldy worldSY
    lda .pattern-2,y
    cmp roomIdNext
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
    stx roomIdNext
    rts

.type:
    .byte ROOM_MAZE_1, ROOM_MAZE_2
.exit
    .byte <(ROOM_MAZE_1 - #$1), <(ROOM_MAZE_2 + #$1)
.pattern:
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 - #$10)
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 - #$1)
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 + #$10)
    .byte <(ROOM_MAZE_1 - #$10),<(ROOM_MAZE_2 - #$1)