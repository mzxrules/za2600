;==============================================================================
; mzxrules 2021
;==============================================================================
En_Del:
    lda #SLOT_EN_B
    sta BANK_SLOT
    ldx enType,y
    lda EntityH,x
    pha
    lda EntityL,x
    pha
    rts

;==============================================================================
; Tests room collision
; X = x position
; Y = y position (move to reg a?)
; returns A != 0 if collision occurs
; y position must not be in range 0-3
;==============================================================================
CheckRoomCol: SUBROUTINE
; adjust x coordinate
    txa
    lsr
    lsr
    tax

; adjust y coordinate
    tya
    lsr
    lsr
    tay
; A stores adjusted y coord

CheckRoomCol_XA:
    tya

    cpx #[$04/4]
    bmi .rts
    cmp #[$10/4]
    bmi .rts

    cpx #[$60/4]
    beq .special_right
    cpx #[$20/4]
    beq .special_left
    clc
    adc room_col8_off-1,x
    tay
    lda rPF1RoomL-2,y
    ora rPF1RoomL-1,y
    and room_col8_mask-1,x
    rts

.special_right
    adc #ROOM_PX_HEIGHT -1
.special_left
    tax
    lda rPF1RoomL-2,x
    ora rPF1RoomL-1,x
    ora rPF2Room-2,x
    ora rPF2Room-1,x
    and #1

.rts
    rts

;==============================================================================
; Selects a new direction to move in at random, respecting blocked direction
;==============================================================================
NextDir: SUBROUTINE
    jsr Random
    and #3
    tax
.nextLoop
    inx
    lda enBlockDir,y
    and Lazy8,x
    bne .nextLoop
    txa
    and #3
    sta enDir,y
    rts

NextDir2: SUBROUTINE

EnSetBlockedDir2: SUBROUTINE
    ldx EnSysNX
    cpx #[EnBoardXR/4]
    bne .setBlockedL
    ora #EN_BLOCKDIR_R
.setBlockedL
    cpx #[EnBoardXL/4]
    bne .setBlockedD
    ora #EN_BLOCKDIR_L
.setBlockedD
    ldx EnSysNY
    cpx #[EnBoardYD/4]
    bne .setBlockedU
    ora #EN_BLOCKDIR_D
.setBlockedU
    cpx #[EnBoardYU/4]
    bne .checkPFHit
    ora #EN_BLOCKDIR_U
.checkPFHit
    sta enBlockDir

    jsr Random
    and #3
    sta enNextTemp
    sta enNextTemp2
    bpl .firstGo

.checkLoop
    inc enNextTemp
    lda enNextTemp
    and #3
    cmp enNextTemp2
    beq .miss

.firstGo
    tax
    lda enBlockDir
    and Lazy8,x
    bne .checkLoop
    ldx EnSysNX
    ldy EnSysNY
    lda enNextTemp
    and #3
    bne .check_1

.EN_BLOCKDIR_L
    dex
    jsr CheckRoomCol_XA
    bne .checkLoop
    dec EnSysNX
    lda #EN_DIR_L
    sta enNextDir
    lda #1
    rts

.check_1
    cmp #1
    bne .check_2
.EN_DIR_R
    inx
    jsr CheckRoomCol_XA
    bne .checkLoop
    inc EnSysNX
    lda #EN_DIR_R
    sta enNextDir
    rts

.check_2
    cmp #2
    bne .EN_DIR_D

.EN_DIR_U
    iny
    jsr CheckRoomCol_XA
    bne .checkLoop
    inc EnSysNY
    lda #EN_DIR_U
    sta enNextDir
    rts

.EN_DIR_D
    dey
    jsr CheckRoomCol_XA
    bne .checkLoop
    dec EnSysNY
    lda #EN_DIR_D
    sta enNextDir
    rts

.miss
    lda #0
    rts

;==============================================================================
; Selects a new direction based on the shortest path to the player
; X = returns left/right direction towards player
; Y = returns up/down direction towards player
;==============================================================================
SeekDir: SUBROUTINE
/*
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
*/
    rts

;==============================================================================
; Updates enemy's enBlockDir flags
; A = flag reset mask. Set to $F0 to reset blocked direction flags
;==============================================================================
EnSetBlockedDir: SUBROUTINE
/*
    and enBlockDir,y
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
    ldx enDir,y
    ora Bit8,x
.setBlockDir
    sta enBlockDir,y
*/
    rts

EnDirR2: SUBROUTINE
    inc en0X,x
EnDirR: SUBROUTINE
    inc en0X,x
    rts
EnDirL2: SUBROUTINE
    dec en0X,x
EnDirL: SUBROUTINE
    dec en0X,x
    rts
EnDirD2: SUBROUTINE
    dec en0Y,x
EnDirD: SUBROUTINE
    dec en0Y,x
    rts
EnDirU2: SUBROUTINE
    inc en0Y,x
EnDirU: SUBROUTINE
    inc en0Y,x
    rts

EnNone:
    lda #$F0
    sta enSpr+1
    sta en0Y,y
    rts

;==============================================================================
; ENTITY
;==============================================================================

EnSysEncounter:
    .byte EN_NONE, EN_DARKNUT, EN_ROPE, EN_LIKE_LIKE
    .byte EN_OCTOROK, EN_WALLMASTER, EN_BOSS_GOHMA, EN_TEST
EnSysEncounterCount:
    .byte 0, 2, 2, 1
    .byte 1, 1, 1, 1

EnSystem_DUMMY: SUBROUTINE
.rts2
    rts
EnSystem:
    ; precompute room clear flag helpers because it's annoying
    lda roomId
    bmi .rts2
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
    bvs .checkRoomClear ; #RF_EV_LOADED

    ; Else, if enemy clear event flag set, set enemy clear flag
    lda roomFlags
    and #RF_EV_ENCLEAR
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
    lda #0
    sta enNum
    ; toggle off enemy clear event
    lda #~RF_EV_ENCLEAR
    and roomFlags
    sta roomFlags

    lda roomENCount
    beq .rts
    lda enType
    beq .cont
    inc enNum
    lda enNum
    cmp roomENCount
    beq .rts
    lda enType+1
    bne .rts
.cont
    lda #PS_LOCK_ALL
    bit plState
    bne .rts

    lda EnSysEncounter,y
    sta EnSysNext
    lda #4
    sta EnSysSpawnTry
    jsr EnRandSpawn
    lda EnSysSpawnTry
    beq .rts
    ldy #EN_VARS_COUNT-1
    ldx enNum
    bne .entity2
    dey
.entity2
    lda #0
.EnInitLoop:
    sta EN_VARS,y
    dey
    dey
    bpl .EnInitLoop

    ldx enNum
    lda EnSysNext
    sta enType,x
.rts
    rts


EnRandSpawnRetry:
    dec EnSysSpawnTry
    beq .rts
EnRandSpawn: SUBROUTINE
    jsr Random
    and #$7 ; y pos mask
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
    lda rPF2Room+2+1,y
    ora rPF2Room+2+2,y
    and EnSpawnPF2Mask,x
    bne EnRandSpawnRetry
    tya
    asl
    asl ; y * 4 (* 8 total)
    clc
    adc #$14
    ldy enNum
    sta en0Y,y
    lda Mul8,x
    bit Rand16
    bmi .skipInvert
    eor #$FF
    sec
    adc #0
.skipInvert
    clc
    adc #$40
    sta en0X,y
    rts

EnSpawnPF2Mask:
    .byte $80, $60, $18, $06

    LOG_SIZE "EnRandSpawn", EnRandSpawn

EnSysEnDie:
    dec roomENCount
    bne .continueEncounter
    ; Set room clear flag
    lda #RF_EV_ENCLEAR
    ora roomFlags
    sta roomFlags
    ; set random item drop position
    lda enX
    sta cdBX
    lda enY
    sta cdBY

.continueEncounter
    lda #$80
    sta en0Y,y
    lda #EN_NONE
    sta enType,y
    cpy #0
    beq EnSysCleanShift
.rts
    rts

EnSysCleanShift: SUBROUTINE
    lda enType
    bne .rts
    ldx enType+1
    beq .rts
    stx enType

    ldx #EN_VARS_COUNT + 6 -2
.loop
    lda EN_VARS-6+1,x
    sta EN_VARS-6,X
    dex
    dex
    bpl .loop
    lda #0
    sta enType+1

.rts
    rts

EnMoveDirDel:
    ldy enDir
EnMoveDirDel2:
    lda EnMoveDirH,y
    pha
    lda EnMoveDirL,y
    pha
    rts

ClearDropSystem: SUBROUTINE
    lda enType
    bne .rts
    lda roomFlags
    and #RF_EV_ENCLEAR | #RF_EV_CLEAR
    beq .rts

    ldy #EN_CLEAR_DROP
    sty enType
    ldx #0
    stx enState
    stx cdBTimer
    stx cdAType
    stx cdBType

    and #RF_EV_ENCLEAR
    beq .rts
    dec cdBType ; CD_ITEM_RAND

.rts
    rts