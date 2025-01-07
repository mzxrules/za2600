#!/usr/bin/env python3

from world import GetMapData, WORLD_COUNT, IsOverworld
from collections import Counter

def print_color_count(counter, name):
    values = list(counter)
    print(f"{name} - length: {len(values)}")
    for k,v in counter.most_common():
        print(f"  {k:02X} - {v:>3}")

def get_color_data():
    mdata = GetMapData()
    worlds_co = []

    for i in range (WORLD_COUNT):
        worlds_co.append(mdata[i][5])

    return worlds_co

def yield_color_rooms(wco, id):
    for i in range(128):
        if wco[i] == id:
            yield f"{i:02X}"

def yield_sprite_rooms(wspr, id):
    for i in range(128):
        for j in range(3):
            if wspr[i*3+j] == id:
                yield f"{i:02X}"
                break

def yield_sprite_pf1_rooms(wspr, id):
    for i in range(128):
        for j in range(2):
            if wspr[i*3+j] == id:
                yield f"{i:02X}"
                break

def yield_sprite_pf2_rooms(wspr, id):
    j = 2
    for i in range(128):
        if wspr[i*3+j] == id:
            yield f"{i:02X}"


def get_color_count(world_co):
    worlds_counter = []

    for d in world_co:
        c = Counter(d)
        worlds_counter.append(c)

    return worlds_counter

def get_uncommon_color_location(n = 5):
    worlds_co = get_color_data()
    worlds_counter = get_color_count(worlds_co)

    for i in range(WORLD_COUNT):
        wco = worlds_co[i]
        wcounter = worlds_counter[i]
        least_common = wcounter.most_common()[:-n-1:-1]

        print(f"World {i}")
        for k, v in least_common:
            locations = ", ".join(yield_color_rooms(wco, k))
            print(f" {k:02X} -> {locations}")


def print_world_color_count():
    worlds_co = get_color_data()
    worlds_counter = get_color_count(worlds_co)
    total_counter = Counter()

    for item in worlds_counter:
        total_counter.update(item)

    print_color_count(total_counter, "Total Count")

    i = 0
    for world in worlds_counter:
        print_color_count(world, f"World {i}")
        i += 1

def get_uncommon_sprite_location():
    mdata = GetMapData()

def get_sprite_locations(id):
    def print_world_sprite(i):
        world_sprites = mdata[i][4]

        print(f"World {i}")
        locations = ", ".join(yield_sprite_pf1_rooms(world_sprites, id))
        print(f" {id:02X} PF1 -> {locations}")
        locations = ", ".join(yield_sprite_pf2_rooms(world_sprites, id))
        print(f" {id:02X} PF2 -> {locations}")

    worldOrder = [0, 3, 1, 2, 4, 5]
    mdata = GetMapData()

    print(f"OVERWORLD {id:02X}")
    for i in worldOrder[0:2]:
        print_world_sprite(i)

    print(f"DUNGEON {id:02X}")
    for i in worldOrder[2:6]:
        print_world_sprite(i)

def log_sprite_locations():
    def log_world_sprite(i):
        output = ""
        world_sprites = mdata[i][4]

        if id < 32:
            locations = ", ".join(yield_sprite_pf1_rooms(world_sprites, id))
            output += f"  W{i} PF1 -> {locations}\n"
        locations = ", ".join(yield_sprite_pf2_rooms(world_sprites, id))
        output += f"  W{i} PF2 -> {locations}\n"
        return output

    worldOrder = [0, 3, 1, 2, 4, 5]
    mdata = GetMapData()
    output = ""

    for id in range(64):
        editorId = (id // 32) * 64 + (id % 32)
        output += f"SPR_{id:02} OVER ({editorId})\n"
        for i in worldOrder[0:2]:
            output += log_world_sprite(i)
        output += "\n"

    for id in range(64):
        output += f"SPR_{id:02} DUNG ({editorId + 128})\n"
        for i in worldOrder[2:6]:
            output += log_world_sprite(i)
        output += "\n"

    with open(f'gen/world_sprite_stats.txt', "w") as file:
        file.write(output)


# get_uncommon_color_location()
log_sprite_locations()