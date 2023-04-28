;==============================================================================
; mzxrules 2021
;==============================================================================

En_Rope: SUBROUTINE
    lda #EN_ROPE_MAIN
    sta enType,x
    jsr Random
    and #3
    sta enDir,x
    lda #1 -1
    sta enHp,x
    lda #-12
    sta enRopeTimer,x

    lda en0X,x
    lsr
    lsr
    sta enNX,x
    lda en0Y,x
    lsr
    lsr
    sta enNY,x

En_RopeMain: SUBROUTINE
    lda enNX,x
    sta EnSysNX
    lda enNY,x
    sta EnSysNY

; update stun timer
    lda enStun,x
    cmp #1
    adc #0
    sta enStun,x
;    lda #$F0
;    jsr EnSetBlockedDir

.checkDamaged
; if collided with weapon && stun == 0,
    lda enStun,x
    bne .endCheckDamaged
    lda #SLOT_BATTLE
    sta BANK_SLOT
    ldy enNum
    jsr HbGetPlAtt
    jsr HbPlAttCollide_EnBB

; Get damage
    ldx HbDamage
    lda EnDam_Rope,x
    sta Temp0

    lda #SLOT_EN_A
    sta BANK_SLOT
    lda HbFlags
    beq .endCheckDamaged

.gethit
    lda Temp0 ; fetch damage
    ldx #-32
    stx enStun,y
    clc
    adc enHp,y
    sta enHp,y
    bpl .endCheckDamaged
    jmp EnSysEnDie
.defSfx
    lda #SFX_DEF
    sta SfxFlags
.endCheckDamaged

; Check player hit
    lda enStun,y
    bmi .endCheckHit
    bit CXPPMM
    bpl .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit

    rts



    ldx enNum

    lda enState,x
    and #$40
    bne .checkBlocked
    lda enRopeTimer,x
    cmp #1
    adc #0
    sta enRopeTimer,x
    bne .checkBlocked
.tryAttackX
    lda plX
    lsr
    sta Temp0
    lda en0X,x
    lsr
    cmp Temp0
    bne .tryAttackY
    jmp .tryAttackY ; TODO: FIX
    asl
    sta en0X,x
    jsr SeekDir
    sty enDir
    lda #$40 ; #EN_ROPE_ATTACK
    sta enState
    jmp .checkBlocked
.tryAttackY
    lda plY
    lsr
    sta Temp0
    lda en0Y,x
    lsr
    cmp Temp0
    bne .checkBlocked
    jmp .checkBlocked ; TODO: FIX
    asl
    sta en0Y,x
    jsr SeekDir
    stx enDir
    lda #$40
    sta enState
    jmp .checkBlocked


.checkBlocked
    jmp .endCheckBlocked ; TODO: FIX
    lda enBlockDir
    ldx enDir
    and Bit8,x
    beq .endCheckBlocked
    jsr NextDir
    lda enState
    and #~$40
    sta enState
    lda #-12
    sta enRopeTimer
    jmp .move
.endCheckBlocked

.move
    ldy enNum

    lda enState,y
    and #$40
    beq .checkMove
; Fast move
    ldx enDir,y
    jsr EnMoveDirDel
.checkMove
    lda Frame
    and #1
    beq .clampPos
.moveNow
    ldx enDir,y
    jsr EnMoveDirDel

; Since we're potentially moving 2 pixels per frame, clamp enX/enY
.clampPos
    ldx enNum
; left/right
    lda #EnBoardXR
    cmp en0X,x
    bpl .left
    sta en0X,x
.left
    lda #EnBoardXL
    cmp en0X,x
    bmi .up
    sta en0X,x
.up
    lda #EnBoardYU
    cmp en0Y,x
    bpl .down
    sta en0Y,x
.down
    ldx #EnBoardYD
    cmp en0Y,x
    bmi .rts
    sta en0Y,x
.rts
    rts
    LOG_SIZE "En_Rope", En_Rope