;==============================================================================
; mzxrules 2023
;==============================================================================
En_Appear: SUBROUTINE
    lda enState,x
    ror
    bcs .transform
    lda #2
    sta enState,x
.skipInit

    lda enSysType,x
    cmp #EN_KEESE
    beq .spawn_keese
    cmp #EN_WALLMASTER
    beq .fast_spawn
    cmp #EN_ROLLING_ROCK
    beq .fast_spawn
    cmp #EN_TEST_COLOR
    beq .fast_spawn

    lda #4
    sta EnSysSpawnTry
    jsr EnRandSpawn
    lda EnSysSpawnTry
    beq .rts
    ldx enNum
.set_fuzz
    lda #3
    sta enState,x

    jsr Random
    and #$1F
    adc #$D1
    sta enSysTimer,x

.rts
    rts
.spawn_keese
    ; Enemy Board Width = $40 (0-$3F)
    ; Enemy Board Height = $38 (0-$37)

    jsr Random
    and #$3C
    clc
    adc #EnBoardXL + 8
    cmp #$4C + 1
    bcc .setX
    lda #EnBoardXL + 8 + $1E
.setX
    sta en0X,x
    jsr Random
    and #$1C
    clc
    adc #$0C + EnBoardYD
    sta en0Y,x
    jmp .set_fuzz


.transform

;   update spawn delay
    lda enSysTimer,x
    cmp #1
    adc #0
    sta enSysTimer,x
    bmi .rts

    lda enSysType,x
.fast_spawn
    sta enType,x

    ; zero entity variable data
    ldy #EN_VARS_COUNT-1
    ldx enNum
    bne .entity2
    dey
.entity2
    lda #0
.EnInitLoop:
    sta EN_VARS,y
    dey
    dey
    bpl .EnInitLoop
    jmp En_Del


EnRandSpawnRetry: SUBROUTINE
    dec EnSysSpawnTry
    beq .rts
EnRandSpawn:
    jsr Random
    and #$7 ; y pos mask
    cmp #7
    bne .skipYShift
    lsr
.skipYShift
    asl
    tay      ; y pos * 2
    lda #$18 ; x pos mask
    and Rand16
    lsr
    lsr
    lsr
    tax
    lda rPF2Room+2+1,y
    ora rPF2Room+2+2,y
    and EnSpawnPF2Mask,x
    bne EnRandSpawnRetry
    tya
    asl
    asl ; y * 4 (* 8 total)
    clc
    adc #$14
    ldy enNum
    sta en0Y,y
    lda Mul8,x
    bit Rand16
    bmi .skipInvert
    eor #$FF
    sec
    adc #0
.skipInvert
    clc
    adc #$40
    sta en0X,y
.rts
    rts

EnSpawnPF2Mask:
    .byte $80, $60, $18, $06

    LOG_SIZE "EnRandSpawn", EnRandSpawnRetry