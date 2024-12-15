from dataclasses import dataclass
from math import gcd
from icecream import ic
import re

from colorama import init, Fore, Back, Style

import numpy as np

init()

parser = re.compile(r"p=([0-9]+),([0-9]+) v=([0-9-]+),([0-9-]+)")

@dataclass(slots=True)
class Entity():
    x:int
    y:int

    def down(self):
        self.y += 1
    
    def up(self):
        self.y -= 1
    
    def left(self):
        self.x -= 1

    def right(self):
        self.x += 1


class Box(Entity):
    pass

class Robot(Entity):
    pass

class Wall(Entity):
    pass

@dataclass(slots=True)
class Grid:
    w:int
    h:int
    boxes: list[Box]
    walls: list[Wall]
    robot: Robot
    moves: str = ""

    def __init__(self, f):
        self.moves = ""
        self.boxes = []
        self.walls = []
        moves = False
        self.h = 0
        for y, line in enumerate(f):
            if line.strip() == "":
                moves = True
                continue
            if moves:
                self.moves += line.strip()
            else:
                self.h += 1
                self.w = len(line.strip())
                for x, c in enumerate(line.strip()):
                    if c=="@":
                        self.robot = Robot(x, y)
                    elif c=="#":
                        self.walls.append(Wall(x, y))
                    elif c=="O":
                        self.boxes.append(Box(x, y))

    def process(self):
        for move in self.moves:
            #print(f"Move {move}")
            if move == "^":
                for new_y in range(self.robot.y-1, 0, -1):
                    #self.print(self.robot.x, new_y)
                    if self.is_wall(self.robot.x, new_y):
                        break
                    if self.is_empty(self.robot.x,new_y):
                        for box_y in range(new_y, self.robot.y):
                            b = self.get_box(self.robot.x, box_y)
                            if b:
                                b.up()
                            #self.print()
                        self.robot.up()
                        #self.print()
                        break
            elif move == "v":
                for new_y in range(self.robot.y+1, self.h):
                    #self.print(self.robot.x, new_y)
                    if self.is_wall(self.robot.x, new_y):
                        break
                    if self.is_empty(self.robot.x,new_y):
                        for box_y in range(new_y, self.robot.y, -1):
                            b = self.get_box(self.robot.x, box_y)
                            if b:
                                b.down()
                            #self.print()
                        self.robot.down()
                        #self.print()
                        break
            elif move == "<":
                for new_x in range(self.robot.x-1, 0, -1):
                    #self.print(new_x, self.robot.y)
                    if self.is_wall(new_x, self.robot.y):
                        break
                    if self.is_empty(new_x, self.robot.y):
                        for box_x in range(new_x, self.robot.x):
                            b = self.get_box(box_x, self.robot.y)
                            if b:
                                b.left()
                            #self.print()
                        self.robot.left()
                        #self.print()
                        break
            elif move == ">":
                for new_x in range(self.robot.x+1, self.w):
                    #self.print(new_x, self.robot.y)
                    if self.is_wall(new_x, self.robot.y):
                        break
                    if self.is_empty(new_x, self.robot.y):
                        for box_x in range(new_x, self.robot.x, -1):
                            b = self.get_box(box_x, self.robot.y)
                            if b:
                                b.right()
                            #self.print()
                        self.robot.right()
                        #self.print()
                        break
            else:
                print(f"Unknown move {move}")
                break
            #self.print()


    def get_box(self, x, y) -> Box | None:
        for box in self.boxes:
            if box.x == x and box.y == y:
                return box
        return None
    
    def is_box(self, x, y):
        for box in self.boxes:
            if box.x == x and box.y == y:
                return True
        return False
    
    def is_wall(self, x, y):
        for wall in self.walls:
            if wall.x == x and wall.y == y:
                return True
        return False
    
    def is_robot(self, x, y):
        return self.robot.x == x and self.robot.y == y
    
    def is_empty(self, x, y):
        return not self.is_box(x, y) and not self.is_wall(x, y) and not self.is_robot(x, y)

    def print(self, pin_x:int|None=None, pin_y:int|None=None):
        for y in range(self.h):
            for x in range(self.w):
                style = ''
                if pin_x is not None and pin_y is not None and x == pin_x and y == pin_y:
                    style = Fore.RED
                
                if self.is_robot(x, y):
                    print(style+"@", end="")
                elif self.is_box(x, y):
                    print(style+"O", end="")
                elif self.is_wall(x, y):
                    print(style+"#", end="")
                else:
                    print(style+'.', end="")
                print(Style.RESET_ALL, end="")
            print()

    def score(self):
        score = 0
        for box in self.boxes:
            score += 100 * box.y + box.x
        return score


def part1(w,h,filename):
    with open(filename) as f:
        g = Grid(f)
        g.process()
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


part1(11,7,'input/test15.txt')

part1(11,7,'input/test15.2.txt')

ic.disable()
part1(101,103,'input/input15.txt')
ic.enable()

# part2(11,7,'input/test15.txt')

# ic.disable()
# part2(101,103,'input/input15.txt')
# ic.enable()