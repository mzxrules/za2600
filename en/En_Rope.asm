;==============================================================================
; mzxrules 2021
;==============================================================================

En_Rope: SUBROUTINE
    lda #EN_ROPE_MAIN
    sta enType
    jsr Random
    and #3
    sta enDir
    lda #1 -1
    sta enHp
    lda #-12
    sta enRopeTimer

En_RopeMain: SUBROUTINE
; update stun timer
    lda enStun
    cmp #1
    adc #0
    sta enStun
    lda #$F0
    jsr EnSetBlockedDir

.checkDamaged
; if collided with weapon && stun == 0,
    lda CXM0P
    bpl .endCheckDamaged
    lda enStun
    bne .endCheckDamaged
    jsr EnSys_Damage
    bpl .defSfx
    ldx #-32
    stx enStun
    clc
    adc enHp
    sta enHp
    bpl .endCheckDamaged
    jmp EnSysEnDie
.defSfx
    lda #SFX_DEF
    sta SfxFlags
.endCheckDamaged

; Check player hit
    bit enStun
    bmi .endCheckHit
    bit CXPPMM
    bpl .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit

    bit enState
    bvs .checkBlocked
    lda enRopeTimer
    cmp #1
    adc #0
    sta enRopeTimer
    bne .checkBlocked
.tryAttackX
    lda plX
    lsr
    sta Temp0
    lda enX
    lsr
    cmp Temp0
    bne .tryAttackY
    asl
    sta enX
    jsr SeekDir
    sty enDir
    lda #$40 ; #EN_ROPE_ATTACK
    sta enState
    jmp .checkBlocked
.tryAttackY
    lda plY
    lsr
    sta Temp0
    lda enY
    lsr
    cmp Temp0
    bne .checkBlocked
    asl
    sta enY
    jsr SeekDir
    stx enDir
    lda #$40
    sta enState
    jmp .checkBlocked


.checkBlocked
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
    bit enState
    bvc .checkMove
; Fast move
    ldx enDir
    jsr EnMoveDirDel
.checkMove
    lda Frame
    and #1
    beq .clampPos
.moveNow
    ldx enDir
    jsr EnMoveDirDel

; Since we're potentially moving 2 pixels per frame, clamp enX/enY
.clampPos
; left/right
    ldx #EnBoardXR
    cpx enX
    bpl .left
    stx enX
.left
    ldx #EnBoardXL
    cpx enX
    bmi .up
    stx enX
.up
    ldx #EnBoardYU
    cpx enY
    bpl .down
    stx enY
.down
    ldx #EnBoardYD
    cpx enY
    bmi .rts
    stx enY
.rts
    rts
    LOG_SIZE "En_Rope", En_Rope