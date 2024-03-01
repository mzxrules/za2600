#!/usr/bin/env python3

GAME_COLOR_TABLE = {
    "COLOR_UNDEF":          (0x00,0x00),
    "COLOR_PLAYER_00":      (0xC6,0x58),
    "COLOR_PLAYER_01":      (0xAE,0x9A), # 0xAE, 0x9A
    "COLOR_PLAYER_02":      (0x46,0x66),

    "COLOR_EN_RED":         (0x44,0x64),
    "COLOR_EN_RED_L":       (0x4A,0x6A),
    "COLOR_EN_GREEN":       (0xDA,0x5C),
    "COLOR_EN_BLUE":        (0x74,0xB4),
    "COLOR_EN_BLUE_L":      (0x8C,0xBC),
    "COLOR_EN_YELLOW":      (0x24,0x24),
    "COLOR_EN_YELLOW_L":    (0x2A,0x2A),

    "COLOR_EN_BLACK":       (0x00,0x00),
    "COLOR_EN_GRAY_D":      (0x02,0x06),
    "COLOR_EN_GRAY_L":      (0x06,0x0C),
    "COLOR_EN_WHITE":       (0x0E,0x0E),

    "COLOR_EN_ROK_BLUE":    (0x72,0xC4),
    "COLOR_EN_LIGHT_BLUE":  (0x88,0xD8), # Item
    "COLOR_EN_TRIFORCE":    (0x2A,0x2A),
    "COLOR_EN_BROWN":       (0xF0,0x22),

    "COLOR_PF_BLACK":       (0x00,0x00),
    "COLOR_PF_GRAY_D":      (0x02,0x06),
    "COLOR_PF_GRAY_L":      (0x06,0x0C),
    "COLOR_PF_WHITE":       (0x0E,0x0E),

    "COLOR_PF_PATH":        (0x3C,0x4C),
    "COLOR_PF_CHOCOLATE":   (0xF0,0x22),
    "COLOR_PF_GREEN":       (0xD0,0x52),
    "COLOR_PF_RED":         (0x40,0x60),
    "COLOR_PF_WATER":       (0x7C,0xBA), #(0xAE,0x9E), # ??, BA

    "COLOR_PF_BLUE_D":      (0x90,0xC0),
    "COLOR_PF_BLUE_L":      (0x86,0xD6), # World
    "COLOR_PF_PURPLE_D":    (0x60,0xA2),
    "COLOR_PF_PURPLE":      (0x64,0xA6),
    "COLOR_PF_TEAL_D":      (0xB0,0x72),
    "COLOR_PF_TEAL_L":      (0xB2,0x74),
    "COLOR_PF_SACRED":      (0x1E,0x2E), # No good PAL equivalent

    "COLOR_MINIMAP":        (0x84,0x08), # Different colors
    "COLOR_HEALTH":         (0x46,0x64)
}

ROOM_COLOR_TABLE = [
    "COLOR_PF_BLACK",
    "COLOR_PF_GRAY_D",
    "COLOR_PF_GRAY_L",
    "COLOR_PF_BLUE_D",

    "COLOR_PF_BLUE_L",
    "COLOR_PF_WATER",
    "COLOR_PF_TEAL_D",
    "COLOR_PF_PURPLE_D",

    "COLOR_PF_PURPLE",
    "COLOR_PF_GREEN",
    "COLOR_PF_TEAL_L",
    "COLOR_PF_CHOCOLATE",

    "COLOR_PF_RED",
    "COLOR_PF_PATH",
    "COLOR_PF_SACRED",
    "COLOR_PF_WHITE"
]