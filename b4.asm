;==============================================================================
; mzxrules 2021
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
    
RsGameOver: SUBROUTINE
    lda enInputDelay
    ldx plHealth
    bne .skipInit
    dec plHealth
    stx bgColor
    stx fgColor
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
    lda #-$20
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
    bne .rts
    lda enY
    cmp plY
    bne .rts
    lda roomEX
    sta roomId
    lda roomFlags
    ora #$80
    sta roomFlags

.rts
    rts
    
EnSysEncounter:
    .byte EN_BOSS_CUCCO, EN_DARKNUT, EN_WALLMASTER
EnSysEncounterCount:
    .byte 1, 2, 2
    
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
    
    ; Else, if room clear event flag set, set room clear flag
    lda roomFlags
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
   
    LOG_SIZE "EnRandSpawn", EnRandSpawn
    
EnSpawnPF2Mask:
    .byte $80, $60, $18, $06
    
;==============================================================================
; EnSetBlockedDir
;----------
; Updates enemy's enBlockDir flags
; A = flag reset mask. Set to $F0 to reset flags
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
    ldx CXP1FB
    bpl .setBlockDir
    ldx enDir
    ora Bit8,x
.setBlockDir
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
    
EnBossCucco: SUBROUTINE
    lda #>SprE24
    sta enSpr+1
    lda #<SprE24
    sta enSpr
    lda #%0101
    sta NUSIZ1_T
    lda #$0a
    sta enColor
    rts

EnWallmasterCapture: SUBROUTINE
    inc enWallPhase
    ldx enWallPhase
    cpx #33
    bne .rts
    jsr SPAWN_AT_DEFAULT
.rts
    rts

EnWallmaster: SUBROUTINE
    ; draw sprite
    lda #>SprE15
    sta enSpr+1
    lda enWallPhase
    lsr
    clc
    adc #<SprE15-8
    sta enSpr
    lda #0
    sta enColor
    
    bit enState
    bvs EnWallmasterCapture
    bmi .runMain
    
; calculate initial position
    lda #0 ; up wall phase
    ldy #EnBoardYU
    ldx #EnBoardXL
    cpy plY
    beq .contInit
    cpx plX
    beq .contInit
    lda #32 ; down wall phase
    ldy #EnBoardYD
    ldx #EnBoardXR
    cpy plY
    beq .contInit
    cpx plX
    bne .rts

.contInit
    stx enX
    sty enY
    sta enWallPhase
    
    lda #$80
    sta enState
    
.runMain
    ldx enWallPhase
    cpx #16
    beq .next
    bmi .incWallPhase
    dec enWallPhase
    bpl .rts ; always branch
.incWallPhase
    inc enWallPhase
    bpl .rts ; always branch
    
.next
    bit CXPPMM
    bpl .handleMovement
    lda #-4
    jsr UPDATE_PL_HEALTH
    lda plState
    ora #2
    sta plState
    lda plX
    sta enX
    lda plY
    sta enY
    lda #$40
    ora enState
    sta enState
    lda #$80
    sta plY
    rts
.handleMovement
    lda #3
    bit enX
    bne .skipSetDir
    bit enY
    bne .skipSetDir
    
    lda #$F0
    ldx enPX
    cpx enX
    bne .NextDir
    ldx enPY
    cpx enY
    bne .NextDir
    lda #$FF
.NextDir
    jsr EnSetBlockedDir
    jsr SeekDir
.skipSetDir
    lda enX
    sta enPX
    lda enY
    sta enPY
    lda CXP1FB
    bmi .forceMove
    lda Frame
    and #1
    bne .rts
.forceMove
    ldx enDir
    jmp EnMoveDirDel
.rts
    rts

    LOG_SIZE "EnWallmaster", EnWallmaster
    
EnDarknut: SUBROUTINE
    lda enState
    bmi .skipInit
    lda #$80
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
    lda #$F0
    jsr EnSetBlockedDir

.checkDamaged
; if collided with weapon && stun == 0,
    lda CXM0P
    bpl .endCheckDamaged
    lda enStun
    bne .endCheckDamaged
    lda plDir
    cmp enDir
    beq .defSfx
    lda #-32
    sta enStun
    dec enHp
    bne .endCheckDamaged
    jmp EnSysEnDie
.defSfx
    lda #SFX_DEF
    sta SfxFlags
.endCheckDamaged

    bit enStun
    bmi .endCheckHit
    bit CXPPMM
    bpl .endCheckHit
    lda #-8
    jsr UPDATE_PL_HEALTH
.endCheckHit

.checkBlocked
    lda enBlockDir
    ldx enDir
    and Bit8,x
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
    beq .rts
   
EnMoveDirDel:
    lda EnMoveDirH,x
    pha
    lda EnMoveDirL,x
    pha
.rts
    rts
    LOG_SIZE "EnDarknut", EnDarknut

    INCLUDE "gen/EnMoveDir.asm"

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
    
RoomScriptDel: ; BANK_ROM 4
    ldx roomRS
    lda RoomScriptH,x
    pha
    lda RoomScriptL,x
    pha
    rts