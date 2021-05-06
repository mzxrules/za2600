    processor 6502
    INCLUDE "vcs.h"
    INCLUDE "macro.h"
    INCLUDE "vars.asm"

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
    INCBIN "world/w0co.bin"
    INCBIN "world/w0rs.bin"
    INCBIN "world/w0rs.bin"
    INCBIN "world/w0ex.bin"
    INCBIN "world/w0ex.bin"
    
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

TextKernel: SUBROUTINE
    sta WSYNC ; Scanlines 56 to 97 (3116) (TIM64T 48)
    lda #49
    sta TIM64T
; start
    lda #6
    sta NUSIZ0
    sta NUSIZ1
    lda #$0F
    sta COLUP0
    sta COLUP1
    lda #1
    sta VDELP0
    sta VDELP1
    
TextSetPosition: SUBROUTINE
    lda Frame
    and #1
    beq .position_frame_1
        lda #32
        ldx #0
        jsr SetHorizPos
        lda #48
        ldx #1
        jsr SetHorizPos
        jmp .end_position
    
.position_frame_1    
        lda #40
        ldx #0
        jsr SetHorizPos
        lda #56
        ldx #1
        jsr SetHorizPos
.end_position

    sta WSYNC
    sta HMOVE
    
    lda #$FE
    sta TextLoop

TextDisplayLoop:
.SetVFlag
    inc TextLoop
    inc TextLoop
    lda Frame
    and #$01        ; a ==   x1
    eor #1
    ora TextLoop    ; a ==   11
    ora mesgId      ; a == 1111
    tax
    lda MesgAL,x
    sta TMesgPtr
    lda MesgAH,x
    sta TMesgPtr+1

    clv ; Overflow stores text a/b
    ldy #11
    lda Frame
    and #1
    bne .loadTextLoop
    bit .SetVFlag
    
.loadTextLoop
    lda (TMesgPtr),y
    sta Text0,y
    dey
    bpl .loadTextLoop

.drawtext
    ldx Text0
    lda left_text,x
    ldx Text1
    ora right_text,x
    ldy #0
Frame0Text
    ; Text line 1 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx Text2               ; 4     (13)
    lda left_text,x         ; 4     (17)
    ldx Text3               ; 4     (21)
    ora right_text,x        ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)
    
    ldx Text4               ; 4     (32)
    lda left_text,x         ; 4     (36)
    ldx Text5               ; 4     (40)
    ora right_text,x        ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)
    
    ldx Text6               ; 4     (51)
    lda left_text,x         ; 4     (55)
    ldx Text7               ; 4     (59)
    ora right_text,x        ; 4     (63)
    
    ldy #$0F                ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)
    
    ;line 2
    sta WSYNC               ; 3     (0)

    ldx Text8               ; 4     (4)
    lda left_text,x         ; 4     (8)
    ldx Text9               ; 4     (12)
    ora right_text,x        ; 4     (16)
    sta Temp                ; 3     (19)

    ldx Text10              ; 4     (23*)
    lda left_text,x         ; 4     (27)
    ldx Text11              ; 4     (31)
    ora right_text,x        ; 4     (35)
    
    ldx Temp                ; 3     (38)
    VSLEEP;sleep 4
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx Text0               ; 3     (58)
    lda left_text+1,x       ; 4     (62)
    ldx Text1               ; 3     (65)
    ora right_text+1,x      ; 4     (69)

    ; Text line 2 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx Text2               ; 4     (13)
    lda left_text+1,x       ; 4     (17)
    ldx Text3               ; 4     (21)
    ora right_text+1,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)
    
    ldx Text4               ; 4     (32)
    lda left_text+1,x       ; 4     (36)
    ldx Text5               ; 4     (40)
    ora right_text+1,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)
    
    ldx Text6               ; 4     (51)
    lda left_text+1,x       ; 4     (55)
    ldx Text7               ; 4     (59)
    ora right_text+1,x      ; 4     (63)
    
    ldy #$0F                ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)
    
    ;line 2
    sta WSYNC               ; 3     (0)

    ldx Text8               ; 4     (4)
    lda left_text+1,x       ; 4     (8)
    ldx Text9               ; 4     (12)
    ora right_text+1,x      ; 4     (16)
    sta Temp                ; 3     (19)

    ldx Text10              ; 4     (23*)
    lda left_text+1,x       ; 4     (27)
    ldx Text11              ; 4     (31)
    ora right_text+1,x      ; 4     (35)
    
    ldx Temp                ; 3     (38)
    VSLEEP;sleep 4
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx Text0               ; 3     (58)
    lda left_text+2,x       ; 4     (62)
    ldx Text1               ; 3     (65)
    ora right_text+2,x      ; 4     (69)

    ; Text line 3 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx Text2               ; 4     (13)
    lda left_text+2,x       ; 4     (17)
    ldx Text3               ; 4     (21)
    ora right_text+2,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)
    
    ldx Text4               ; 4     (32)
    lda left_text+2,x       ; 4     (36)
    ldx Text5               ; 4     (40)
    ora right_text+2,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)
    
    ldx Text6               ; 4     (51)
    lda left_text+2,x       ; 4     (55)
    ldx Text7               ; 4     (59)
    ora right_text+2,x      ; 4     (63)
    
    ldy #$0F                ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)
    
    ;line 2
    sta WSYNC               ; 3     (0)

    ldx Text8               ; 4     (4)
    lda left_text+2,x       ; 4     (8)
    ldx Text9               ; 4     (12)
    ora right_text+2,x      ; 4     (16)
    sta Temp                ; 3     (19)

    ldx Text10              ; 4     (23*)
    lda left_text+2,x       ; 4     (27)
    ldx Text11              ; 4     (31)
    ora right_text+2,x      ; 4     (35)
    
    ldx Temp                ; 3     (38)
    VSLEEP; sleep 4
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx Text0               ; 3     (58)
    lda left_text+3,x       ; 4     (62)
    ldx Text1               ; 3     (65)
    ora right_text+3,x      ; 4     (69)

    ; Text line 4 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx Text2               ; 4     (13)
    lda left_text+3,x       ; 4     (17)
    ldx Text3               ; 4     (21)
    ora right_text+3,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)
    
    ldx Text4               ; 4     (32)
    lda left_text+3,x       ; 4     (36)
    ldx Text5               ; 4     (40)
    ora right_text+3,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)
    
    ldx Text6               ; 4     (51)
    lda left_text+3,x       ; 4     (55)
    ldx Text7               ; 4     (59)
    ora right_text+3,x      ; 4     (63)
    
    ldy #$0F                ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)
    
    ;line 2
    sta WSYNC               ; 3     (0)

    ldx Text8               ; 4     (4)
    lda left_text+3,x       ; 4     (8)
    ldx Text9               ; 4     (12)
    ora right_text+3,x      ; 4     (16)
    sta Temp                ; 3     (19)

    ldx Text10              ; 4     (23*)
    lda left_text+3,x       ; 4     (27)
    ldx Text11              ; 4     (31)
    ora right_text+3,x      ; 4     (35)
    
    ldx Temp                ; 3     (38)
    VSLEEP; sleep 4
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    ldy #0                  ; 2     (55)
    ldx Text0               ; 3     (58)
    lda left_text+4,x       ; 4     (62)
    ldx Text1               ; 3     (65)
    ora right_text+4,x      ; 4     (69)

    ; Text line 5 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty COLUP0              ; 3     (3)
    sty COLUP1              ; 3     (6)
    sta GRP0                ; 3     (9)

    ldx Text2               ; 4     (13)
    lda left_text+4,x       ; 4     (17)
    ldx Text3               ; 4     (21)
    ora right_text+4,x      ; 4     (25*)
    sleep 2
    sta GRP1                ; 3     (28)
    
    ldx Text4               ; 4     (32)
    lda left_text+4,x       ; 4     (36)
    ldx Text5               ; 4     (40)
    ora right_text+4,x      ; 4     (44)
    sleep 2
    sta GRP0                ; 3     (47)
    
    ldx Text6               ; 4     (51)
    lda left_text+4,x       ; 4     (55)
    ldx Text7               ; 4     (59)
    ora right_text+4,x      ; 4     (63)
    
    ldy #$0F                ; 2     (65)
    sty COLUP0              ; 3     (68)
    sty COLUP1              ; 3     (71)
    tay                     ; 2     (73)
    
    ;line 2
    sta WSYNC               ; 3     (0)

    ldx Text8               ; 4     (4)
    lda left_text+4,x       ; 4     (8)
    ldx Text9               ; 4     (12)
    ora right_text+4,x      ; 4     (16)
    sta Temp                ; 3     (19)

    ldx Text10              ; 4     (23*)
    lda left_text+4,x       ; 4     (27)
    ldx Text11              ; 4     (31)
    ora right_text+4,x      ; 4     (35)
    
    ldx Temp                ; 3     (38)
    VSLEEP; sleep 4
    sty GRP1                ; 3     (41)
    stx GRP0                ; 3     (44)
    sta GRP1                ; 3     (47)
    sleep 3                 ; 3     (50)
    sta GRP0                ; 3     (53)

    sta WSYNC
    lda #0
    sta GRP0
    sta GRP1
    sta GRP0
    
FinishVS
    sleep 13
    lda #0
    sta GRP1
    sta GRP0
    sta GRP1
    
    lda TextLoop
    bne .end
    jmp TextDisplayLoop
    
.end
    lda #0
    sta VDELP0
    sta VDELP1
    sta GRP0
    sta GRP1
    sta GRP0
    
    lda #COLOR_PLAYER_00
    sta COLUP0
    jsr PosWorldObjects
    
.waitTimerLoop
    lda INTIM
    bne .waitTimerLoop
    ldy TEXT_ROOM_HEIGHT
    sta WSYNC ; 95
    
    jmp KERNEL_WORLD_RESUME

SetHorizPos: SUBROUTINE
    sta WSYNC   ; start a new line
    bit 0       ; waste 3 cycles
    sec     ; set carry flag
.DivideLoop
    sbc #15     ; subtract 15
    bcs .DivideLoop  ; branch until negative
    eor #7      ; calculate fine offset
    asl
    asl
    asl
    asl
    sta RESP0,x ; fix coarse position
    sta HMP0,x  ; set fine offset
    rts     ; return to caller
 
    LOG_SIZE "-BANK 3- Text Bank", BANK_3

; ****************************************
; *               BANK 4                 *
; ****************************************

    SEG Bank4
    ORG $2000
    RORG $F000
BANK_4
    INCLUDE "gen/EnemyAI.asm"
    INCLUDE "gen/RoomScript.asm"
NextDir: SUBROUTINE
    jsr Random
    and #3
    tax
.nextLoop
    lda enBlockDir
    and Lazy8,x
    beq .end
    inx
    bpl .nextLoop
.end
    txa
    and #3
    sta enDir
    rts
NoAI:
    lda #$F0
    sta enSpr+1
    sta enY
RsNone:
RsWorldMidEnt:
RsStairs:
RsRaftSpot:
RsNeedTriforce:
RsFairyFountain:
    rts
    
RsItem: SUBROUTINE
    lda roomENCount
    bne .rts
    ldx roomId
    ldy worldBank
    lda BANK_RAM + 1,y
    lda rRoomFlag,x
    bmi .rts
    ora #$80
    sta wRoomFlag,x
    inc itemKeys
    
.rts
    lda BANK_RAM + 0
    rts
    
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
    lda #$10
    sta plY
    lda roomId
    sta worldSR
    lda #01
    sta worldId
    lda roomFlags
    ora #$80
    sta roomFlags
    lda #$73;lda roomEX
    sta roomId
    lda #MS_PLAY_DUNG
    sta SeqFlags
.rts
    rts
    
RsDungExit: SUBROUTINE
    bit roomFlags
    bmi .rts
    lda plY
    cmp #BoardYD
    bne .rts
    lda worldSX
    sta plX
    lda worldSY
    sta plY
    lda worldSR
    sta roomId
    lda #0
    sta worldId
    lda roomFlags
    ora #$80
    sta roomFlags
    lda #MS_PLAY_THEME
    sta SeqFlags
.rts
    rts

TriforceAI: SUBROUTINE
    lda #>SprItem6
    sta enSpr+1
    lda #<SprItem6
    sta enSpr
    lda #$4C
    sta enX
    lda #$2C
    sta enY
    lda Frame
    and #$10
    bne .TriforceBlue

    lda #COLOR_TRIFORCE
    .byte $2C
.TriforceBlue
    lda #COLOR_LIGHT_BLUE
    sta enColor
    rts


SpectacleOpenAI: SUBROUTINE

    ldy #$6
    lda rPF2Room,y
    and #$F9
    sta wPF2Room,y
    sta wPF2Room+1,y
    lda #$58
    sta enX
    lda #$20
    sta enY
    lda fgColor
    sta enColor
    lda #(30*8)
    sta enSpr
    rts

BlockStairAI: SUBROUTINE
; diamond room
    ldy #$D
    lda rPF2Room,y
    and #$7F
    sta wPF2Room,y
    sta wPF2Room+1,y
    lda #$40
    sta enX
    lda #$3C
    sta enY
    lda fgColor
    sta enColor
    lda #(30*8)
    sta enSpr
    rts

StairAI: SUBROUTINE
    lda #$40
    sta enX
    lda #$2C
    sta enY
    lda fgColor
    sta enColor
    lda #<SprItem7
    sta enSpr
    lda #>SprItem7
    sta enSpr+1

    lda enX
    cmp plX
    bne .playerNotOnStairs
    lda enY
    cmp plY
    bne .playerNotOnStairs
    lda #01
    sta worldId
    lda #$73
    sta roomId
    lda #0
    sta enType
    lda roomFlags
    ora #$80
    sta roomFlags

.playerNotOnStairs
    rts

DarknutAI: SUBROUTINE
    lda #>SprE0
    sta enSpr+1
; update stun/recoil timers
    lda enRecoil
    cmp #1
    adc #0
    sta enRecoil
    lda enStun
    cmp #1
    adc #0
    sta enStun
    asl
    asl
    adc #COLOR_DARKNUT_RED
    sta enColor

.setBlockedDir
    lda enBlockDir
    and #$F0
    ldx enX
    cpx #EnBoardXR
    bne .setBlockedL
    ora #1
.setBlockedL
    cpx #EnBoardXL
    bne .setBlockedD
    ora #2
.setBlockedD
    ldx enY
    cpx #EnBoardYD
    bne .setBlockedU
    ora #4
.setBlockedU
    cpx #EnBoardYU
    bne .setBlockedEnd
    ora #8
.setBlockedEnd
    sta enBlockDir

.checkPFHit
    lda enRecoil
    bne .endCheckPFHit
    lda CXP1FB
    bpl .endCheckPFHit
    ; set blocked dir
    ldx enDir
    lda enBlockDir
    ora Bit8,x
    sta enBlockDir
.endCheckPFHit

.checkHit
; if collided with weapon && stun == 0,
    lda CXM0P
    bpl .endCheckHit
    lda enStun
    bne .endCheckHit
    lda #-32
    sta enStun
    lda #-16
    sta enRecoil
.endCheckHit

.checkBlocked
    lda enBlockDir
    ldx enDir
    and Lazy8,x
    beq .endCheckBlocked
    jsr NextDir
    jmp .move
.endCheckBlocked

.randDir
    lda enX
    and #3
    bne .move
    lda enY
    and #3
    bne .move
    lda Frame
    eor enBlockDir
    and #$20
    beq .move
    eor enBlockDir
    sta enBlockDir
    jsr NextDir

.move

    ldx enDir
    ldy Mul8,x
    sty enSpr

    lda Frame
    and #1
    beq .return
    txa

    cmp #0
    beq EnMoveRight
    cmp #1
    beq EnMoveLeft
    cmp #2
    beq EnMoveDown
    cmp #3
    beq EnMoveUp
.return
    rts


EnMoveRight: SUBROUTINE
    inc enX
    rts

EnMoveLeft: SUBROUTINE
    dec enX
    rts

EnMoveDown: SUBROUTINE
    dec enY
    rts

EnMoveUp: SUBROUTINE
    inc enY
    rts

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
    align 16
    INCLUDE "gen/ms_header.asm"
    INCLUDE "gen/MusicSeq.asm"
    INCLUDE "gen/Sfx.asm"

UpdateAudio: SUBROUTINE
    lda SeqFlags
    bpl .continueSequence
    and #$7F
    sta SeqFlags
    lda #$FF
    ldx Frame
    sta SeqCur
    sta SeqCur + 1
    stx SeqTFrame
    stx SeqTFrame + 1
.continueSequence
    ldx #0
    jsr AudioChannel
    ldx #1
    jsr AudioChannel

    lda SfxFlags
    and #$3F
    beq .sfxEnd
    bit SfxFlags
    bpl .skipResetSfx
    ldy #$FF
    sty SfxCur
.skipResetSfx
    tax
    jsr SfxDel
.sfxEnd
    ldy #5
    
.set_audio_loop
    lda AUDCT0,y
    sta AUDC0,y
    dey
    bpl .set_audio_loop
    rts
    
SfxStabPattern:
    .byte $01, $02, $03, $02, $01
    
SfxStab: SUBROUTINE
    ldx #8
    stx AUDVT1
    stx AUDCT1
    ldy SfxCur
    lda SfxStabPattern,y
    sta AUDFT1
    cpy #4
    bpl SfxStop
    rts
    
SfxStop:
    lda #0
    sta SfxFlags
    rts
    
SfxBomb: SUBROUTINE
    lda SfxCur
    cmp #16
    bpl SfxStop
    asl
    sta AUDFT1
    lda #8
    sta AUDVT1
    sta AUDCT1
    rts
    
SfxItemPickup: SUBROUTINE
    lda SfxCur
    cmp #4
    bpl SfxStop
    lda #4
    sta AUDCT1
    ldx #8
    stx AUDVT1
    inx
    stx AUDFT1
    rts
    
SfxDel:
    stx SfxFlags
    inc SfxCur
    lda SfxH-1,x
    pha
    lda SfxL-1,x
    pha
    rts
    
; x = channel
AudioChannel: SUBROUTINE
    lda Mul8,x
    ora SeqFlags
    and #$0F  
    sta Temp0 ; SeqId
    
    ; Test if next note should be played
    clv
    ldy SeqTFrame,x
    cpy Frame
    bne .skipUpdateCur
    ; Played note has changed
    inc SeqCur,x
    bit .OverflowOn
    ldy Temp0
    lda ms_header,y ; duration
.OverflowOn
    cmp SeqCur,x
    bne .skipUpdateCur
    lda #0
    sta SeqCur,x
.skipUpdateCur
    ldx Temp0
    lda MusicSeqH,x
    pha
    lda MusicSeqL,x
    pha
    rts
    
MsNone: SUBROUTINE
    lda #0
    sta AUDVT0
    sta AUDVT1
    rts
    
MsDung0: SUBROUTINE
    ldx SeqCur
    bvc .skipSetDur
    lda ms_dung0_dur,x
    clc
    adc Frame
    sta SeqTFrame
.skipSetDur
    lda ms_dung0_note,x
; A = Packed Note
SeqChan0:
    ldy #0
    beq SeqChan
    
SeqChan1:
    ldy #1
SeqChan:
    pha
    lsr
    lsr
    lsr
    sta AUDFT0,y
    pla
    and #7
    tax
    lda ToneLookup,x
    sta AUDCT0,y
    lda #2
    sta AUDVT0,y
    rts

MsDung1: SUBROUTINE
    ldx SeqCur + 1
    bvc .skipSetDir
    lda #$0A ;ms_dung1_dur,x
    clc
    adc Frame
    sta SeqTFrame + 1
.skipSetDir
    lda ms_dung1_note,x
    jmp SeqChan1
    
MsGI0: SUBROUTINE
    ldx SeqCur
    bvc .skipSetDur
    lda ms_gi0_dur,x
    clc
    adc Frame
    sta SeqTFrame
.skipSetDur
    lda ms_gi0_note,x
    jmp SeqChan0
    
MsGI1: SUBROUTINE
    ldx SeqCur + 1
    bvc .skipSetDur
    lda ms_gi1_dur,x
    clc
    adc Frame
    sta SeqTFrame + 1
.skipSetDur
    lda ms_gi1_note,x
    jmp SeqChan1
    
MsOver0: SUBROUTINE
    ldx SeqCur
    bvc .skipSetDur
    lda ms_over0_dur,x
    clc
    adc Frame
    sta SeqTFrame
.skipSetDur
    lda ms_over0_note,x
    jmp SeqChan0
    
MsOver1: SUBROUTINE
    ldx SeqCur + 1
    bvc .skipSetDur
    lda ms_over1_dur,x
    clc
    adc Frame
    sta SeqTFrame + 1
.skipSetDur
    lda ms_over1_note,x
    jmp SeqChan1
    
    ;align 8
ToneLookup
    .byte 0, 1, 4, 6, 12
    LOG_SIZE "-BANK 5- Audio", BANK_5

    SEG Bank6
    ORG $3000
    RORG $F000


; ****************************************
; *               BANK 6                 *
; ****************************************

BANK_6
LoadRoom_B6: SUBROUTINE
; set OR mask for the room top/bottom
    lda worldId
    beq .WorldRoomOrTop
    lda #$FF
    .byte $2C
.WorldRoomOrTop
    lda #$00
    
    sta Temp6
    ldy #1
.roomUpDownBorder
    lda rPF1RoomL+2
    ora Temp6
    sta wPF1RoomL,y
    
    lda rPF2Room+2
    ora Temp6
    sta wPF2Room,y
    
    lda rPF1RoomR+2
    ora Temp6
    sta wPF1RoomR,y
    
    lda rPF1RoomL+ROOM_PX_HEIGHT-3
    ora Temp6
    sta wPF1RoomL+ROOM_PX_HEIGHT-2,y
    
    lda rPF1RoomR+ROOM_PX_HEIGHT-3
    ora Temp6
    sta wPF1RoomR+ROOM_PX_HEIGHT-2,y
    
    lda rPF2Room+ROOM_PX_HEIGHT-3
    ora Temp6
    sta wPF2Room+ROOM_PX_HEIGHT-2,y
    dey
    bpl .roomUpDownBorder
    lda worldId
    beq UpdateWorldDoors
    rts
    
UpdateWorldDoors: SUBROUTINE
    lda roomDoors
    and #3
    tax
    ldy #1
.Up
    lda WorldDoorPF2,x
    ora rPF2Room+ROOM_PX_HEIGHT-2,y
    sta wPF2Room+ROOM_PX_HEIGHT-2,y
    lda WorldDoorPF1Up,x
    ora rPF1RoomL+ROOM_PX_HEIGHT-2,y
    sta wPF1RoomL+ROOM_PX_HEIGHT-2,y
    lda WorldDoorPF1Up,x
    ora rPF1RoomR+ROOM_PX_HEIGHT-2,y
    sta wPF1RoomR+ROOM_PX_HEIGHT-2,y
    dey
    bpl .Up
    
    lda roomDoors
    lsr
    lsr
    pha
    and #3
    tax
    ldy #1
.Down
    lda WorldDoorPF2,x
    ora rPF2Room,y
    sta wPF2Room,y
    lda WorldDoorPF1Up,x
    ora rPF1RoomL,y
    sta wPF1RoomL,y
    lda WorldDoorPF1Up,x
    ora rPF1RoomR,y
    sta wPF1RoomR,y
    dey
    bpl .Down

.LeftRight
    pla
    lsr
    lsr
    tay
    and #3
    tax
    lda WorldDoorPF1A,x
    sta Temp1
    lda WorldDoorPF1B,x
    sta Temp3
    tya
    lsr
    lsr
    and #3
    tax
    lda WorldDoorPF1A,x
    sta Temp0
    lda WorldDoorPF1B,x
    sta Temp2
    
    ldy #5
.LeftRightWorldDoor
    lda rPF1RoomL+2,y
    ora Temp0
    sta wPF1RoomL+2,y
    
    lda rPF1RoomL+12,y
    ora Temp0
    sta wPF1RoomL+12,y
    
    lda rPF1RoomR+2,y
    ora Temp1
    sta wPF1RoomR+2,y
    
    lda rPF1RoomR+12,y
    ora Temp1
    sta wPF1RoomR+12,y
    dey
    bpl .LeftRightWorldDoor
    
    ldy #3
.LeftRightWorldDoor2
    lda rPF1RoomL+8,y
    ora Temp2
    sta wPF1RoomL+8,y
    
    lda rPF1RoomR+8,y
    ora Temp3
    sta wPF1RoomR+8,y
    dey
    bpl .LeftRightWorldDoor2
rts_UpdateDoors:
    rts
    
UpdateDoors_B6: SUBROUTINE
    lda worldId
    beq rts_UpdateDoors
    ldy #$3F
    ldx #$FF
    lda roomDoors

    lsr
    sty wPF2Room+ROOM_PX_HEIGHT-2
    bcc .skipDown0
    stx wPF2Room+ROOM_PX_HEIGHT-2

.skipDown0
    lsr
    sty wPF2Room+ROOM_PX_HEIGHT-1
    bcc .skipDown1
    stx wPF2Room+ROOM_PX_HEIGHT-1

.skipDown1
    lsr
    sty wPF2Room+1
    bcc .skipUp0
    stx wPF2Room+1

.skipUp0
    lsr
    sty wPF2Room+0
    bcc .skipUp1
    stx wPF2Room+0

.skipUp1
    lda roomDoors
    and #$C0
    sta Temp0
    lda roomDoors
    asl
    asl
    and #$C0
    sta Temp1

    ldy #3
.lrLoop
    lda rPF1RoomL+(ROOM_PX_HEIGHT/2)-2,y
    and #$3F
    ora Temp0
    sta wPF1RoomL+(ROOM_PX_HEIGHT/2)-2,y
    lda rPF1RoomR+(ROOM_PX_HEIGHT/2)-2,y
    and #$3F
    ora Temp1
    sta wPF1RoomR+(ROOM_PX_HEIGHT/2)-2,y
    dey
    bpl .lrLoop
    rts
   
KeydoorCheck_B6: SUBROUTINE
    lda worldId
    beq .rts1
    lda itemKeys
    beq .rts1
    
; Up/Down check    
    lda plX
    sec
    sbc #BoardKeydoorUDA
    ; continue if positive
    bmi .LRCheck
    sbc #$8+1
    bpl .LRCheck
    
    ldx #0
    lda plY
    cmp #BoardKeydoorUY
    beq .UnlockUp
    cmp #BoardKeydoorDY
    beq .UnlockDown
    
.LRCheck
    lda plY
    sec
    sbc #BoardKeydoorLRA
    bmi .rts1
    sbc #$8+1
    bpl .rts1
    
    ldx #2
    lda plX
    cmp #BoardKeydoorRX
    beq .UnlockRight
    cmp #BoardKeydoorLX
    beq .UnlockLeft
.rts1
    rts
.UnlockUp
.UnlockLeft
    inx
.UnlockDown
.UnlockRight
    lda roomDoors
    eor #%01010101
    and KeydoorMask,x
    bne .rts1
    lda KeydoorMask,x
    eor #$FF
    and roomDoors
    sta roomDoors
    dec itemKeys
    lda #SFX_STAB
    sta SfxFlags
    ; x = door dir, S/N/E/W
    
    ; load world bank (RAM)
    ldy worldBank
    lda BANK_RAM + 1,y
    
    ldy roomId
    lda KeydoorFlagA,x
    ora rRoomFlag,y
    sta wRoomFlag,y
    tya
    clc
    adc KeydoorRoomOff,x
    tay
    lda KeydoorFlagB,x
    ora rRoomFlag,y
    sta wRoomFlag,y
    lda BANK_RAM + 0
    rts

PlayerItem_B6: SUBROUTINE
; Sword
    bit plState
    bvc .skipSetItemTimer
; If Item Button, stab sword
    lda #ItemTimerSword
    sta plItemTimer
; Sfx
    lda #SFX_STAB
    sta SfxFlags
.skipSetItemTimer
    ldy plItemTimer
    bne .drawSword
    lda #$80
    sta m0Y
    bmi .endSword

.drawSword
    lda #0
    cpy #-7
    bmi .endSword
    cpy #-1
    beq .drawSword4
    lda #4
.drawSword4
    clc
    adc plDir
    tay
    lda SwordWidth4,y
    sta NUSIZ0_T
    lda SwordHeight4,y
    sta m0H
    lda SwordOff4X,y
    clc
    adc plX
    sta m0X
    lda SwordOff4Y,y
    clc
    adc plY
    sta m0Y
.endSword
    rts
 
Encounters:
    align 256
    .byte $00
    align 256
    .byte $00
    align 256
    .byte $00
    
    align 4
KeydoorMask:
    ; S/N/E/W
    .byte $0C, $03, $30, $C0
KeydoorFlagA:
    .byte $04, $01, $10, $40
KeydoorFlagB:
    .byte $01, $04, $40, $10
KeydoorRoomOff:
    .byte $10, $F0, $01, $FF
   
    align 4
WorldDoorPF1Up:
    .byte $C0, $C0, $FF, $FF
    
WorldDoorPF1A:
    .byte $00, $00, $C0, $C0
    
WorldDoorPF1B:
    .byte $00, $C0, $00, $C0
    
WorldDoorPF2:
    .byte $00, $FF, $3F, $FF

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
    
INIT:

    ; set player colors
    lda #COLOR_PLAYER_00
    sta COLUP0

    ; set bgColor
    lda #COLOR_PATH
    sta bgColor

    ; set playfield
    lda #COLOR_GREEN_ROCK
    sta fgColor
    
    lda #%00110001 ; ball size 8, reflect playfield
    sta CTRLPF
    
    ; seed RNG
    lda #$2C
    sta Rand8
    lda #$20
    ldx #10-1
INIT_POS:
    sta plX,x
    dex
    bpl INIT_POS
    
    ; set ball
    lda #$60
    sta blX
    sta blY
    
    ; set player stats
    lda #$80
    sta plHealth
    sta plHealthMax
    
    ;lda #$83
    ;sta SeqFlags
    
    lda #$77
    sta roomId
    jsr LoadRoom


;TOP_FRAME ;3 37 192 30
VERTICAL_SYNC: ; 3 SCANLINES
    lda #2
    ldx #49
    sta WSYNC
    sta VSYNC
    stx TIM64T ; 41 scanline timer
    inc Frame
    sta WSYNC
    sta WSYNC
    lda #0      ; LoaD Accumulator with 0 so D1=0
    ;sta PF0     ; blank the playfield
    sta PF1
    sta PF2
    ;sta GRP0    ; blanks player0 if VDELP0 was off
    ;sta GRP1    ; blanks player0 if VDELP0 was on, player1 if VDELP1 was off
    ;sta GRP0    ; blanks                           player1 if VDELP1 was on
    sta WSYNC
    sta VSYNC

VERTICAL_BLANK: SUBROUTINE ; 37 SCANLINES
    lda #0
    sta VDELP0
    sta VDELP1
    
    lda roomFlags
    and #$BF
    sta roomFlags
    bpl .skipLoadRoom
    ora #$40
    sta roomFlags
    jsr LoadRoom
    lda #0
    sta enType
    sta KernelId
.skipLoadRoom

    bit roomFlags
    bvs .roomLoadCpuSkip
    jsr ProcessInput
    jsr Random
    lda BANK_ROM + 6
    jsr PlayerItem_B6
.roomLoadCpuSkip

; room setup
    lda BANK_ROM + 6
    jsr KeydoorCheck_B6
    jsr UpdateDoors_B6
    lda BANK_ROM + 5
    jsr UpdateAudio
    jsr EnemyAIDel
    
;===============================================================================
; Pre-Position Sprites
;===============================================================================

; room draw start
    ldy KernelId
    lda RoomWorldOff,y
    sta roomSpr
    
; player draw height
    lda Spr8WorldOff,y;#(ROOM_HEIGHT+8)
    sec
    sbc plY
    sta plDY

; player sword draw height
    lda Spr8WorldOff,y;#(ROOM_HEIGHT+8)
    sec
    sbc m0Y
    sta m0DY

.player_sprite_setup
    lda #<(SprP0 + 7) ; Sprite + height-1
    clc
    ldx plDir
    adc Mul8,x
    sec ; set Carry
    sbc plY
    sta plSpr

    lda #>(SprP0 + 7)
    sbc #0
    sta plSpr+1

; enemy draw height
    lda Spr8WorldOff,y;#(ROOM_HEIGHT+8)
    sec
    sbc enY
    sta enDY

.enemy_sprite_setup
    lda enSpr; #<(SprE0 + 7)
    clc
    adc #7;enSpr
    sec
    sbc enY
    sta enSpr

    lda enSpr + 1;#>(SprE0 + 7)
    sbc #0
    sta enSpr + 1
    
.ball_sprite_setup
    lda #7
    sta blH
; ball draw height
    lda Spr1WorldOff,y;#(ROOM_HEIGHT+1)
    sec
    sbc blY
    sta blDY
    
.minimap_setup
; sprite setup
    lda #<(MINIMAP) ; Sprite + height-1
    clc
    ldx worldId
    adc Mul8,x
    sta mapSpr
    lda #>(MINIMAP)
    sta mapSpr+1
; double width map if on overworld
    ldx #5
    bit worldId
    beq .minimap_16
    ldx #$00
.minimap_16
    stx NUSIZ1 ; double minimap size if world 0
    lda #0
    sta COLUBK
    sta NUSIZ0 ; clean sword from previous frame
    
    lda BANK_ROM + 0
.hud_sprite_setup
; rupee display
    lda itemRupees
    and #$0F
    asl
    asl
    asl
    clc
    adc #7
    sta THudDigits+5
    lda itemRupees
    and #$F0
    lsr
    clc
    adc #7
    sta THudDigits+4
; key display
    ldx itemKeys
    bmi .hud_all_keys
    cpx #9
    bmi .hud_key_digit
    ldx #9
    .byte $2C
.hud_all_keys
    ldx #10
.hud_key_digit
    lda Mul8,x
    clc
    adc #7
    sta THudDigits+3
    lda #<SprN10 - #<SprN0 +7
    sta THudDigits+2
; bomb display    
    lda itemBombs
    cmp #10
    bpl .hud_bomb_digit
    lda #<SprN11 - #<SprN0 +7
    .byte $2C
.hud_bomb_digit
    lda #<SprN1+7
    sta THudDigits+0 
    lda itemBombs
    and #$0F
    asl
    asl
    asl
    clc
    adc #7
    sta THudDigits+1

    jsr PosHudObjects
    
; ===================================================    
;    Pre HUD
; ===================================================
    lda roomId
    lsr
    lsr
    lsr
    lsr
    eor #$7
    and #$7
    sta TMapPosY
    lda plHealth
    clc
    adc #7
    lsr
    lsr
    lsr
    sta THudHealthL
    sec
    sbc #8
    bcs .skipHealthHighClampMin
    lda #0
.skipHealthHighClampMin
    tax
    lda HealthPattern,x
    sta THudHealthH
    beq .skipHealthClamp
    lda #8
    sta THudHealthL
.skipHealthClamp
    ldx THudHealthL
    lda HealthPattern,x
    sta THudHealthL
    lda #0
    
    lda #COLOR_MINIMAP
    sta COLUP1
    lda #COLOR_PLAYER_02
    sta COLUPF

; ===================================================
; Kernel Main
; ===================================================
KERNEL_MAIN: SUBROUTINE ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN
    sta VBLANK

KERNEL_HUD: SUBROUTINE
    ldy #7
    lda #0
    sta WSYNC
    beq .loop
;=========== Scanline 1A ==============
.hudScanline1A
    sta WSYNC
    lda #0
    sta GRP0
    sta PF1
    ldx #3
.hudShiftDigitLoop
    lda THudDigits,x
    sta THudDigits+2,x
    dex
    bpl .hudShiftDigitLoop
    lda THudHealthL
    sta THudHealthH
    dey
    lda #0
    sta THudHealthL
    nop ;sta WSYNC
KERNEL_HUD_LOOP:
.loop:

;=========== Scanline 0 ==============
    cpy TMapPosY ; 3
    bne .skip ; 2/3
    lda #2    ; 2
.skip
    sta ENAM0 ; 3
    lda (mapSpr),y ; 5
    sta GRP1 ; 3
    
    ldx THudDigits+4 ; 3
    lda SprN0,x  ; 4
    and #$F0     ; 2
    sta THudTemp    ; 3 
    ldx THudDigits+5; 3
    lda SprN0,x ; 4
    and #$0F  ; 2
    ora THudTemp ; 3
    sta GRP0 ; 3
    lda THudHealthH
    sta PF1
    cpy #5
    beq .hudScanline1A
    cpy #2
    beq .hudScanline1A
    lda #0
    sta WSYNC
    sta PF1
;=========== Scanline 1 ==============
    dec THudDigits+4 ; 5
    dec THudDigits+5 ; 5
    
    ldx THudDigits+4 ; 3
    lda SprN0,x  ; 4
    and #$F0     ; 2
    sta THudTemp    ; 3 
    ldx THudDigits+5; 3
    lda SprN0,x ; 4
    and #$0F  ; 2
    ora THudTemp ; 3
    sta GRP0 ; 3
    lda THudHealthH
    sta PF1
    dec THudDigits+4
    dec THudDigits+5
    lda #0
    dey
    sta WSYNC
    sta PF1
;=========== Scanline 0 ==============
    bpl .loop
; HUD LOOP End
    lda #85;#76 
    sta TIM8T ; Delay 8 scanlines
    lda #0
    sta ENAM0
    sta GRP1
    
    ldx THudDigits+4 ; 3
    lda SprN0,x  ; 4
    and #$F0     ; 2
    sta THudTemp    ; 3 
    ldx THudDigits+5; 3
    lda SprN0,x ; 4
    and #$0F  ; 2
    ora THudTemp ; 3
    sta GRP0 ; 3
    
    lda fgColor
    sta COLUPF
    
    ldx #0
    stx GRP0
    stx GRP1
    LOG_SIZE "-HUD KERNEL-", KERNEL_HUD
    lda KernelId
    beq .defaultWorldKernel
    lda BANK_ROM + 3
    jmp TextKernel
    
.defaultWorldKernel
; HMOVE setup
    jsr PosWorldObjects

.waitTimerLoop
    lda INTIM
    bne .waitTimerLoop
    sta WSYNC
    
    ldy #ROOM_HEIGHT
KERNEL_WORLD_RESUME:
    
    lda BANK_ROM + 0
    lda #$FF
    sta PF0
    sta PF1
    sta PF2

    lda bgColor
    sta COLUBK
    lda fgColor
    sta COLUPF
    lda enColor
    sta COLUP1
    
    lda #1
    ldx #0
    sta VDELP1
    stx NUSIZ1
    lda NUSIZ0_T
    sta NUSIZ0
    
    lda #0
    ldx #0
    sta WSYNC
    sta CXCLR
    LOG_SIZE "-KERNEL HUD-", KERNEL_HUD

KERNEL_LOOP: SUBROUTINE ; 76 cycles per scanline
    sta ENAM0       ; 3
    stx GRP0        ; 3

    ldx roomSpr     ; 3
    lda rPF1RoomL,x ; 4
    sta PF1         ; 3
    lda rPF2Room,x  ; 4
    sta PF2         ; 3

; Enemy
    lda #7          ; 2     enemy height
    dcp enDY        ; 5
    bcs .DrawE0     ; 2/3
    lda #0          ; 2
    .byte $2C       ; 4-5   BIT compare hack to skip 2 byte op
.DrawE0:
    lda (enSpr),y   ; 5
    sta GRP1        ; 3
    lda rPF1RoomR,x ; 4
    sta PF1         ; 3
    
; Ball
    lda blH         ; 3 ball height
    dcp blDY        ; 5
    lda #1          ; 2
    adc #0          ; 2
    sta WSYNC       ; 3  34-35 cycles, not counting WSYNC (can save cycle by fixing bcs)
    sta ENABL

    ldx roomSpr     ; 3
    lda rPF1RoomL,x ; 4
    sta PF1         ; 3

; Player
    lda #7          ; 2 player height
    dcp plDY        ; 5
    bcs .DrawP0     ; 2/3
    lda #0          ; 2
    .byte $2C       ; 4-5 BIT compare hack to skip 2 byte op
.DrawP0:
    lda (plSpr),y   ; 5
    pha
    ldx roomSpr     ; 3
    lda rPF1RoomR,x ; 4
    sta PF1         ; 3
    pla
    tax             ; 2

; Playfield
    tya             ; 2
    and #3          ; 2
    beq .skipPFDec  ; 2/3
    .byte $2C       ; 4-5
.skipPFDec
    dec roomSpr     ; 5

; Player Missle
    lda m0H         ; 3 player height
    dcp m0DY        ; 5
    lda #1          ; 2
    adc #0          ; 2

    sta WSYNC
    dey
    bpl KERNEL_LOOP
    lda fgColor
    sta COLUBK
    lda #0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1
    sta ENAM0
    sta PF0
    LOG_SIZE "-KERNEL WORLD-", KERNEL_LOOP

OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer
    
; test player board bounds
    ldy roomId
    lda plX
    cmp #BoardXR+1
    bne .plXRSkip
    ldx #BoardXL
    stx plX
    inc roomId
.plXRSkip
    cmp #BoardXL-1
    bne .plXLSkip
    ldx #BoardXR
    stx plX
    dec roomId
.plXLSkip
    lda plY
    cmp #BoardYU+1
    bne .plYUSkip
    ldx #BoardYD
    stx plY
    clc
    lda roomId
    adc #$F0
    sta roomId
    lda plY
.plYUSkip
    cmp #BoardYD-1
    bne .plYDSkip
    ldx #BoardYU
    stx plY
    clc
    lda roomId
    adc #$10
    sta roomId
.plYDSkip

    cpy roomId
    beq .skipSwapRoom
    lda #$80
    ora roomFlags
    sta roomFlags
.skipSwapRoom
    bit roomFlags
    bmi .skipCollisionPosReset
    ldx #1
.posResetLoop
    lda CXP0FB,x
    jsr TestCollisionReset
    dex
    bpl .posResetLoop
.skipCollisionPosReset
   
.RoomScript:   
    jsr RoomScriptDel

OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne OVERSCAN_WAIT

    jmp VERTICAL_SYNC


;===============================================================================
; CollisionReset
;----------
; N = reset collision
; x = Player (0), Enemy (1)
;===============================================================================
TestCollisionReset:
    bpl .SkipPFCollision
    lda plXL,x
    sta plX,x
    lda plYL,x
    sta plY,x
.SkipPFCollision:
    lda plX,x
    sta plXL,x
    lda plY,x
    sta plYL,x
    rts

ProcessInput: SUBROUTINE
    ; test if player locked
    lda #02
    bit plState
    beq .InputContinue
    rts
.InputContinue
    lda plState
    and #$BF
    sta plState
    bpl .FireNotHit
    lda INPT4
    bmi .FireNotHit
    lda plItemTimer
    bne .FireNotHit
    lda plState
    ora #$40
    sta plState
.FireNotHit
    lda plState
    and #$7F
    bit INPT4
    bpl .skipLastFire
    ora #$80
.skipLastFire
    sta plState

    lda plItemTimer
    cmp #1
    adc #0
    sta plItemTimer

    bmi .skipItemInput

.skipItemInput
    lda SWCHA
    and #$F0

ContRight:
    asl
    bcs ContLeft
    lda plY
    and #(GRID_STEP - 1)
    beq MovePlayerRight
    and #(GRID_STEP / 2)
    beq MovePlayerDown
    jmp MovePlayerUp

MovePlayerRight:
    lda plState
    lsr
    bcc .MovePlayerRightFr
    lda #2
    bit plDir
    bne .rts
.MovePlayerRightFr
    lda #$00
    sta plDir
    inc plX
.rts
    rts ;jmp ContFin

ContLeft:
    asl
    bcs ContDown
    lda plY
    and #(GRID_STEP - 1)
    beq MovePlayerLeft
    and #(GRID_STEP / 2)
    beq MovePlayerDown
    jmp MovePlayerUp

MovePlayerLeft:
    lda plState
    lsr
    bcc .MovePlayerLeftFr
    lda #2
    bit plDir
    bne .rts
.MovePlayerLeftFr
    lda #$01
    sta plDir
    dec plX
    rts ;jmp ContFin

ContDown:
    asl
    bcs ContUp
    lda plX
    and #(GRID_STEP - 1)
    beq MovePlayerDown
    and #(GRID_STEP / 2)
    beq MovePlayerLeft
    jmp MovePlayerRight

MovePlayerDown:
    lda plState
    lsr
    bcc .MovePlayerDownFr
    lda #2
    bit plDir
    beq .rts
.MovePlayerDownFr
    lda #$2
    sta plDir
    dec plY
    rts ;jmp ContFin

ContUp:
    asl
    bcs ContFin
    lda plX
    and #(GRID_STEP - 1)
    beq MovePlayerUp
    and #(GRID_STEP / 2)
    beq MovePlayerLeft
    jmp MovePlayerRight

MovePlayerUp:
    lda plState
    lsr
    bcc .MovePlayerUpFr
    lda #2
    bit plDir
    beq .rts
.MovePlayerUpFr
    lda #$3
    sta plDir
    inc plY

ContFin:
    rts
    LOG_SIZE "Input", ProcessInput

LoadRoom: SUBROUTINE
    ; flush loadroom flag
    lda roomFlags
    and #$7F
    sta roomFlags

    ; load world bank
    ldy worldId
    beq .worldBankSet
    ldy #1
.worldBankSet
    sty worldBank
    lda BANK_ROM + 1,y

    ldy roomId
    lda WORLD_RS,y
    sta roomRS
    lda WORLD_EX,y
    sta roomEX
    lda WORLD_EN,y
    sta roomEN
    lda WORLD_WA,y
    sta roomWA
    
    ; set fg/bg color
    lda WORLD_COLOR,y
    and #$0F
    tax
    lda WorldColors,x
    sta fgColor
    lda WORLD_COLOR,y
    lsr
    lsr
    lsr
    lsr
    tax
    lda WorldColors,x
    sta bgColor
    
    ; PF1 Right
    lda WORLD_T_PF1R,y
    tax
    and #$F0
    sta Temp4
    txa
    and #$01
    clc
    adc #$F0
    sta Temp5
    txa
    and #$0E
    asl
    asl
    asl
    asl
    sta roomDoors
    
    ; PF1 Left
    lda WORLD_T_PF1L,y
    tax
    and #$F0
    sta Temp0
    txa
    and #$01
    clc
    adc #$F0
    sta Temp1
    txa
    and #$0E
    lsr
    ora roomDoors
    sta roomDoors
    
    ; PF2
    lda WORLD_T_PF2,y
    tax
    and #$F0
    sta Temp2
    txa
    and #$03
    clc
    adc #$F0
    sta Temp3
    txa
    and #$0C
    asl
    ora roomDoors
    sta roomDoors
    
; set OR mask for the room sides    
    lda worldId
    beq .WorldRoomOrSides
; sneak in opportunity to update roomDoors
    ldx worldBank
    lda BANK_RAM + 1,x
    ldy roomId
    lda rRoomFlag,y
    and #%01010101
    sta Temp6
    asl
    clc
    adc Temp6
    eor #$FF
    and roomDoors
    sta roomDoors
    lda BANK_RAM
    
    lda #$C0
    .byte $2C
.WorldRoomOrSides
    lda #$00
    sta Temp6
    
    ldy #ROOM_SPR_HEIGHT-1
.roomInitMem
    lda BANK_ROM + 0
.roomInitMemLoop
    lda (Temp0),y ; PF1L
    ora Temp6
    sta wPF1RoomL+2,y
    lda (Temp4),y ; PF1R
    ora Temp6
    sta wPF1RoomR+2,y
    lda (Temp2),y ; PF2
    sta wPF2Room+2,y
    dey
    bpl .roomInitMemLoop

; All room sprite data has been read, we can now switch banks to
; conserve Bank 7 space
    lda BANK_ROM + 6
    jmp LoadRoom_B6
    LOG_SIZE "Room Load", LoadRoom
        
;===============================================================================
; Generate Random Number
;-----------------------
;   A - returns the randomly generated value
;===============================================================================
Random:
        lda Rand8
        lsr
        bcc noeor
        eor #$B4
noeor:
        sta Rand8
        rts

RoomScriptDel:
    lda BANK_ROM + 4
    ldx roomRS
    lda RoomScriptH,x
    pha
    lda RoomScriptL,x
    pha
    rts

EnemyAIDel:
    lda BANK_ROM + 4
    ldx enType
    lda EnemyAIH,x
    pha
    lda EnemyAIL,x
    pha
    rts

    LOG_SIZE "-CODE-", ENTRY

DataStart

    ;align 16
Mul8:
    .byte 0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38, 0x40, 0x48, 0x50, 0x58
Lazy8:
    .byte 0x01, 0x02, 0x04, 0x08
Bit8:
    .byte 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80
    
    
    ;align 4 

SwordWidth4:
    .byte $20, $20, $10, $10
SwordWidth8:
    .byte $30, $30, $10, $10
SwordHeight4:
    .byte 1, 1, 3, 3
SwordHeight8:
    .byte 1, 1, 7, 7
SwordOff4X:
    .byte 7, -1, 4, 4
SwordOff8X:
    .byte 7, -5, 4, 4
SwordOff4Y:
    .byte 3, 3, -2, 6
SwordOff8Y:
    .byte 3, 3, -6, 6
    ;align 16
WorldColors:
    .byte $00, COLOR_DARK_BLUE, $00, COLOR_LIGHT_BLUE, $42, $7A, COLOR_PATH, $06, $02, COLOR_LIGHT_BLUE, COLOR_GREEN_ROCK, COLOR_LIGHT_WATER, $00, COLOR_CHOCOLATE, COLOR_GOLDEN, $0E
HealthPattern:
    .byte $00, $01, $03, $07, $0F, $1F, $3F, $7F, $FF 

Spr8WorldOff:
    .byte (ROOM_HEIGHT+8), (TEXT_ROOM_HEIGHT+8)
Spr1WorldOff: 
    .byte (ROOM_HEIGHT+1), (TEXT_ROOM_HEIGHT+1)
RoomWorldOff:
    .byte (ROOM_PX_HEIGHT-1), (TEXT_ROOM_PX_HEIGHT-1)

    LOG_SIZE "-DATA-", DataStart

;===============================================================================
; PosObject
;----------
; subroutine for setting the X position of any TIA object
; when called, set the following registers:
;   A - holds the X position of the object
;   X - holds which object to position
;       0 = player0
;       1 = player1
;       2 = missile0
;       3 = missile1
;       4 = ball
; the routine will set the coarse X position of the object, as well as the
; fine-tune register that will be used when HMOVE is used.
;===============================================================================
/*
PosObject: SUBROUTINE
        sec
        sta WSYNC
.DivideLoop
        sbc #15        ; 2  2 - each time thru this loop takes 5 cycles, which is
        bcs .DivideLoop; 2  4 - the same amount of time it takes to draw 15 pixels
        eor #7         ; 2  6 - The EOR & ASL statements convert the remainder
        asl            ; 2  8 - of position/15 to the value needed to fine tune
        asl            ; 2 10 - the X position
        asl            ; 2 12
        asl            ; 2 14
        sta.wx HMP0,X  ; 5 19 - store fine tuning of X
        sta RESP0,X    ; 4 23 - set coarse X position of object
        rts            ; 6 29
*/
        
;===============================================================================
; PosWorldObjects
;----------
; Sets X position for all TIA objects
; X position must be between 0-134 ($00 to $86)
; Higher values will cause an extra cycle
;===============================================================================
PosWorldObjects: SUBROUTINE
    sec            ; 2
    ldx #4
.Loop
    sta WSYNC      ; 3
    lda plX,x      ; 4
DivideLoop
    sbc #15        ; 2  2 - each time thru this loop takes 5 cycles, which is
    bcs DivideLoop ; 2  4 - the same amount of time it takes to draw 15 pixels
    eor #7         ; 2  6 - The EOR & ASL statements convert the remainder
    asl            ; 2  8 - of position/15 to the value needed to fine tune
    asl            ; 2 10 - the X position
    asl            ; 2 12
    asl            ; 2 14
    sta.wx HMP0,X  ; 5 19 - store fine tuning of X
    sta RESP0,X    ; 4 23 - set coarse X position of object
; scn cycle 67
    dex ; 69
    bpl .Loop ; 72
        
    sta WSYNC
    sta HMOVE
    rts

; $18 2 iter (9) + 15 = 24
; $18
; $60 7 iter (34) + 15 = 49
PosHudObjects: SUBROUTINE
    sta WSYNC
    ; 26 cycles start
    
    lda worldId         ; 3
    ; 7 cycle start
    bne .dungeon        ; 2/3
    lda #$F             ; 2
    bne .roomIdMask     ; 3
.dungeon
    lda #$7             ; 2
    nop                 ; 2
.roomIdMask
    ; 7 cycle end
    
    and roomId          ; 3
    eor #7              ; 2
    asl                 ; 2
    asl                 ; 2
    asl                 ; 2
    asl                 ; 2
    sta HMM0            ; 3
    ; 26 cycles end
    sta RESP1           ; 3 - Map Sprite
    sta RESM0           ; 3 - Player Dot
    ; 18 cycles start
    lda worldId         ; 3
    bne .MapShift       ; 2/3
    lda #0              ; 2
    beq .SetMapShift    ; 3
.MapShift
    lda #$F0            ; 2
    nop                 ; 2
.SetMapShift
    sta HMP1            ; 3
    lda #0              ; 2
    sta HMP0            ; 3
    ; 18 cycles end
    sta RESP0           ;  - Inventory Sprites
    
    sta WSYNC
    sta HMOVE
    rts

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