;==============================================================================
; mzxrules 2021
;==============================================================================
EN_OCTOROK_SPIN = $08
EN_OCTOROK_COMMON = $80
En_Octorok: SUBROUTINE
    lda #EN_OCTOROK_MAIN
    sta enType,x
    jsr Random

    ;and #$7F
    ;ora #$10
    ;sta enOctorokThink,x
    and #3
    sta enDir,x
    sta enState,x
    lda Rand16
    and #7
    beq .rareType

    lda enState,x
    ora #EN_OCTOROK_COMMON
    sta enState,x

.rareType
    lda #2 -1
    sta enHp,x

; target next
    lda en0X,x
    lsr
    lsr
    sta enNX,x
    lda en0Y,x
    lsr
    lsr
    sta enNY,x

    jsr En_Octorok_Think
    rts

En_OctorokMain:
; update EnSysNX
    lda enNX,x
    sta EnSysNX
    lda enNY,x
    sta EnSysNY

; update stun timer
    lda enStun,x
    cmp #1
    adc #0
    sta enStun,x

; update think timer
    lda enOctorokThink,x
    cmp #1
    adc #0
    sta enOctorokThink,x


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
    lda EnDam_Octorok,x
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

; Movement
    ldx enNum

; What's the plan, octo dad?
    lda enState,x
    and #3
    cmp enDir,x
    bne .spinInPlace

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


.solveNextDirection

    lda #$00
    jsr EnSetBlockedDir2

.testThink
    lda enOctorokThink,x
    beq .newDir

    jsr TestCurDir
    beq .hitWall
    ldx enNum
    bpl .move
.hitWall
.newDir

    jsr NextDir2
    ldx enNum

    jsr En_Octorok_Think

; set spin direction
    lda Rand16
    and #4
    ora enNextDir
    sta Temp0
    lda enState,x
    and #$80
    ora Temp0
    sta enState,x
    jmp .rts ;

.move
    lda enState,x
    rol
    rol
    and Frame
    and #1
    bne .rts
    ldy enDir,x
    jsr EnMoveDirDel2
    jmp .rts


.spinInPlace
    lda Frame
    and #3
    bne .rts
    lda enState,x
    and #4
    sta Temp0
    lda enDir,x
    clc
    adc Temp0
    tay
    lda ENEMY_ROT,y
    sta enDir,x
.rts
    ldx enNum
    lda EnSysNX
    sta enNX,x
    lda EnSysNY
    sta enNY,x
    rts

; Fire Nut logic
/*
    lda Frame
    and #$3F
    bne .skipFire
    lda #1
    sta MiSysAddType
    clc
    lda enX
    adc #3
    sta MiSysAddX
    lda enY
    adc #2
    sta MiSysAddY
    ldy enDir
    lda EN_ATAN2_CARDINAL,y
    jsr MiSpawn
.skipFire
    lda Frame
    and #1
    bne .rts
    jsr EnMoveDirDel
.rts
    rts
*/

En_Octorok_Think: SUBROUTINE
    lda enState,x
    sta Temp0
    lda Rand16
    and #$1F
    adc #$C0
    bit Temp0
    bmi .skipShift
    sec
    ror
.skipShift
    sta enOctorokThink,x
    rts

ENEMY_ROT:
   ;.byte 0, 2, 1, 3 ; enemy direction sprite indices
    .byte 2, 3, 1, 0 ; clockwise
    .byte 3, 2, 0, 1 ; counterclock

EN_ATAN2_CARDINAL:
    .byte DEG_180, DEG_000, DEG_090, DEG_270
    LOG_SIZE "En_Octorok", En_Octorok