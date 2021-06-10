;==============================================================================
; mzxrules 2021
;==============================================================================
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
EnNone:
    lda #$F0
    sta enSpr+1
    sta enY
RsNone:
RsWorldMidEnt:
RsRaftSpot:
RsNeedTriforce:
RsFairyFountain:
    rts

RsText: SUBROUTINE
    lda #1
    sta KernelId
    lda roomEX
    sta mesgId
    rts
    
RsItem: SUBROUTINE
    lda roomENCount
    bne .rts
    ldx roomId
    ldy worldBank
    lda BANK_RAM + 1,y
    lda rRoomFlag,x
    bmi .NoLoad
    
    lda #$40
    sta enX
    lda #$2C
    sta enY
    lda #EN_ITEM
    sta enType
.NoLoad
    lda BANK_RAM + 0
    lda #0
    sta roomRS
.rts
    rts
    
GiItemDel: SUBROUTINE
    ldx roomEX
    lda ItemIdH,x
    pha
    lda ItemIdL,x
    pha
    rts
    
GiFlute:
GiBomb:
GiRing:
GiSword3:
GiSword2:
GiRupee5:
GiBoots:
GiMeat:
GiCandle:
GiPotion:
GiRecoverHeart:
GiFairy:
GiRaft:
GiTriforce:
    inc itemTri
    lda #MS_PLAY_GI
    sta SeqFlags
    rts
GiKey:
    inc itemKeys
    lda #SFX_ITEM_PICKUP
    sta SfxFlags
    rts
GiMasterKey:
    lda #$C0
    sta itemKeys
    lda #MS_PLAY_GI
    sta SeqFlags
    rts
    
GiHeart:
    clc
    lda #8
    adc plHealthMax
    sta plHealthMax
    lda #8
    adc plHealth
    sta plHealth
    lda #MS_PLAY_GI
    sta SeqFlags
    rts
    
EnItem: SUBROUTINE
    lda #>SprItem0
    sta enSpr+1
    ldy roomEX
    lda GiItemColors,y
    sta enColor
    lda roomEX
    asl
    asl
    asl
    clc
    adc #<SprItem0
    sta enSpr
    lda CXPPMM
    bpl .rts
    ; item collected
    lda #EN_NONE
    sta enType
    ldx roomId
    ldy worldBank
    lda BANK_RAM + 1,y
    lda rRoomFlag,x
    ora #$80
    sta wRoomFlag,x
    lda BANK_RAM + 0
    jsr GiItemDel
.rts
    rts
    
GiItemColors:
    .byte COLOR_DARKNUT_RED, COLOR_DARKNUT_RED, COLOR_DARKNUT_BLUE, COLOR_DARKNUT_BLUE
    .byte COLOR_TRIFORCE, COLOR_DARKNUT_RED, COLOR_TRIFORCE, COLOR_TRIFORCE
    .byte $06, $0E, COLOR_DARKNUT_BLUE, COLOR_DARKNUT_RED
    .byte $0E, COLOR_DARKNUT_RED, COLOR_DARKNUT_BLUE, $F0
    .byte COLOR_TRIFORCE
    
EnTriforce: SUBROUTINE
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
    ldy roomEX
    lda DUNGEON_ENT-1,y
    sta roomId
    sty worldId
    lda roomFlags
    ora #$80
    sta roomFlags
    lda #MS_PLAY_DUNG
    sta SeqFlags
.rts
    rts
    
DUNGEON_ENT:
    .byte #$73, #$00, #$00, #$00, #$00, #$F3, #$00, #$00, #$00
    
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
    lda #MS_PLAY_THEME_L
    sta SeqFlags
.rts
    rts
    
EnSpectacleOpen: SUBROUTINE
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

EnBlockStairs: SUBROUTINE
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

RsStairs:
    lda #$40
    sta enX
    lda #$2C
    sta enY
    lda #EN_STAIRS
    sta enType
    rts
    
EnStairs: SUBROUTINE
    lda fgColor
    sta enColor
    lda #<SprE31
    sta enSpr
    lda #>SprE31
    sta enSpr+1

    lda enX
    cmp plX
    bne .playerNotOnStairs
    lda enY
    cmp plY
    bne .playerNotOnStairs
    lda roomEX
    sta roomId
    lda roomFlags
    ora #$80
    sta roomFlags

.playerNotOnStairs
    rts
    
EnSysEncounter:
    .byte EN_DARKNUT
EnSysEncounterCount:
    .byte 2
    
    align 256
EnSystem: SUBROUTINE
    ; precompute room clear flag helpers because it's annoying
    lda roomId
    lsr
    lsr
    lsr
    sta EnSysClearOff
    lda roomId
    and #7
    tax
    lda Bit8,x
    sta EnSysClearMask
    
    ; Set x to clear flag offset
    ldx EnSysClearOff
    ; Set y to encounterId
    ldy roomEN
    
    ; If room load this frame, setup new encounter
    lda roomFlags
    bvs .checkRoomClear
    
    ; Else, if room clear event flag set, set room clear flag
    and #$20
    beq .runEncounter ; flag not set, run encounter
    
    lda rRoomClear,x
    ora EnSysClearMask
    sta wRoomClear,x
    bne .runEncounter ; should always branch
    
    ; Test if room wasn't cleared
.checkRoomClear
    lda #0
    sta roomENCount
    ; check room clear state
    lda rRoomClear,x ; get room clear byte
    and EnSysClearMask
    bne .runEncounter
    
    lda EnSysEncounterCount,y
    sta roomENCount
    
.runEncounter
    ; toggle off room clear event
    lda #$DF
    and roomFlags
    sta roomFlags
    
    lda roomENCount
    beq .rts
    lda enType
    bne .rts
    lda EnSysEncounter,y
    sta EnSysNext
    lda #4
    sta EnSysSpawnTry
    jsr EnRandSpawn
    lda EnSysSpawnTry
    beq .rts
    ldy #EN_V0_COUNT-1
    lda #0
.EnInitLoop:
    sta EN_VARIABLES,y
    dey
    bpl .EnInitLoop
    
    lda EnSysNext
    sta enType
.rts
    rts
    
EnRandSpawnRetry:
    dec EnSysSpawnTry
    beq .rts
EnRandSpawn: SUBROUTINE
    jsr Random
    and #$7 ; y pos mask
    ;sta itemRupees ; remove
    cmp #7
    bne .skipYShift
    lsr
.skipYShift
    asl
    tay      ; y pos * 2
    lda #$18 ; x pos mask
    and Rand16
    lsr
    lsr
    lsr
    tax
    lda EnSpawnPF2Mask,x
    sta Temp0
    lda rPF2Room+2+1,y
    and Temp0
    bne EnRandSpawnRetry
    lda rPF2Room+2+2,y
    and Temp0
    bne EnRandSpawnRetry
    tya
    asl
    asl ; y * 4 (* 8 total)
    clc
    adc #$14
    sta enY
    sta enYL
    lda Mul8,x
    bit Rand16
    bmi .skipInvert
    eor #$FF
    sec
    adc #0
.skipInvert
    clc
    adc #$40
    sta enX
    sta enXL
    rts
   
    LOG_SIZE "EnRandSpawn", EnRandSpawn
    
EnSpawnPF2Mask:
    .byte $80, $60, $18, $06
    
EnBlockedDirSet: SUBROUTINE
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
    rts
    
EnSysEnDie:
    lda #$80
    sta enY
    lda #EN_NONE
    sta enType
    dec roomENCount
    bne .rts
    ; Set room clear flag
    lda #$20
    ora roomFlags
    sta roomFlags
.rts
    rts

EnDarknut: SUBROUTINE
    lda enState
    bmi .skipInit
    lda #$80
    ora enState
    sta enState
    jsr Random
    and #3
    sta enDir
    lda #1
    sta enHp
.skipInit
    lda #>SprE0
    sta enSpr+1
; update stun timer
    lda enStun
    cmp #1
    adc #0
    sta enStun
    asl
    asl
    adc #COLOR_DARKNUT_RED
    sta enColor

    jsr EnBlockedDirSet

.checkPFHit
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
    dec enHp
    bne .endCheckHit
    jmp EnSysEnDie
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
    and #7
    bne .move
    lda enY
    and #7
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