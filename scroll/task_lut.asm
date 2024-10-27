;==============================================================================
; mzxrules 2024
;==============================================================================
ROOMSCROLL_TASK__END    = 0
ROOMSCROLL_TASK__ROOMA  = 1
ROOMSCROLL_TASK__ROOMB  = 2
ROOMSCROLL_TASK__LOAD   = 3
ROOMSCROLL_TASK__EAST   = 4
ROOMSCROLL_TASK__WEST   = 5
ROOMSCROLL_TASK__NORTH  = 6
ROOMSCROLL_TASK__SOUTH  = 7
ROOMSCROLL_TASK__NONE   = 8

RoomScroll_TaskMatrix:
; E, W, N, s
    ROOMSCROLL_TASK ROOMA, ROOMA, ROOMA, ROOMB
    ROOMSCROLL_TASK  LOAD,  LOAD,  LOAD,  LOAD
    ROOMSCROLL_TASK ROOMB, ROOMB, ROOMB, ROOMA
    ROOMSCROLL_TASK  WEST,  EAST, NORTH, SOUTH
    ROOMSCROLL_TASK   END,   END,   END,   END

RoomScroll_TaskInvalid:
    .byte ROOMSCROLL_TASK__ROOMA
    .byte ROOMSCROLL_TASK__LOAD
    .byte ROOMSCROLL_TASK__ROOMA
    .byte ROOMSCROLL_TASK__END

RoomScrollTaskBank:
    .byte #SLOT_FC_HALT_RSCR
    .byte #SLOT_F4_ROOMSCROLL
    .byte #SLOT_F4_ROOMSCROLL
    .byte #SLOT_F0_ROOM
    .byte #SLOT_F4_ROOMSCROLL
    .byte #SLOT_F4_ROOMSCROLL
    .byte #SLOT_F4_ROOMSCROLL
    .byte #SLOT_F4_ROOMSCROLL
    .byte #SLOT_FC_HALT_RSCR

RoomScrollTaskL:
    .byte <(RoomScrollTask_End-1)
    .byte <(RoomScrollTask_TransferA-1)
    .byte <(RoomScrollTask_TransferB-1)
    .byte <(RoomScrollTask_LoadRoom-1)
    .byte <(RoomScrollTask_AnimE-1)
    .byte <(RoomScrollTask_AnimW-1)
    .byte <(RoomScrollTask_AnimN-1)
    .byte <(RoomScrollTask_AnimS-1)
    .byte <(RoomScrollTask_None-1)

RoomScrollTaskH:
    .byte >(RoomScrollTask_End-1)
    .byte >(RoomScrollTask_TransferA-1)
    .byte >(RoomScrollTask_TransferB-1)
    .byte >(RoomScrollTask_LoadRoom-1)
    .byte >(RoomScrollTask_AnimE-1)
    .byte >(RoomScrollTask_AnimW-1)
    .byte >(RoomScrollTask_AnimN-1)
    .byte >(RoomScrollTask_AnimS-1)
    .byte >(RoomScrollTask_None-1)