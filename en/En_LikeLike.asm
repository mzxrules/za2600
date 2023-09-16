;==============================================================================
; mzxrules 2021
;==============================================================================
EN_LIKELIKE_LOCK = #$40
EN_LIKELIKE_THINK = #$01
En_LikeLike: SUBROUTINE
    lda #EN_LIKE_LIKE_MAIN
    sta enType,x

    lda #6 -1
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

    rts

En_LikeLikeMain: SUBROUTINE
; update stun timer
    lda enStun,x
    cmp #1
    adc #0
    sta enStun,x

.checkDamaged
; if collided with weapon && stun == 0,
    lda enStun,x
    cmp #-8
    bmi .endCheckDamaged

    lda #SLOT_BATTLE
    sta BANK_SLOT
    jsr HbGetPlAtt
    jsr HbPlAttCollide_EnBB

; Get damage
    ldy HbDamage
    lda EnDam_Rope,y
    sta Temp0

    lda #SLOT_EN_A
    sta BANK_SLOT
    lda HbFlags
    beq .endCheckDamaged

.gethit
    lda Temp0 ; fetch damage
    ldy #-32
    sty enStun,x
    ldy #SFX_EN_DAMAGE
    sty SfxFlags
    clc
    adc enHp,x
    sta enHp,x
    bpl .endCheckDamaged
    lda plState
    and #~PS_LOCK_MOVE
    sta plState
    jmp EnSysEnDie
.endCheckDamaged

    ; Check if player was sucked in
    lda enState,x
    and #EN_LIKELIKE_LOCK
    beq .playerhit

.lockInPlace
    lda plState
    ora #PS_LOCK_MOVE
    sta plState

    lda Frame
    and #$3F
    cmp enLLTimer,x
    bne .skipSuccDamage
    lda #-8
    jsr UPDATE_PL_HEALTH
.skipSuccDamage

    lda en0X,x
    sta plX
    lda en0Y,x
    sta plY
    rts

.playerhit
    ; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit CXPPMM
    bpl .endCheckHit
    lda #-8
    jsr UPDATE_PL_HEALTH
    lda plState
    and #PS_LOCK_MOVE
    bne .endCheckHit

    lda enState,x
    ora #EN_LIKELIKE_LOCK
    sta enState,x
    lda Frame
    and #$3F
    sta enLLTimer,x
.endCheckHit

; Movement Routine
    lda #SLOT_EN_MOV
    sta BANK_SLOT

    lda enLLThink,x
    cmp #1
    adc #0
    sta enLLThink,x

; update EnMoveNX
    lda enNX,x
    sta EnMoveNX
    lda enNY,x
    sta EnMoveNY

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

    lda enLLThink,x
    bne .contdir

.newdir
    jsr EnMov_Card_NewDir
    bpl .setNewDir

.contdir
    jsr EnMov_Card_ContDir
    tya
    cmp enDir,x
    beq .move

.setNewDir
    sty enDir,x
    lda Rand16
    and #$1F
    adc #$D0
    sta enLLThink,x

.move
    lda Frame
    and #1
    bne .rts
    jsr EnMoveDir
.rts
    rts

    LOG_SIZE "En_LikeLike", En_LikeLike