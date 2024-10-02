;==============================================================================
; mzxrules 2023
;==============================================================================
En_Appear: SUBROUTINE
    lda enState,x
    ror
    bcs .transform
    lda #2
    sta enState,x
    lda #$80
    sta en0Y,x
.skipInit

    lda enSysType,x
    cmp #EN_KEESE
    beq .spawn_keese
    cmp #EN_LEEVER
    beq .fast_spawn
    cmp #EN_WALLMASTER
    beq .fast_spawn
    cmp #EN_TEST
    bcs .fast_spawn

    lda #4
    sta EnSysSpawnTry
    jsr EnRandSpawn
    lda EnSysSpawnTry
    beq .rts
    ldx enNum
; special case for leevers
    lda enSysType,x
    cmp #EN_LEEVER_BLUE
    beq .fast_spawn
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
    ldy #EN_FREE_SIZE-1
    ldx enNum
    bne .entity2
    dey
.entity2
    lda #0
.EnInitLoop:
    sta EN_FREE,y
    dey
    dey
    bpl .EnInitLoop
    jmp En_Del


EnRandSpawnRetry: SUBROUTINE
    dec EnSysSpawnTry
    beq .rts
EnRandSpawn:
    jsr Random
    and #$1F
    tay
    lda room_spawn_x,y
    sta EnSysSpawnX
    tax
    jsr Random
    and #$F
    tay
    lda room_spawn_y,y
    sta EnSysSpawnY

    jsr CheckRoomCol_Unsafe_XA
    bne EnRandSpawnRetry
    ldx enNum
    lda EnSysSpawnX
    asl
    asl
    sta en0X,x
    lda EnSysSpawnY
    asl
    asl
    sta en0Y,x
.rts
    rts
    INCLUDE "gen/roomspawn.asm"


    LOG_SIZE "EnRandSpawn", EnRandSpawnRetry