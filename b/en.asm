;==============================================================================
; mzxrules 2021
;==============================================================================

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
/*
    jsr Random
    and #3
    tax
.nextLoop
    inx
    lda EnSysBlockedDir,y
    and Lazy8,x
    bne .nextLoop
    txa
    and #3
    sta enDir,y
*/
    rts


EnSetBlockedDir2: SUBROUTINE
    ldy EnSysNX
    cpy #[EnBoardXR/4]
    bne .setBlockedL
    ora #EN_BLOCKED_DIR_R
.setBlockedL
    cpy #[EnBoardXL/4]
    bne .setBlockedD
    ora #EN_BLOCKED_DIR_L
.setBlockedD
    ldy EnSysNY
    cpy #[EnBoardYD/4]
    bne .setBlockedU
    ora #EN_BLOCKED_DIR_D
.setBlockedU
    cpy #[EnBoardYU/4]
    bne .checkPFHit
    ora #EN_BLOCKED_DIR_U
.checkPFHit
    sta EnSysBlockedDir
    rts

;==============================================================================
; Tests if entity can move in current cardinal direction
; returns A != 0 if not blocked
; enNextDir returns tested direction
; Clobbers X, Y registers
;==============================================================================
TestCurDir: SUBROUTINE
    lda #0
    sta EnSysNextDirCount
    lda enDir,x
    sta enNextDir
    bpl .firstGo ; jmp

;==============================================================================
; Randomly selects a new cardinal direction that is not enNextDir
; returns A != 0 if not blocked
; enNextDir returns new direction
; Clobbers X, Y registers
;==============================================================================
NextDir3:
    lda #2
    sta EnSysNextDirCount
    jsr Random
    ldy #0
    cmp #$55
    bcc .select3
    iny
    cmp #$AA
    bcc .select3
    iny
.select3
    and #4
    ora Mul8,y
    ora enNextDir
    bpl .nextDir3Entry

;==============================================================================
; Randomly selects a new cardinal direction
; returns A != 0 if not blocked
; enNextDir returns new direction
; Clobbers X, Y registers
;==============================================================================
NextDir4:
    lda #3
    sta EnSysNextDirCount
    jsr Random
    ldy #0
    cmp #$55
    bcc .select
    iny
    cmp #$AA
    bcc .select
    iny
.select
    and #7
    ora Mul8,y
    sta EnSysNextDirSeed
    and #3
    sta enNextDir
    bpl .firstGo

.checkLoop
    dec EnSysNextDirCount
    bmi .miss
    lda EnSysNextDirSeed
    sec
    sbc #8
    bpl .continue
    adc #24
.continue
.nextDir3Entry
    sta EnSysNextDirSeed
    tax
    lda nextdir_lut,x
    sta enNextDir

.firstGo
    ldx EnSysNX
    ldy EnSysNY
    lda enNextDir
    bne .check_1

.EN_DIR_L
    lda EnSysBlockedDir
    and Lazy8 + EN_DIR_L
    bne .checkLoop

    dex
    jsr CheckRoomCol_XA
    bne .checkLoop
    dec EnSysNX
    lda #1
    rts

.check_1
    cmp #EN_DIR_R
    bne .check_2
.EN_DIR_R
    lda EnSysBlockedDir
    and Lazy8 + EN_DIR_R
    bne .checkLoop

    inx
    jsr CheckRoomCol_XA
    bne .checkLoop
    inc EnSysNX
    lda #1
    rts

.check_2
    cmp #EN_DIR_U
    bne .EN_DIR_D

.EN_DIR_U
    lda EnSysBlockedDir
    and Lazy8 + EN_DIR_U
    bne .checkLoop

    iny
    jsr CheckRoomCol_XA
    bne .checkLoop
    inc EnSysNY
    lda #1
    rts

.EN_DIR_D
    lda EnSysBlockedDir
    and Lazy8 + EN_DIR_D
    bne .checkLoop

    dey
    jsr CheckRoomCol_XA
    bne .checkLoop
    dec EnSysNY
    lda #1
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
    lda EnSysBlockedDir
    and Bit8,x
    bne .storeY
    lda EnSysBlockedDir
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
; Updates enemy's enBlockedDir flags
; A = flag reset mask. Set to $F0 to reset blocked direction flags
;==============================================================================
EnSetBlockedDir: SUBROUTINE
/*
    and enBlockedDir,y
    ldx enX
    cpx #EnBoardXR
    bne .setBlockedL
    ora #EN_BLOCKED_DIR_R
.setBlockedL
    cpx #EnBoardXL
    bne .setBlockedD
    ora #EN_BLOCKED_DIR_L
.setBlockedD
    ldx enY
    cpx #EnBoardYD
    bne .setBlockedU
    ora #EN_BLOCKED_DIR_D
.setBlockedU
    cpx #EnBoardYU
    bne .checkPFHit
    ora #EN_BLOCKED_DIR_U

.checkPFHit
    bit CXP1FB
    bmi .setCurBlock
    bvc .setBlockDir
.setCurBlock
    ldx enDir,y
    ora Bit8,x
.setBlockDir
    sta enBlockedDir,y
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

; Diagonals
EnDirLu: SUBROUTINE
    dec en0X,x
    inc en0Y,x
    rts
EnDirLd: SUBROUTINE
    dec en0X,x
    dec en0Y,x
    rts
EnDirRu: SUBROUTINE
    inc en0X,x
    inc en0Y,x
    rts
EnDirRd: SUBROUTINE
    inc en0X,x
    dec en0Y,x
    rts

EnNone:
    lda #$F0
    sta enSpr+1
    sta en0Y,x
    rts

;==============================================================================
; ENTITY
;==============================================================================

EnSysEncounter:
    .byte EN_NONE, EN_OCTOROK, EN_OCTOROK, EN_ROPE
    .byte EN_ROPE, EN_DARKNUT, EN_DARKNUT, EN_BOSS_GOHMA
    .byte EN_WALLMASTER, EN_TEST_MISSILE, EN_LIKE_LIKE, EN_BOSS_GLOCK
    .byte EN_WATERFALL, EN_ROLLING_ROCK
EnSysEncounterCount:
    .byte 0, 1, 2, 1
    .byte 2, 1, 2, 1
    .byte 1, 1, 1, 1
    .byte 1, 2, 0, 0

ClearDropSystem: SUBROUTINE
    lda enType
    bne .ClearDropSystem_rts
    lda roomFlags
    and #RF_EV_ENCLEAR | #RF_EV_CLEAR
    beq .ClearDropSystem_rts

    ldy #EN_CLEAR_DROP
    sty enType
    ldx #0
    stx enState
    stx cdBTimer
    stx cdAType
    stx cdBType

    and #RF_EV_ENCLEAR
    beq .ClearDropSystem_rts
    dec cdBType ; CD_ITEM_RAND

.ClearDropSystem_rts

EnSystem: SUBROUTINE
    lda roomId
    bmi .rts
    ; precompute room clear flag helpers because it's annoying
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
    ; toggle off enemy clear event
    lda #~RF_EV_ENCLEAR
    and roomFlags
    sta roomFlags

    ; test if the player is being positioned in the room
    lda #PS_LOCK_ALL
    bit plState
    bne .rts

    ; return if...
    ; There are 0 encounters left
    ; There is 1 encounter left and enType is already slotted
    ldx #0
.loop
    cpx roomENCount
    beq .rts
    lda enType,x
    beq .cont
    inx
    cpx #2
    bne .loop
.rts
    rts

.cont
    ; store next encounter
    lda EnSysEncounter,y
    sta EnSysNext

    ; zero entity variable data
    ldy #EN_VARS_COUNT-1
    stx enNum
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

    lda #4
    sta EnSysSpawnTry
    jsr EnRandSpawn
    lda EnSysSpawnTry
    beq .rts

    ldx enNum
    lda EnSysNext
    sta enType,x
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

;==============================================================================
; EnSysEnDie
;----------
; Kills an Enemy
; X = enNum of Enemy to kill
;==============================================================================
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
    sta en0Y,x
    lda #EN_NONE
    sta enType,x
    cpx #0
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
    sta EN_VARS-6,x
    dex
    dex
    bpl .loop
    lda #EN_NONE
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