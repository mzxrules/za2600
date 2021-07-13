;==============================================================================
; mzxrules 2021
;==============================================================================

;==============================================================================
; Selects a new direction to move in at random, respecting blocked direction
;==============================================================================
NextDir: SUBROUTINE
    jsr Random
    and #3
    tax
.nextLoop
    inx
    lda enBlockDir
    and Lazy8,x
    bne .nextLoop
    txa
    and #3
    sta enDir
    rts
    
;==============================================================================
; Selects a new direction based on the shortest path to the player
;==============================================================================
SeekDir: SUBROUTINE
    ldx #EN_DIR_L
    lda enX
    sec
    sbc plX
    bpl .checkY ; enX - plX >= 0, left
                ; enX - plX <  0, right
    ldx #EN_DIR_R
    ; negate A
    eor #$FF
    adc #1
.checkY
    sta Temp0 ; store abs(enX - plX)
    ldy #EN_DIR_D
    lda enY
    sec
    sbc plY
    bpl .checkAxis  ; enY - plY >= 0, down
                    ; enY - plY <  0, up
    ldy #EN_DIR_U
    ; negate A
    eor #$FF
    adc #1
.checkAxis
    sta Temp1
    stx enDir
    lda enBlockDir
    and Bit8,x
    bne .storeY
    lda enBlockDir
    and Bit8,y
    bne .rts
    lda Temp1
    sec
    sbc Temp0 ; abs(yDelta) - abs(xDelta)
    bmi .rts
.storeY
    sty enDir
.rts
    rts
    
;==============================================================================
; Updates enemy's enBlockDir flags
; A = flag reset mask. Set to $F0 to reset blocked direction flags
;==============================================================================
EnSetBlockedDir: SUBROUTINE
    and enBlockDir
    ldx enX
    cpx #EnBoardXR
    bne .setBlockedL
    ora #EN_BLOCKDIR_R
.setBlockedL
    cpx #EnBoardXL
    bne .setBlockedD
    ora #EN_BLOCKDIR_L
.setBlockedD
    ldx enY
    cpx #EnBoardYD
    bne .setBlockedU
    ora #EN_BLOCKDIR_D
.setBlockedU
    cpx #EnBoardYU
    bne .checkPFHit
    ora #EN_BLOCKDIR_U

.checkPFHit
    bit CXP1FB
    bmi .setCurBlock
    bvc .setBlockDir
.setCurBlock
    ldx enDir
    ora Bit8,x
.setBlockDir
    sta enBlockDir
    rts
    
EnDirR2: SUBROUTINE
    inc enX
EnDirR: SUBROUTINE
    inc enX
    rts
EnDirL2: SUBROUTINE
    dec enX
EnDirL: SUBROUTINE
    dec enX
    rts
EnDirD2: SUBROUTINE
    dec enY
EnDirD: SUBROUTINE
    dec enY
    rts
EnDirU2: SUBROUTINE
    inc enY
EnDirU: SUBROUTINE
    inc enY
    rts
    
EnNone:
    lda #$F0
    sta enSpr+1
    sta enY
RsNone:
RsWorldMidEnt:
RsNeedTriforce:
RsFairyFountain:
    rts
    
RsRaftSpot: SUBROUTINE
    lda plState
    and #$20
    bne .fixPos
; If item not obtained
    lda #ITEMF_RAFT
    and ITEMV_RAFT
    beq .rts
; If not touching water surface
    bit CXP0FB
    bpl .rts
    ldy plY
    cpy #$40
    bne .rts
    ldx plX
    cpx #$40
    bne .rts
    iny
    sty plY
    lda #PL_DIR_U
    sta plDir
    lda plState
    ora #$22
    sta plState
    lda #SFX_SURF
    sta SfxFlags
.fixPos
    lda #$40
    sta plX
.rts
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
    
RsGameOver: SUBROUTINE
    lda enInputDelay
    ldx plHealth
    bne .skipInit
    dec plHealth
    stx wBgColor
    stx wFgColor
    stx enType
    stx roomFlags
    stx mesgId
    inx
    stx KernelId
    inx
    stx plState
    
    ldx #RS_GAME_OVER
    stx roomRS
    ldx #$80
    stx plY
    
    ldx #MS_PLAY_OVER
    stx SeqFlags
    lda #-$20 ; input delay timer
.skipInit
    cmp #1
    adc #0
    sta enInputDelay
    bne .rts
    bit INPT4
    bmi .rts
    jsr RESPAWN
.rts
    rts
    
GiItemDel: SUBROUTINE
    ldx roomEX
    lda ItemIdH,x
    pha
    lda ItemIdL,x
    pha
    rts
    
GiBomb:
GiRupee5:
GiRecoverHeart:
GiFairy:
    rts

GiSword2:
GiSword3:
GiCandle:
GiMeat:
GiBoots:
GiRing:
GiPotion:
GiRaft:
    lda Bit8-8,x
    ora itemFlags
    sta itemFlags
    lda #MS_PLAY_GI
    sta SeqFlags
    rts
    
GiFlute:
GiFireMagic:
GiBow:
GiArrows:
GiBracelet:
    lda Bit8-8,x
    ora itemFlags+1
    sta itemFlags+1
    lda #MS_PLAY_GI
    sta SeqFlags
    rts

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
    
GiMap:
    ldy worldId
    lda Bit8-2,y
    ora itemMaps
    sta itemMaps
    lda #SFX_ITEM_PICKUP
    sta SfxFlags
    rts
    
GiItemColors:
    .byte COLOR_DARKNUT_RED, COLOR_DARKNUT_RED, COLOR_DARKNUT_BLUE, COLOR_DARKNUT_BLUE
    .byte COLOR_TRIFORCE, COLOR_DARKNUT_RED, COLOR_TRIFORCE, COLOR_TRIFORCE
    .byte $06, $0E, COLOR_DARKNUT_BLUE, COLOR_DARKNUT_RED
    .byte $0E, COLOR_DARKNUT_RED, COLOR_DARKNUT_BLUE, $F0
    
    .byte COLOR_TRIFORCE, COLOR_DARKNUT_RED, $F0, COLOR_TRIFORCE
    .byte COLOR_DARKNUT_RED, COLOR_TRIFORCE
    
;==============================================================================
; ENTITY
;==============================================================================
    
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
    lda roomId
    sta worldSR
    
    ldy roomEX
    sty worldId
    jmp SPAWN_AT_DEFAULT
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
    ora #RF_LOAD_EV
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
    lda rFgColor
    sta enColor
    lda #(30*8)
    sta enSpr
    rts

RsDiamondBlockStairs: SUBROUTINE
    lda #RF_NO_ENCLEAR
    ora roomFlags
    sta roomFlags
    lda #0
    sta wPF2Room + 13
    sta wPF2Room + 14
    lda #$41
    sta blX
    lda #$3C
    sta blY
    lda #BL_PUSH_BLOCK
    sta blType
    lda #RS_STAIRS
    sta roomRS
    rts

BlNone:
    lda #$80
    sta blY
    rts
    
BlR: SUBROUTINE
    inc blX
    rts
BlL:
    dec blX
    rts
BlU:
    inc blY
    rts
BlD:
    dec blY
    rts

BlPushBlock: SUBROUTINE
    ldx roomENCount
    bne .rts
    ldx blTemp
    inx
    cpx #16+12 ; full move
    bpl .pushDone
    stx blTemp
    cpx #12
    bmi .pushCheck
    lda Frame
    and #1
    beq .rts
    ldx blDir
    inx
    jmp BallDel

.pushCheck
    ; set direction
    lda plDir
    sta blDir
    
    ldy #0
    bit CXP0FB
    bvs .rts
    sty blTemp
    rts
    
.pushDone
    lda roomFlags
    ora #RF_CLEAR
    sta roomFlags
.rts
    rts
    
RsCentralBlock: SUBROUTINE
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    ldx #$40+1
    stx blX
    ldx #$2C
    stx blY
    lda #BL_PUSH_BLOCK
    sta blType
    lda #RS_NONE
    sta roomRS
    rts
    
RsStairs:
    lda roomFlags
    and #RF_CLEAR
    beq .rts
    lda #$40
    sta enX
    lda #$2C
    sta enY
    lda #EN_STAIRS
    sta enType
.rts
    rts
    
EnStairs: SUBROUTINE
    lda rFgColor
    sta enColor
    lda #<SprE31
    sta enSpr
    lda #>SprE31
    sta enSpr+1

    lda enX
    cmp plX
    bne .rts
    lda enY
    cmp plY
    bne .rts
    lda roomEX
    sta roomId
    lda roomFlags
    ora #RF_LOAD_EV
    sta roomFlags
.rts
    rts
    
EnSysEncounter:
    .byte EN_NONE, EN_DARKNUT, EN_LIKE_LIKE, EN_OCTOROK, EN_WALLMASTER, EN_BOSS_CUCCO
EnSysEncounterCount:
    .byte 0, 2, 2, 1, 1
    
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
    bit roomFlags
    bvs .checkRoomClear
    
    ; Else, if enemy clear event flag set, set enemy clear flag
    lda roomFlags
    and #RF_ENCLEAR_EV
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
    ; toggle off enemy clear event
    lda #~RF_ENCLEAR_EV
    and roomFlags
    sta roomFlags
    
    lda roomENCount
    beq .rts
    lda enType
    bne .rts
    lda #2
    bit plState
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
    
EnSpawnPF2Mask:
    .byte $80, $60, $18, $06
   
    LOG_SIZE "EnRandSpawn", EnRandSpawn
    
EnSysEnDie:
    lda #$80
    sta enY
    lda #EN_NONE
    sta enType
    dec roomENCount
    bne .rts
    ; Set room clear flag
    lda #RF_ENCLEAR_EV
    ora roomFlags
    sta roomFlags
.rts
    rts
    
EnMoveDirDel:
    ldx enDir
    lda EnMoveDirH,x
    pha
    lda EnMoveDirL,x
    pha
    rts
    
BallDel:
    lda BallH,x
    pha
    lda BallL,x
    pha
    rts
    
RoomScriptDel:
    ldx roomRS
    lda RoomScriptH,x
    pha
    lda RoomScriptL,x
    pha
    rts