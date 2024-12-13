from dataclasses import dataclass
from operator import le
from pprint import pprint
from icecream import ic
from typing import TextIO

@dataclass(slots=True)
class Head():
    x:int
    y:int
    value:int = 0
    has_finished:bool = False
    has_failed:bool = False

class Grid():
    def __init__(self, f: TextIO):
        self.elevation = [[ord(x)-ord('0') for x in l.strip()] for l in f.readlines() if l.strip() != ""]
        self.width = len(self.elevation[0])
        self.height = len(self.elevation)

    def print(self):
        for line in self.elevation:
            for char in line:
                print(char, end="")
            print('\n',end="")

    def get(self, x, y):
        if x < 0 or x >= self.width or y < 0 or y >= self.height:
            return None
        return self.elevation[y][x]
    
    def find_paths(self, x, y):
        heads = [Head(x, y)]
        finished = set()
        finished_num = 0
        while True:
            new_heads = []
            for head in heads:
                if head.value == 9:
                    finished.add((head.x, head.y))
                    finished_num+=1
                if head.has_finished or head.has_failed:
                    continue
                next_value = head.value + 1
                dirs = []
                if self.get(head.x-1, head.y) == next_value:
                    dirs.append('W')
                if self.get(head.x+1, head.y) == next_value:
                    dirs.append('E')
                if self.get(head.x, head.y-1) == next_value:
                    dirs.append('N')
                if self.get(head.x, head.y+1) == next_value:
                    dirs.append('S')
                if len(dirs) == 0:
                    head.has_failed = True
                elif len(dirs) >= 1:
                    for dir in dirs:
                        new_head = Head(head.x, head.y, next_value)
                        if dir == 'N':
                            new_head.y -= 1
                        elif dir == 'S':
                            new_head.y += 1
                        elif dir == 'W':
                            new_head.x -= 1
                        elif dir == 'E':
                            new_head.x += 1
                        if self.get(new_head.x, new_head.y) != next_value:
                            raise ValueError("Mistakes were made...")
                        new_heads.append(new_head)
            heads = new_heads
            ic(x,y,heads)
            if len(heads)==0:
                break
        ic(x,y,finished, len(finished), finished_num)
        return len(finished),finished_num

        

    def process(self, use_part2:bool):
        heads : list[tuple[int,int]] = []
        s = 0
        for x in range(self.width):
            for y in range(self.height):
                #print(self.get(x, y))

                if self.get(x, y) == 0:
                    heads.append((x, y))
        ic(heads)
        for head in heads:
            s += self.find_paths(*head)[1 if use_part2 else 0]
        return s


def part1(filename):
    with open(filename) as f:
        g = Grid(f)
        g.print()
        print(f"Part 1 {filename}: {g.process(False)}")

def part2(filename):
    with open(filename) as f:
        g = Grid(f)
        g.print()
        print(f"Part 1 {filename}: {g.process(True)}")

part1('../input/test10.txt')

ic.disable()
part1('../input/input10.txt')
ic.enable()

part2('../input/test10.txt')

ic.disable()
part2('../input/input10.txt')
ic.enable()