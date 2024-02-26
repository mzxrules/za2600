;==============================================================================
; mzxrules 2024
;==============================================================================
EN_PEEHAT_INIT = $80
EN_PEEHAT_ANIM = $40

EN_PEEHAT_STOPPED = $00
EN_PEEHAT_RISING  = $01
EN_PEEHAT_FLYING  = $02
EN_PEEHAT_NESTING = $03
EN_PEEHAT_STATE_MASK = $03

En_Peehat: SUBROUTINE
    lda enState,x
    bmi .main

    lda #EN_PEEHAT_INIT + #EN_PEEHAT_RISING
    sta enState,x
    lda #2-1
    sta enHp,x
    lda #$08
    sta enPeehatVel,x
    jsr Random
    and #7
    sta enDir,x
    rts

.main
    lda enState,x
    and #$3
    cmp #EN_PEEHAT_RISING
    beq .state_rise
    cmp #EN_PEEHAT_NESTING
    beq .state_fall

    lda Frame
    and #$7
    bne .skip_timer_lengthen
    lda enPeehatFlyThink,x
    sec
    sbc #$7
    sta enPeehatFlyThink,x

.skip_timer_lengthen
    lda enPeehatFlyThink,x
    cmp #1
    adc #0
    sta enPeehatFlyThink,x
    bne .battle_logic
    ldy enState,x
    iny ; advance to next state
    sty enState,x
    bmi .battle_logic ; JMP

.state_rise
    lda enPeehatVel,x
    clc
    adc #$01
    sta enPeehatVel,x
    bpl .battle_logic
    ; randomly rise between 16 and 48  x8 frames
    jsr Random
    and #31 ;
    sec
    sbc #49 ; 1 more for good measure
    sta enPeehatFlyThink,x
    ldy enState,x
    iny ; advance to next state
    sty enState,x
    bmi .battle_logic ; JMP

.state_fall
    lda enPeehatVel,x
    sec
    sbc #$01
    sta enPeehatVel,x
    bne .battle_logic
    lda #$E8
    sta enPeehatFlyThink,x
    lda enState,x
    and #~EN_PEEHAT_STATE_MASK
    sta enState,x


.battle_logic
; check damaged
    lda enPeehatVel,x
    bne .updateStunTimer

    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT

    lda enHp,x
    bpl .endCheckDamaged
    jmp EnSysEnDie
.updateStunTimer
    lda enStun,x
    clc
    adc #4
    bmi .skip_zero_enStun
    lda #0
.skip_zero_enStun
    sta enStun,x
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

.movement
    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT

    lda enPeehatThink,x
    bne .endThink

    jsr Random
    and #7
    sta enDir,x
    lda Rand16
    and #$1F
    adc #$D8
    sta enPeehatThink,x
    ;bmi .endThink ; jmp
.endThink

; bounceTest
    lda en0X,x
    cmp #EnBoardXL
    bcc .bounce
    cmp #EnBoardXR
    bcs .bounce
    lda en0Y,x
    cmp #EnBoardYD
    bcc .bounce
    cmp #EnBoardYU
    bcc .movement_logic_cont
.bounce
    jsr EnMove_Ord_SetSeekCenter

.movement_logic_cont
    lda enPeehatVel,x
    clc
    adc enPeehatSpeedFrac,x
    sta enPeehatSpeedFrac,x
    bcc .skip_move

    lda enPeehatThink,x
    cmp #1
    adc #0
    sta enPeehatThink,x

    lda enState,x
    eor #EN_PEEHAT_ANIM
    sta enState,x

    lda enDir,x
    and #7
    tay
    jmp EnMoveDel


.skip_move
    rts