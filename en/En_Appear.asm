;==============================================================================
; mzxrules 2023
;==============================================================================
EN_APPEAR_TRANSFORM = $01

En_Appear: SUBROUTINE
    lda enState,x
    ror
    bcs .transform
    lda #$80
    sta en0Y,x
.skipInit

    lda enSysType,x
    cmp #EN_KEESE
    beq .spawn_keese
    cmp #EN_LEEVER
    beq .instant_spawn
    cmp #EN_WALLMASTER
    beq .instant_spawn
    cmp #EN_TEST
    bcs .instant_spawn

    lda #3
    sta EnSysSpawnTry
    jsr EnRandSpawn
    lda EnSysSpawnTry
    beq .rts
    ldx enNum
; special case for leevers
    lda enSysType,x
    cmp #EN_LEEVER_BLUE
    beq .instant_spawn
.begin_appear_spawn
; quick-spawn if room just loaded
    ldy roomTimer
    bmi .instant_spawn
.set_fuzz
    lda #EN_APPEAR_TRANSFORM
    sta enState,x

    jsr Random
    and #$18
    ora #$C7
.quick_spawn
    sta enSysTimer,x
.rts
    rts
.spawn_keese ; keese are $28 units wide

    jsr Random
    and #3
    tay
    lda En_AppearKeeseSpawnX,y
    sta en0X,x
    lda Frame
    and #3
    tay
    lda En_AppearKeeseSpawnY,y
    sta en0Y,x
; safety check player overlap
    clc
    sbc plY
    sbc #8-1
    adc #8+8-1
    bcc .begin_appear_spawn
    clc
    lda en0X,x
    sbc plX
    sbc #8-1
    adc #$28+8-1
    bcs .set_fuzz
    bcc .begin_appear_spawn


.transform
;   update spawn delay
    lda enSysTimer,x
    cmp #1
    adc #0
    sta enSysTimer,x
    bmi .rts

.instant_spawn
    lda enSysType,x
    sta enType,x

    ; zero entity variable data
    ldx enNum
    ldy .freeloop_index_start,x
    lda #0
.EnInitLoop:
    sta EN_FREE,y
    dey
    dey
    bpl .EnInitLoop
    jmp En_Del

.freeloop_index_start
    .byte #EN_FREE_SIZE-2, #EN_FREE_SIZE-1

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

    lda EnSysSpawnY
    asl
    asl
    sta EnSysSpawnY

    lda EnSysSpawnX
    asl
    asl
    sta EnSysSpawnX

; Ball bounds check
; assume 8x8 ball; room collision will catch 8x12 ball checks
    clc
;   lda EnSysSpawnX
    sbc blX
    sbc #8-1
    adc #8+8+1
    bcc .no_ball_overlap
    clc
    lda EnSysSpawnY
    sbc blY
    sbc #8-1
    adc #8+8+1
    bcs EnRandSpawnRetry
.no_ball_overlap

; Player bounds check
; Add a buffer around the player blocking spawns
PL_SAFE = 12
PL_SAFE_W = #PL_SAFE * 2 + 8
    lda plX
    adc #-#PL_SAFE
    clc
    sbc EnSysSpawnX
    sbc #8-1
    adc #PL_SAFE_W+8-1
    bcc .no_player_safebounds_overlap
    clc
    lda plY
    adc #-#PL_SAFE
    clc
    sbc EnSysSpawnY
    sbc #8-1
    adc #PL_SAFE_W+8-1
    bcs EnRandSpawnRetry

.no_player_safebounds_overlap
    ldx enNum
    lda EnSysSpawnX
    sta en0X,x
    lda EnSysSpawnY
    sta en0Y,x
.rts
    rts
    INCLUDE "gen/roomspawn.asm"

En_AppearKeeseSpawnX:
    .byte #$1C, #$40, #$2C, #$34

En_AppearKeeseSpawnY:
    .byte #$1C, #$3C, #$24, #$34


    LOG_SIZE "EnRandSpawn", EnRandSpawnRetry