from dataclasses import dataclass
from math import gcd
from icecream import ic
import re

import numpy as np

parser = re.compile(r"Button A: X\+([0-9]+), Y\+([0-9]+)\nButton B: X\+([0-9]+), Y\+([0-9]+)\nPrize: X=([0-9]+), Y=([0-9]+)")

@dataclass(slots=True)
class Configuration:
    AX: int
    AY: int
    BX: int
    BY: int
    TX: int
    TY: int
    coeff: np.ndarray
    target: np.ndarray

    def __init__(self, lines, add_trillion=False):
        m = parser.match(lines)
        if m:
            self.AX = int(m.group(1))
            self.AY = int(m.group(2))
            self.BX = int(m.group(3))
            self.BY = int(m.group(4))
            self.TX = int(m.group(5)) + (10000000000000 if add_trillion else 0)
            self.TY = int(m.group(6)) + (10000000000000 if add_trillion else 0)
            self.coeff = np.array([[self.AX, self.AY], [self.BX, self.BY]])
            self.target = np.array([self.TX, self.TY])

        else:
            raise ValueError(f"Invalid configuration: {lines}")
        
    def solve(self):
        if self.TX % gcd(self.AX, self.BX) != 0 or self.TY % gcd(self.AY, self.BY) != 0:
            return None

        presses = np.linalg.solve(self.coeff.T, self.target)
        rounded = np.round(presses)
        x_is_valid = np.all(0 <= rounded) and np.allclose(presses, rounded, rtol=1e-14, atol=1e-8) # need to adjust the defaults rtol=1e-9, atol=1e-5, because they were too sensitive for large values in y

        if x_is_valid:
            return rounded[0]*3+rounded[1]
        else:
            ic(self.coeff.T, self.target, presses, rounded)

def part1(filename):
    with open(filename) as f:
        configs = [Configuration(x) for x in f.read().split("\n\n")]
        
        s = 0
        for config in configs:
            solution = config.solve()
            ic(solution)
            if solution:
                s += solution
        print(f"Part 1 {filename}: {s}")

def part2(filename):
    with open(filename) as f:
        configs = [Configuration(x, True) for x in f.read().split("\n\n")]
        
        s = 0
        for config in configs:
            solution = config.solve()
            ic(solution)
            if solution:
                s += solution

        print(f"Part 2 {filename}: {s}")

part1('../input/test13.txt')

ic.disable()
part1('../input/input13.txt')
ic.enable()

part2('../input/test13.txt')

ic.disable()
part2('../input/input13.txt')
ic.enable()