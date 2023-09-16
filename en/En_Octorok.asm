;==============================================================================
; mzxrules 2021
;==============================================================================
EN_OCTOROK_SPIN = $08
EN_OCTOROK_RARE = $80
En_Octorok: SUBROUTINE
    lda #EN_OCTOROK_MAIN
    sta enType,x
    jsr Random

    and #3
    sta enDir,x
    sta enState,x
    lda Rand16
    and #7
    bne .commonType

    lda enState,x
    ora #EN_OCTOROK_RARE
    sta enState,x

.commonType
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
    jsr HbGetPlAtt
    jsr HbPlAttCollide_EnBB

; Get damage
    ldy HbDamage
    lda EnDam_Octorok,y
    sta Temp0

    lda #SLOT_EN_A
    sta BANK_SLOT
    lda HbFlags
    beq .endCheckDamaged

.gethit
    lda Temp0 ; fetch damage
    ldy #-32
    sty enStun,x
    clc
    adc enHp,x
    sta enHp,x
    bpl .endCheckDamaged
    jmp EnSysEnDie
.defSfx
    lda #SFX_DEF
    sta SfxFlags
.endCheckDamaged

; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit CXPPMM
    bpl .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit

; Movement
    lda #SLOT_EN_MOV
    sta BANK_SLOT

; update EnMoveNX
    lda enNX,x
    sta EnMoveNX
    lda enNY,x
    sta EnMoveNY

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
    jsr EnMov_Card_WallCheck

    lda enOctorokThink,x
    beq .newDir

    jsr EnMov_Card_RandDirIfBlocked
    tya
    cmp enDir,x
    beq .move
    bne .setNewDir ; jmp

.newDir
    jsr EnMov_Card_NewDir

.setNewDir
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
    rts

.move
    ldx enNum
    lda enState,x
    rol
    rol
    rol
    ora #1
    and Frame
    and #3
    beq .rts
    jsr EnMoveDir

; update think timer
    lda enOctorokThink,x
    cmp #1
    adc #0
    sta enOctorokThink,x
    rts


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
    sta mi0Dir,x
    lda #1
    sta miType,x
    lda en0X,x
    sta mi0X,x
    lda en0Y,x
    sta mi0Y,x
.rts
    rts

En_Octorok_Think: SUBROUTINE
    lda Rand16
    and #$1F
    adc #$D8
    sta enOctorokThink,x
    rts

ENEMY_ROT:
   ;.byte 0, 2, 1, 3 ; enemy direction sprite indices
    .byte 2, 3, 1, 0 ; clockwise
    .byte 3, 2, 0, 1 ; counterclock

;EN_ATAN2_CARDINAL:
;    .byte DEG_180, DEG_000, DEG_090, DEG_270
    LOG_SIZE "En_Octorok", En_Octorok