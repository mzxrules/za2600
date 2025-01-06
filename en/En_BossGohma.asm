;==============================================================================
; mzxrules 2022
;==============================================================================

En_BossGohmaBlue: SUBROUTINE
En_BossGohma: SUBROUTINE
    bit enState
    bmi .main
    lda #$40
    sta en0X
    sta en0Y
    lda #[$80 | #GOHMA_ANIM_0]
    sta enState

    ldx #0
    lda enType
    cmp #EN_BOSS_GOHMA
    beq .setStats
    inx
.setStats
    lda En_BossGohma_CiColor,x
    sta enGohmaCiColor
    lda En_BossGohma_Hp,x
    sta enHp

    jsr Random
    ora #$80
    sta enGohmaTimer

    jsr En_BossGohma_SetFireTimer
    jmp En_BossGohma_SetStep

.main
; Weapon Detection

    lda enStun
    clc
    adc #4
    bmi .stun_timer_update
    lda #0
.stun_timer_update
    sta enStun
    bmi .endWeaponCollision
    lda CXM0P
    bpl .endWeaponCollision
    lda plState2
    and #PS_ACTIVE_ITEM
    eor #PLAYER_ARROW
    bne .defSfx
.arrowCollision
    lda plItemDir
    eor #PL_DIR_U
    bne .defSfx
    lda enState
    and #7
    eor #GOHMA_ANIM_2
    bne .defSfx

; Check X hit
    lda m0X
    sec
    sbc #4
    sbc en0X
    cmp #9
    bcs .endWeaponCollision

; Check y hit
    lda m0Y
    sec
    sbc #$100-7
    sec
    sbc en0Y
    cmp #4
    bcs .endWeaponCollision
    lda #$80
    sta m0Y
    lda #EN_STUN_TIME
    sta enStun
    dec enHp
    bpl .endWeaponCollision

    ldx enNum
    jsr EnSysRoomKill
    jmp EnSys_KillEnemyB

.defSfx
    lda #SFX_EN_DEF
    sta SfxFlags

.endWeaponCollision

; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit CXPPMM
    bpl .endCheckHit
    lda #-24
    jsr UPDATE_PL_HEALTH
.endCheckHit

; handle firing
    dec enGohmaFire
    bpl .endFire
    jsr En_BossGohma_SetFireTimer
    lda #GOHMA_FIRE
    jsr En_BossGohma_ToggleFlag
    ldx #0
    and #GOHMA_FIRE
    beq .fire0
.fire1
    inx
.fire0
    SET_A_miType #MI_SPAWN_BALL, -8
    sta miType,x
    lda en0X
    clc
    adc #8-4
    sta mi0X,x
    lda en0Y
    sec
    sbc #4
    sta mi0Y,x
.endFire

; update animation state
    dec enGohmaTimer
    bne .endAnimStateChange

    clc
    lda enState
    adc #2
    and #~$08
    sta enState

    and #7
    lsr
    tay

    lda En_BossGohma_AnimTimer,y
    sta enGohmaTimer
.endAnimStateChange

; movement
    lda Frame
    ror
    bcc .rts

    lda en0Y
    cmp #40
    bcc .move_du

    lda en0X
    and #3
    bne .endStep
    dec enGohmaStep
    bmi .move_du
.endStep

.move_rl
    bit enState ; #GOHMA_MOVE_R
    bvc .left
.right
    inc en0X
    lda en0X
    cmp #$5C
    bne .rts
    lda #GOHMA_MOVE_R
    jmp En_BossGohma_ToggleFlag
.left
    dec en0X
    lda en0X
    cmp #$24
    bne .rts
    lda #GOHMA_MOVE_R
    jmp En_BossGohma_ToggleFlag

.move_du
    lda enState
    and #GOHMA_MOVE_U
    bne .up
.down
    dec en0Y
    lda en0Y
    cmp #$14
    bne .rts
    lda #GOHMA_MOVE_U
    jmp En_BossGohma_ToggleFlag
.up
    inc en0Y
    lda en0Y
    cmp #$40
    bne .rts
    lda #GOHMA_MOVE_U
    jsr En_BossGohma_ToggleFlag
    jmp En_BossGohma_SetStep


; A returns enState
En_BossGohma_ToggleFlag:  ; SUBROUTINE
    eor enState
    sta enState
.rts
    rts

En_BossGohma_SetFireTimer: SUBROUTINE
    jsr Random
    and #$3F
    adc #20
    sta enGohmaFire
    rts

En_BossGohma_SetStep: SUBROUTINE
    jsr Random
    and #$1F
    adc #2
    sta enGohmaStep
    rts


En_BossGohma_CiColor
    .byte #CI_EN_YELLOW, #CI_EN_BLUE
En_BossGohma_Hp
    .byte #1-1, #3-1

En_BossGohma_AnimTimer:
    .byte $0, $20, $60, $20
    LOG_SIZE "En_BossGohma", En_BossGohma