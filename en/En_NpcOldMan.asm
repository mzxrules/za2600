;==============================================================================
; mzxrules 2021
;==============================================================================

En_NpcOldMan: SUBROUTINE
    lda #$40
    sta enX
    lda #$38
    sta enY

    lda roomFlags
    and #RF_EV_LOAD
    bne .skipSetPos
    lda #$30
    cmp plY
    bpl .skipSetPos
    sta plY
.skipSetPos
.rts
    rts

En_NpcMonster:
    bit roomFlags
    bmi .rts ; RF_EV_LOAD

    bit enState
    bmi .main
.init
    lda #$E8
    sta enNpcMonsterTimer
    lda #$80
    sta enState
    rts

.main
    bvc .main_continue
    inc enNpcMonsterTimer
    bne .rts
.kill
    lda #0
    sta enType
    sta mesgId
    sta KernelId
    rts

.main_continue
    lda plState3
    and #PS_ACTIVE_ITEM2
    cmp #PLAYER_MEAT_FX
    bne .end
    lda plItem2Time
    beq .end

    lda #$C0
    sta enState

    lda #$E8
    sta plItem2Time

    lda #0
    sta mesgId
    sta KernelId
    sta roomRS

    lda roomId
    and #$7F
    tay
    lda rRoomFlag,y
    ora #RF_SV_ITEM_GET
    sta wRoomFlag,y

    lda ITEMV_MEAT
    and #~ITEMF_MEAT
    sta ITEMV_MEAT

    lda #SFX_SOLVE
    sta SfxFlags

.end
    jmp En_NpcOldMan