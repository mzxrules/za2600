;==============================================================================
; mzxrules 2021
;==============================================================================

En_Darknut: SUBROUTINE
    lda #EN_DARKNUT_MAIN
    sta enType,x
    jsr Random
    and #3
    sta enDir,x
    lda #2
    sta enHp,x
    lda en0X,x
    lsr
    lsr
    sta enNX,x
    lda en0Y,x
    lsr
    lsr
    sta enNY,x

En_DarknutMain:
    lda enNX,x
    sta EnSysNX
    lda enNY,x
    sta EnSysNY

; update stun timer
    lda enStun,x
    cmp #1
    adc #0
    sta enStun,x


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
    lda EnDam_Darknut,x
    sta Temp0

    lda #SLOT_EN_A
    sta BANK_SLOT
    lda HbFlags
    beq .endCheckDamaged

; Test if darknut takes damage
    lda HbFlags
    and #HB_PL_FIRE
    bne .endCheckDamaged
    lda HbFlags
    and #HB_PL_SWORD | #HB_PL_BOMB
    beq .defSfx ; block non-damaging attacks

; Test if item hit Darknut's shield
    ldx enDir,y
    cpx plItemDir
    bne .gethit

    ; Test if sword hit shield
    and #HB_PL_SWORD
    bne .defSfx
    ; Bomb hit shield
    lda #-2
    sta Temp0

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
    lda #-8
    jsr UPDATE_PL_HEALTH
    ldy enNum
.endCheckHit

; Movement
    ldx enNum
    lda enNX,x
    asl
    asl
    cmp en0X,x
    bne .move
    lda enNY,x
    asl
    asl
    cmp en0Y,x
    bne .move

    lda #$00
    jsr EnSetBlockedDir2
    jsr NextDir2
    beq .rts
    ldx enNum
    lda enNextDir
    sta enDir,x
.move
    lda Frame
    and #1
    beq .rts
    ldx enNum
    lda enDir,x
    tay
    jsr EnMoveDirDel2
.rts
    ldx enNum
    lda EnSysNX
    sta enNX,x
    lda EnSysNY
    sta enNY,x
    rts
    LOG_SIZE "En_Darknut", En_Darknut