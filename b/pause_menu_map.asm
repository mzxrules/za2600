Pause_PlotMap: SUBROUTINE
    lda #SLOT_F4_SPR_HUD
    sta BANK_SLOT

    ldx worldId

; select line to update
    lda Frame
    and #7

; compute start room
    asl
    asl
    asl
    asl
    clc
    adc MapData_RoomOffsetX+0x400-#LV_MIN,x
    and #$7F
    sta PMapRoom

; fetch current world data
    ldy .WorldData_BankOffset-#LV_MIN,x
    lda .WorldData_WorldRomSlot,y
    sta BANK_SLOT

; compute visited rooms and room links
    ldy PMapRoom
    dey
    ldx #7
.visit_room_loop
    iny
    bpl .cont
    ldy #0
.cont
    lda rWorldRoomFlags,y
    and #WRF_SV_VISIT
    clc
    beq .visit_room_false
    sec
.visit_room_false
    rol PMapRoomVisit

.room_link_loop
; NORTH
    clc
    lda rWorldRoomFlags,y
    and #WRF_SV_OPEN_N
    bne .path_n_true
    lda WORLD_T_PF1L,y
    and #%00000110
    bne .path_n_false
.path_n_true
    sec
.path_n_false
    rol PMapRoomN
; SOUTH
    clc
    lda rWorldRoomFlags,y
    and #WRF_SV_OPEN_S
    bne .path_s_true
    lda WORLD_T_PF1L,y
    and #%1000
    bne .path_s_false
    lda WORLD_T_PF2,y
    and #%0100
    bne .path_s_false
.path_s_true
    sec
.path_s_false
    rol PMapRoomS
; EAST
    clc
    lda rWorldRoomFlags,y
    and #WRF_SV_OPEN_E
    bne .path_e_true
    lda WORLD_T_PF2,y
    and #%1000
    bne .path_e_false
    lda WORLD_T_PF1R,y
    and #%0010
    bne .path_e_false
.path_e_true
    sec
.path_e_false
    rol PMapRoomE
; WEST
    clc
    lda rWorldRoomFlags,y
    and #WRF_SV_OPEN_W
    bne .path_w_true
    lda WORLD_T_PF1R,y
    and #%1100
    bne .path_w_false
.path_w_true
    sec
.path_w_false
    rol PMapRoomW

    dex
    bpl .visit_room_loop

; use map texture to only include current dungeon rooms
    lda #SLOT_F4_SPR_HUD
    sta BANK_SLOT

; invert y cursor and setup for memory wipe
    lda Frame
    and #7
    tay

; Y == map y
    ldx worldId
    lda Mul8-#LV_MIN,x
    clc
    adc .Invert8,y
    tax
    lda PMapRoomVisit
    and MINIMAP+0x400,x
    sta PMapRoomVisit

    ldx #3
.set_loop
    lda PMapRoomN,x
    and PMapRoomVisit
    sta PMapRoomN,x
    dex
    bpl .set_loop

.path_up_loop_end

    lda .Invert8Mul5,y
    tay
    lda #SLOT_F4_PAUSE_MENU_MAP
    sta BANK_SLOT
    jmp Pause_PlotMapRow

    INCLUDE "WorldData_WorldRomSlot.asm"

.Invert8:
    .byte 7, 6, 5, 4
    .byte 3, 2, 1, 0

.Invert8Mul5:
    .byte 35, 30, 25, 20
    .byte 15, 10,  5,  0
