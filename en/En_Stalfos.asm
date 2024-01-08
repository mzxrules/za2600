;==============================================================================
; mzxrules 2023
;==============================================================================

En_Stalfos: SUBROUTINE
    lda enState,x
    rol
    bcs .main
    lda #$80
    sta enState,x
    lda #1
    sta enHp,x

    jsr Random
    and #3
    sta enDir,x

    jsr Random
    and #7
    sta enDarknutStep,x
    rts

.main
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
    ldy en0X,x
    lda en_offgrid_lut,y
    bne .move
    ldy en0Y,x
    lda en_offgrid_lut,y
    bne .move

    dec enDarknutStep,x
    bpl .seek_next
    jsr Random
    and #7
    sta enDarknutStep,x

    jsr EnMov_Card_WallCheck
    jsr EnMov_Card_RandDir
    sty enDir,x
    bpl .move

.seek_next
    jsr EnMov_Card_WallCheck
    jsr EnMov_Card_RandDirIfBlocked
    sty enDir,x
.move
    lda Frame
    and #1
    bne .rts
    jsr EnMoveDir
.rts
    rts