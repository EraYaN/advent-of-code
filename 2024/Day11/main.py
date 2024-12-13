from icecream import ic

def update_dict(i:int, value:int, d: dict[int,int], stone: int, new_stone: int,new_stone2: int | None = None):
    #print(f"{i}: Replace ", stone, " with ", new_stone,', ', new_stone2)
    if new_stone not in d:
        d[new_stone] = value
    else:
        d[new_stone] += value
    if new_stone2 is not None:
        if new_stone2 not in d:
            d[new_stone2] = value
        else:
            d[new_stone2] += value
    if stone in d:
        d[stone] -= value
        if d[stone] == 0:
            del d[stone]

def process(stones: dict[int,int], blinks: int =25):
    for i in range(blinks):
        #new_stones : dict[int,int] = {}

        for stone,value in list(stones.items()):
            if stone == 0:
                update_dict(i,value,stones, stone, 1)
                continue
            formatted = f"{stone}"
            if len(formatted) % 2==0:
                half = 10**(len(formatted)//2)
                update_dict(i,value,stones, stone, stone//half, stone%half)
            else:
                update_dict(i,value,stones, stone, stone*2024)
        ic(i,stones.keys(),stones.values(), sum(stones.values()))
        #print(i,len(stones))
    return sum(list(stones.values()))

def part1(filename):
    with open(filename) as f:
        stones = {int(x):1 for x in f.readline().strip().split(' ')}
        
        print(f"Part 1 {filename}: {process(stones)}")

def part2(filename):
    with open(filename) as f:
        stones = {int(x):1 for x in f.readline().strip().split(' ')}
        
        print(f"Part 2 {filename}: {process(stones, 75)}")

part1('../input/test11.txt')

ic.disable()
part1('../input/input11.txt')
ic.enable()

part2('../input/test11.txt')

ic.disable()
part2('../input/input11.txt')
ic.enable()