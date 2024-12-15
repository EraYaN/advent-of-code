from dataclasses import dataclass
from math import gcd
from icecream import ic
import re

import numpy as np

parser = re.compile(r"p=([0-9]+),([0-9]+) v=([0-9-]+),([0-9-]+)")

@dataclass(slots=True)
class Robot():
    x:int
    y:int
    v_x:int
    v_y:int

    def __init__(self, line):
        m = parser.match(line)
        if m:
            self.x = int(m.group(1))
            self.y = int(m.group(2))
            self.v_x = int(m.group(3))
            self.v_y = int(m.group(4))

    def get_quad(self, w, h):
        q_w = w // 2
        q_h = h // 2

        if self.x < q_w:
            if self.y < q_h:
                return 1
            elif self.y == q_h and h % 2 == 1:
                return 0
            else:
                return 3
        elif self.x == q_w and w % 2 == 1:
            return 0
        else:
            if self.y < q_h:
                return 2
            elif self.y == q_h and h % 2 == 1:
                return 0
            else:
                return 4

@dataclass(slots=True)
class Grid:
    w:int
    h:int
    robots: list[Robot]

    def __init__(self, w, h, lines):
        self.w = w
        self.h = h
        self.robots = []
        for line in lines:
            self.robots.append(Robot(line))
            
        
    def step(self):
        for robot in self.robots:
            robot.x += robot.v_x
            robot.y += robot.v_y

            if robot.x < 0:
                robot.x += self.w
            elif robot.x >= self.w:
                robot.x -= self.w
            if robot.y < 0:
                robot.y += self.h
            elif robot.y >= self.h:
                robot.y -= self.h

    def print(self):
        for y in range(self.h):
            for x in range(self.w):
                sum = 0
                for r in self.robots:
                    if r.x == x and r.y == y:
                        sum += 1
                        break
                if sum > 9:
                    print("#", end="")
                elif sum > 0:
                    print(sum, end="")
                else:
                    print(".", end="")
            print()

    def score(self):
        quads = {
            1: 0,
            2: 0,
            3: 0,
            4: 0
        }

        for r in self.robots:
            q = r.get_quad(self.w, self.h)
            if q > 0:
                quads[q] += 1
        return quads[1] * quads[2] * quads[3] * quads[4]
    
    def max_score(self):
        quads = {
            1: 0,
            2: 0,
            3: 0,
            4: 0
        }

        for r in self.robots:
            q = r.get_quad(self.w, self.h)
            if q > 0:
                quads[q] += 1
        ic(quads, max(quads.values()))
        return max(quads.values())



def part1(w,h,filename):
    with open(filename) as f:
        lines = f.readlines()
        g = Grid(w,h,lines)
        for t in range(1000):
            g.step()
        print(f"Part 1 {filename}: {g.score()}")

def part2(w,h,filename):
    with open(filename) as f:
        lines = f.readlines()
        g = Grid(w,h,lines)
        for t in range(w*h):
            g.step()
            if g.max_score() <= len(g.robots)//2:
                continue
            print(f"t={t}+1 s={g.score()}")
            g.print()
        print(f"Part 2 {filename}: search manually")


part1(11,7,'input/test14.txt')

ic.disable()
part1(101,103,'input/input14.txt')
ic.enable()

part2(11,7,'input/test14.txt')

ic.disable()
part2(101,103,'input/input14.txt')
ic.enable()