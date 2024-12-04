Pause_Menu_Map: SUBROUTINE
    ldx worldId
    ldy .WorldData_BankOffset-#LV_MIN,x
    lda .WorldData_WorldRomSlot,y
    sta BANK_SLOT

; select line to update
    lda Frame
    and #7

; compute start room
    asl
    asl
    asl
    asl
    clc
    adc MapData_RoomOffsetX-#LV_MIN,x
    sta PMapRoom

; compute visited rooms and room links
    tay
    ldx #7
.visit_room_loop
    tya
    and #$7F
    tay
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

    iny
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
    adc Pause_Invert,y
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

    lda Pause_InvertMul5,y
    tay
    lda #SLOT_F4_PAUSE_MENU_MAP
    sta BANK_SLOT
    jmp Pause_MapPlot

    INCLUDE "WorldData_BankOffset.asm"
    INCLUDE "WorldData_WorldRomSlot.asm"