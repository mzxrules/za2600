;==============================================================================
; mzxrules 2024
;==============================================================================

;==============================================================================
; Sets position and color variables, overriding with stun colors
; Y = Color Index
; X = EnNum
;==============================================================================
EnDraw_PosAndStunColor: SUBROUTINE
    lda rBgColor
    cpy #CI_EN_BLACK
    beq .test_ci_en_black
.test_all
    cmp #COLOR_PF_PATH
    beq .set_all_altcolor
    cmp #COLOR_PF_GRAY_D
    bne .fetchColor
.set_all_altcolor
    iny
    bpl .fetchColor ;jmp
.test_ci_en_black
    cmp #COLOR_PF_BLACK
    bne .fetchColor
    iny
.fetchColor
    lda EnDrawColor_LUT,y
    sta EnDrawColor
    lda enStun,x
    asl
    asl
    adc EnDrawColor
    sta wEnColor

EnDraw_Pos: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY
    rts

EnDraw_Wave: SUBROUTINE
EnDraw_Arrow: SUBROUTINE
EnDraw_SmallMissile: SUBROUTINE
    lda miType,x
    ror
    bcc .rts
EnDraw_Gel2:
    clc
    lda mi0X,x
    adc #3+1
    sta m1X
    clc
    lda mi0Y,x
    adc #3
    sta m1Y

; 2x2 missile
    lda #1
    sta wM1H
    lda rNUSIZ1_T
    ora #%10000
    sta wNUSIZ1_T
.rts
    rts


EnDraw_GoriyaColor:
EnDraw_DarknutColor:
EnDraw_OctorokColors:
EnDraw_TektiteColors:
EnDraw_LeeverColors:
    .byte #CI_EN_RED, #CI_EN_BLUE

EnDraw_MoblinColors:
    .byte #CI_EN_RED, #CI_EN_BLUE

EnDrawColor_LUT:
    .byte COLOR_EN_RED_L,       COLOR_EN_RED
    .byte COLOR_EN_GREEN,       COLOR_EN_GREEN
    .byte COLOR_EN_BLUE_L,      COLOR_EN_BLUE
    .byte COLOR_EN_YELLOW_L,    COLOR_EN_YELLOW
    .byte COLOR_EN_WHITE,       COLOR_EN_WHITE
    .byte COLOR_EN_BLACK,       COLOR_EN_RED