;==============================================================================
; mzxrules 2024
;==============================================================================
EN_POLS_STATE_BOUNCE = #%001
EN_POLS_STATE_NEWDIR = #%100

; Movement notes:
; walls critical, must turn back when reached
; everything else forces a jump

En_Pols: SUBROUTINE
    lda enState,x
    bmi .main
    lda #$80
    sta enState,x
    lda #10-1
    sta enHp,x

    jsr Random
    and #3
    sta enDir,x

    jsr Random
    and #$F
    sta enPolsStep,x
    rts

.main
; check damaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT

    lda enHp,x
    bpl .endCheckDamaged
    jmp EnSys_KillEnemyB
.endCheckDamaged

; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda #-16
    jsr UPDATE_PL_HEALTH
.endCheckHit

; Adjust en0Y for room collision routines
    lda en0Y,x
    sec
    sbc enPolsShiftY,x
    sta en0Y,x

; Movement
    lda #SLOT_F0_EN_MOVE
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

.normal_movement
    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

    dec enPolsStep,x
    bpl .keep_going
    lda enState,x
    ora #EN_POLS_STATE_NEWDIR
    sta enState,x
.keep_going

    jsr EnMove_Card_BorderCheck

    lda enPolsShiftY,x
    beq .state_grounded

.state_bouncing
    jsr EnPols_OppositeDirIfBlocked
    jmp .move


.state_grounded

.state_grounded_test_pos
; Check if current position is blocked

    jsr EnMove_Card_RoomCheck
    beq .state_grounded_test_seekdir
    lda enState,x
    ora #EN_POLS_STATE_BOUNCE
    sta enState,x
    and #EN_POLS_STATE_NEWDIR
    bne .rand_dir_if_blocked

.state_grounded_test_seekdir
; Check if next position is blocked
    ldy enDir,x
    lda EnMoveNX
    clc
    adc EnMoveDeltaX,y
    tax

    lda EnMoveNY
    clc
    adc EnMoveDeltaY,y

    jsr EnMove_Card_RoomCheck
    beq .state_grounded_test_newdir
    lda enState,x
    ora #EN_POLS_STATE_BOUNCE
    sta enState,x
    jmp .seek_next

.state_grounded_test_newdir
    lda enState,x
    and #EN_POLS_STATE_NEWDIR
    beq .seek_next

; Add a random bounce
    jsr Random
    cmp #32
    bcs .rand_dir_if_blocked
    lda enState,x
    ora #EN_POLS_STATE_BOUNCE
    sta enState,x


.rand_dir_if_blocked
    jsr Random
    and #$F
    adc #2
    sta enPolsStep,x

    lda enState,x
    and #~#EN_POLS_STATE_NEWDIR
    sta enState,x

    jsr EnMove_Card_RandDir
    sty enDir,x
    bpl .move

.seek_next
    jsr EnPols_OppositeDirIfBlocked
.move
    lda Frame
    and #1
    bne .handle_bouncey
    jsr EnMoveDir


.handle_bouncey
    lda enState,x
    ror
    bcc .downY
.upY
    ldy enPolsShiftY,x
    iny
    sty enPolsShiftY,x
    cpy #16
    bne .end_bouncey
    lda #$80
    sta enState,x
    jmp .end_bouncey
.downY
    ldy enPolsShiftY,x
    beq .end_bouncey
    dec enPolsShiftY,x

.end_bouncey

; Revert en0Y adjustment for display and hitbox purposes
    lda en0Y,x
    clc
    adc enPolsShiftY,x
    sta en0Y,x
    rts

EnPols_OppositeDirIfBlocked: SUBROUTINE
    ldy enDir,x
    lda Bit8,y
    and EnMoveBlockedDir
    beq .rts
    tya
    eor #1
    sta enDir,x

    jsr Random
    and #$F
    adc #2
    sta enPolsStep,x

    lda enState,x
    and #~#EN_POLS_STATE_NEWDIR
    sta enState,x

.rts
    rts