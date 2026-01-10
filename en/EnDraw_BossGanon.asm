;==============================================================================
; mzxrules 2025
;==============================================================================

EnDraw_BossGanon: SUBROUTINE
    jsr EnDraw_SmallMissile
    jsr EnDraw_None

    lda #SLOT_RW_F0_BOSS4
    sta BANK_SLOT_RAM

    jsr Boss4_SetPlayerSpr

    lda #COLOR_EN_GANON
    sta wEnColor

EnDraw_BossGanon_SetKernel:
    lda rGanonShow
    bne .Boss4

.GameView:
    lda <#KERNEL_WORLD_RESUME
    sta wWorldKernelDraw
    lda >#KERNEL_WORLD_RESUME
    sta wWorldKernelDraw+1
    lda #HALT_KERNEL_GAMEVIEW
    sta wHaltKernelId

    lda #$80
    sta enY

    lda #%10001
    sta wNUSIZ1_T
    rts

.Boss4
    lda <#KERNEL_BOSS4
    sta wWorldKernelDraw
    lda >#KERNEL_BOSS4
    sta wWorldKernelDraw+1
    lda #HALT_KERNEL_GAMEVIEW_GANON
    sta wHaltKernelId

    lda en0Y
    sta enY

    lda Frame
    and #1
    tax

    jsr GanonFrame
    jsr EnDraw_BossGanon_Boss4Missile

; Calculate what draw kernel to use
    lda enX
    sec
    sbc #$0D
    ; divide by 9
    sta KERNEL_TEMP
    lsr
    lsr
    lsr
    adc KERNEL_TEMP
    ror
    adc KERNEL_TEMP
    ror
    adc KERNEL_TEMP
    ror
    lsr
    lsr
    lsr
    ; result
    sta wGanonKernelId
    rts

GanonFrame: SUBROUTINE
    lda en0X
    clc
    adc .spriteOffTbl,x
    sta enX

    lda .spriteTblL,x
    sec
    sbc enY
    sta enSpr
    lda .spriteTblH,x
    sta enSpr+1
    sta enSpr2+1

    lda .spriteTblL+2,x
    sec
    sbc enY
    sta enSpr2
    rts

.spriteOffTbl:
    .byte #0, #8

.spriteTblL:
    .byte #<SprGanon0 + $30+8, #<SprGanon1 + $30+8
    .byte #<SprGanon2 + $30+8, #<SprGanon3 + $30+8
.spriteTblH:
    .byte #>SprGanon0, #>SprGanon1

EnDraw_BossGanon_Boss4Missile: SUBROUTINE
    lda #$FF
    sta wMISPR_LOC+4
    sta wMISPR_LOC+5

    ldx #0
    lda miType,x
    ror
    bcc .Boss4Missile_end

    lda #<rMISPR_MEM + $51
    sec
    sbc mi0Y,x
    sta enMSpr
    lda #>rMISPR_MEM
    sta enMSpr+1

.Boss4Missile_end
    rts

Boss4_SetPlayerSpr:
; Flush player sprite mem
    ldy rPLSPR_y
    cpy #BOSS4_ROOM_DY_HEIGHT + 8 + 1
    bcs .skip_plspr_wipe

    lda #0
    sta wPLSPR_MEM+0,y
    sta wPLSPR_MEM+1,y
    sta wPLSPR_MEM+2,y
    sta wPLSPR_MEM+3,y
    sta wPLSPR_MEM+4,y
    sta wPLSPR_MEM+5,y
    sta wPLSPR_MEM+6,y
    sta wPLSPR_MEM+7,y
.skip_plspr_wipe

    ldy rPLMSPR_y
    cpy #BOSS4_ROOM_DY_HEIGHT + 8 + 1
    bcs .skip_plmspr_wipe
    lda #0
    sta wPLMSPR_MEM+0+1,y
    sta wPLMSPR_MEM+1+1,y
    sta wPLMSPR_MEM+2+1,y
    sta wPLMSPR_MEM+3+1,y
    sta wPLMSPR_MEM+4+1,y
    sta wPLMSPR_MEM+5+1,y
    sta wPLMSPR_MEM+6+1,y
    sta wPLMSPR_MEM+7+1,y
.skip_plmspr_wipe

    ldx m0Y
    cpx #BOSS4_ROOM_DY_HEIGHT + 8 + 1
    bcs .skip_write_plmspr
    stx wPLMSPR_y
    ldy rM0H
    lda #$FF
.plmspr_write_loop
    sta wPLMSPR_MEM+1,x
    inx
    dey
    bpl .plmspr_write_loop
.skip_write_plmspr
    rts