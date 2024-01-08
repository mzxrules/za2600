;==============================================================================
; mzxrules 2021
;==============================================================================
EN_OCTOROK_SPIN = $08
EN_OCTOROK_RARE = $80

En_OctorokBlue: SUBROUTINE
    lda enState,x
    ora #EN_OCTOROK_RARE
    sta enState,x

En_Octorok: SUBROUTINE
    lda #EN_OCTOROK_MAIN
    sta enType,x
    jsr Random

    and #3
    sta enDir,x
    ora enState,x
    sta enState,x

    lda #2 -1
    sta enHp,x

    jmp En_Octorok_Think

En_OctorokMain:
; check damaged
    lda #SLOT_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_EN_A
    sta BANK_SLOT
    lda enHp,x
    bpl .endCheckDamaged
    jmp EnSysEnDie
.endCheckDamaged

; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit

; Movement
    lda #SLOT_EN_MOV
    sta BANK_SLOT

; update EnMoveNX/NY
    lda en0X,x
    lsr
    lsr
    sta EnMoveNX
    lda en0Y,x
    lsr
    lsr
    sta EnMoveNY

; check recoil movement
    lda enState,x
    and #EN_ENEMY_MOVE_RECOIL
    beq .normal_movement
    jmp EnMov_Recoil

.normal_movement

; What's the plan, octo dad?
    lda enState,x
    and #3
    cmp enDir,x
    bne .spinInPlace

    ldy en0X,x
    lda en_offgrid_lut,y
    bne .move
    ldy en0Y,x
    lda en_offgrid_lut,y
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