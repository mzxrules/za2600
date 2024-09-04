;==============================================================================
; mzxrules 2024
;==============================================================================

En_ZolGel: SUBROUTINE
; Setup initial position if offgrid
    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT

.init_fixgrid
    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .init_move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    beq .init_cont

.init_move
    lda enStun,x
    and #$FC
    ora enDir,x
    sta enStun,x
    jsr EnMoveDir
    jmp .init_fixgrid

.init_cont
    lda enGelStepTimer,x
    cmp #1
    adc #0
    sta enGelStepTimer,x
    bne .rts
    lda #-5
    sta enGelStep,x
    sta enGelStep+2,x

    lda #EN_GEL
    sta enType,x

    lda enStun,x
    and #3
    ; move perpendicular to last direction
    eor #2
    sta enDir,x
    eor #1
    sta mi0Dir,x
    lda #0
    sta enStun,x

    lda en0X,x
    sta mi0X,x
    lda en0Y,x
    sta mi0Y,x

    lda #3
    sta enHp,x

    lda #$80
    sta enState,x

    jsr Random
    sta enGelAnim,x

.rts
    rts

En_Gel: SUBROUTINE
    lda enState,x
    bmi .main

    lda #1
    sta enHp,x

    lda #$80
    sta enState,x
    rts

.main
    lda enGelAnim,x
    clc
    adc #$11
    sta enGelAnim,x

.checkDamaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT

    lda enHp,x
    sta enGelHpTemp

    lda #%11
    sta enGelTemp
    jsr HbGetPlAtt
    jsr HbEnSq4
.test_01
    ror enGelHpTemp
    bcc .test_10
    jsr HbPlAttCollide_EnBB
    lda HbFlags2
    bpl .test_10 ; not HB_BOX_HIT
    lda #%10
    sta enGelTemp
.test_10
    ror enGelHpTemp
    bcc .end_checkhit
    lda mi0X,x
    sta Hb_bb_x
    lda mi0Y,x
    sta Hb_bb_y
    jsr HbPlAttCollide
    lda HbFlags2
    bpl .end_checkhit ; not HB_BOX_HIT
    lda #%01
    and enGelTemp
    sta enGelTemp

.end_checkhit
; restore common enemy bank
    lda #SLOT_F0_EN
    sta BANK_SLOT
    lda enHp,x
    and enGelTemp
    sta enHp,x
    bne .endCheckDamaged
    jmp EnSysEnDie ; TODO: disable rng itemdrop
.endCheckDamaged

; Check player hit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bmi .isHit
    bit CXM1P
    bpl .endCheckHit
.isHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit

; Set enNum to double entity index
    lda enNum
    sta enGelNum
    lda enState,x
    sta enGelEnState
; select gel to update this frame
    lda Frame
    ror
    bcc .set_GelNum
    inx
    inx
.set_GelNum
    stx enNum

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

    lda enGelStepTimer,x
    cmp #1
    adc #0
    sta enGelStepTimer,x
    bne .finally

    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

    jsr EnMove_Card_WallCheck
    lda enGelStep,x
    cmp #1
    adc #0
    sta enGelStep,x
    bne .go_direction

    jsr Random
    tay
    and #1
    ora #-4 ; (-3 or -4 for step dist 2 or 3)
    sta enGelStep,x
    tya
    and #$F8
    ora #$E0 ; -32 to -8
    sta enGelStepTimer,x
    lda enGelEnState
    ora GelBitAltern8,x
    sta enGelEnState

    jsr EnMove_Card_NewDir
    sty enDir,x
    bpl .finally ; jmp

.go_direction
    jsr EnMove_Card_RandDirIfBlocked
    sty enDir,x

.move
    jsr EnMoveDir
    lda enGelEnState
    and GelBitAltern8,x
    bne .finally
    jsr EnMoveDir

.finally
    ldx enGelNum
    stx enNum
    lda enGelEnState
    sta enState,x
    rts

GelBitAltern8:
    .byte 1, 1, 2, 2