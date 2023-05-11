#!/usr/bin/env python3

from collections import Counter

def print_color_count(counter, name):
    values = list(counter)
    print(f"{name} - length: {len(values)}")
    for k,v in counter.most_common():
        print(f"  {k:02X} - {v:>3}")

def get_color_data():
    files = [
        "world/w0co",
        "world/w1co",
        "world/w2co"
    ]
    worlds_co = []
    for file_path in files:
        d = None
        with open(f'{file_path}.bin', "rb") as file:
            d = file.read()
        worlds_co.append(d)

    return worlds_co

def yield_color_rooms(co, id):
    for i in range(128):
        if co[i] == id:
            yield f"{i:02X}"


def get_color_count(world_co):
    worlds_counter = []

    for d in world_co:
        c = Counter(d)
        worlds_counter.append(c)

    return worlds_counter

def get_uncommon_color_location():
    worlds_co = get_color_data()
    worlds_counter = get_color_count(worlds_co)

    for i in range(3):
        co = worlds_co[i]
        counter = worlds_counter[i]
        n = 5
        least_common = counter.most_common()[:-n-1:-1]

        print(f"World {i}")
        for k, v in least_common:
            locations = ", ".join(yield_color_rooms(co, k))
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

get_uncommon_color_location()