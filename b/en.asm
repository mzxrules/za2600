;==============================================================================
; mzxrules 2021
;==============================================================================
En_Del:
    lda #SLOT_EN_B
    sta BANK_SLOT
    ldx enType
    lda EntityH,x
    pha
    lda EntityL,x
    pha
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
    rts
    
;==============================================================================
; ENTITY
;==============================================================================
    
EnSysEncounter:
    .byte EN_NONE, EN_DARKNUT, EN_LIKE_LIKE, EN_OCTOROK, EN_WALLMASTER, EN_BOSS_CUCCO
EnSysEncounterCount:
    .byte 0, 1, 2, 1, 1
    
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
    
    lda roomENCount
    beq .rts
    lda enType
    bne .rts
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
    dec roomENCount
    bne .continueEncounter
    ; Set room clear flag
    lda #RF_EV_ENCLEAR
    ora roomFlags
    sta roomFlags
    
    lda enX
    sta cdBX
    lda enY
    sta cdBY
    
.continueEncounter
    lda #$80
    sta enY
    lda #EN_NONE
    sta enType
.rts
    rts
    
EnMoveDirDel:
    ldx enDir
    lda EnMoveDirH,x
    pha
    lda EnMoveDirL,x
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