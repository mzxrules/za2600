;==============================================================================
; mzxrules 2024
;==============================================================================

;==============================================================================
; Sets position and color variables, overriding with stun colors
; Y = Color Index
; X = EnNum
;==============================================================================
EnDraw_PosAndStunColor: SUBROUTINE
    lda worldId
    beq .fetchColor
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

EnDraw_Arrow: SUBROUTINE
EnDraw_SmallMissile: SUBROUTINE
    lda miType,x
    bpl .rts

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
    .byte COLOR_EN_RED,     COLOR_EN_RED_L
    .byte COLOR_EN_GREEN,   COLOR_EN_GREEN
    .byte COLOR_EN_BLUE,    COLOR_EN_BLUE_L
    .byte COLOR_EN_YELLOW,  COLOR_EN_YELLOW_L
    .byte COLOR_EN_WHITE,   COLOR_EN_WHITE
    .byte COLOR_EN_BLACK,   COLOR_EN_RED