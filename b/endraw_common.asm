;==============================================================================
; mzxrules 2024
;==============================================================================

; EnWeaponWidth
EnWeaponWidth_4px_thick:
    .byte $20, $20, $10, $10
EnWeaponWidth_8px_thick:
    .byte $30, $30, $10, $10
EnWeaponWidth_4px_thin:
    .byte $20, $20, $00, $00
EnWeaponWidth_8px_thin:
    .byte $30, $30, $00, $00

; EnWeaponHeight
EnWeaponHeight_4px_thick:
    .byte 1, 1, 3, 3
EnWeaponHeight_8px_thick:
    .byte 1, 1, 7, 7
EnWeaponHeight_4px_thin:
    .byte 0, 0, 3, 3
EnWeaponHeight_8px_thin:
    .byte 0, 0, 7, 7

; EnWeaponOffX  ; Drawn displacement from mi0X
EnWeaponOffX_4px_thick:
    .byte 2+1, 2+1, 3+1, 3+1
EnWeaponOffX_8px_thin:
    .byte 0+1, 0+1, 4+1, 4+1

; EnWeaponOffY  ; Drawn displacement from mi0Y
EnWeaponOffY_4px_thick:
    .byte 3, 3, 2, 2
EnWeaponOffY_8px_thin:
    .byte 4, 4, 0, 0

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
EnDraw_Sword: SUBROUTINE
    lda miType,x
    ror
    bcc .rts
    ldy mi0Dir,x

    lda rNUSIZ1_T
    ora EnWeaponWidth_4px_thick,y
    sta wNUSIZ1_T

    lda EnWeaponHeight_4px_thick,y
    sta wM1H
    clc
    lda mi0X,x
    adc EnWeaponOffX_4px_thick,y
    sta m1X
    clc
    lda mi0Y,x
    adc EnWeaponOffY_4px_thick,y
    sta m1Y

.rts
    rts

EnDraw_Arrow: SUBROUTINE
    lda miType,x
    ror
    bcc .rts
    ldy mi0Dir,x

    lda rNUSIZ1_T
    ora EnWeaponWidth_8px_thin,y
    sta wNUSIZ1_T

    lda EnWeaponHeight_8px_thin,y
    sta wM1H
    clc
    lda mi0X,x
    adc EnWeaponOffX_8px_thin,y
    sta m1X
    clc
    lda mi0Y,x
    adc EnWeaponOffY_8px_thin,y
    sta m1Y
.rts
    rts

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


EnDraw_GoriyaColors:
EnDraw_DarknutColors:
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