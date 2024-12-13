from dataclasses import dataclass
from icecream import ic

@dataclass(slots=True)
class Plot():
    x:int
    y:int
    value:str

    def pos(self) -> tuple[int,int]:
        return (self.x, self.y)

    def down(self):
        return Plot(self.x, self.y+1, self.value)
    
    def up(self):
        return Plot(self.x, self.y-1, self.value)
    
    def left(self):
        return Plot(self.x-1, self.y, self.value)
    
    def right(self):
        return Plot(self.x+1, self.y, self.value)

class Grid():
    default_plot = Plot(-1, -1, "X")
    def __init__(self, f):
        self.field = [l.strip() for l in f.readlines() if l.strip() != ""]
        self.width = len(self.field[0])
        self.height = len(self.field)

        self.assigned = ["."*self.width]*self.height

    def print(self):
        return
        for line in self.field:
            print(line)

        for line in self.assigned:
            print(line)

    def is_valid(self, p : Plot) -> bool:
        if p is None:
            return False
        return p.x >= 0 and p.x < self.width and p.y >= 0 and p.y < self.height

    def get(self, p : Plot) -> str | None:
        if not self.is_valid(p):
            return Grid.default_plot.value
        return self.field[p.y][p.x]
    
    def get_assigned(self, p : Plot):
        if not self.is_valid(p):
            return Grid.default_plot
        return self.assigned[p.y][p.x]
    
    def set_assigned(self, p : Plot):
        self.assigned[p.y] = self.assigned[p.y][:p.x] + "X" + self.assigned[p.y][p.x+1:]
    
    def get_first_unassigned(self):
        for x in range(self.height):
            for y in range(self.width):
                if self.get_assigned(Plot(x,y,'.')) == ".":
                    v = self.get(Plot(x,y,'.'))
                    if v is None:
                        raise ValueError(f"Invalid coordinates: {x}, {y}")
                    return Plot(x, y, v)
        return None
    
    def check_dir(self, value, new_plot, plots):
        if not self.is_valid(new_plot):
            return -1
        if self.get(new_plot) == value and self.get_assigned(new_plot) == ".":
            plots.append(new_plot)
            self.set_assigned(new_plot)
            return 1
        elif self.get(new_plot) == value and self.get_assigned(new_plot) == "X":
            return 0
        #elif self.get_assigned(new_plot) == ".":
        #    return -1
        return  -1
    
    def get_boundries(self, points):
        deltas = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        return set((p[0]+dx, p[1]+dy) for p in points for dx, dy in deltas if (p[0]+dx, p[1]+dy) not in points)


    def count_corners(self, region):
        corners = set()
        kernels = [
            [(-1, 0), (0, -1), (-1, -1)],  # upper left
            [(1, 0), (0, -1), (1, -1)],  # upper right
            [(-1, 0), (0, 1), (-1, 1)],  # lower left
            [(1, 0), (0, 1), (1, 1)],  # lower right
        ]

        # get outer corners
        for px, py in region:
            for kernel in kernels:
                vals = [(px+kx, py+ky) for kx, ky in kernel]
                if all(v not in region for v in vals):
                    corners.add((px, py, kernels.index(kernel)))

        inner_kernels = [
            [(-1, 0), (0, -1)],
            [(-1, 0), (0, 1)],
            [(1, 0), (0, -1)],
            [(1, 0), (0, 1)],
        ]
        inner_corners = set()
        # get inner corners
        for px, py in self.get_boundries(region):
            for kernel in inner_kernels:
                vals = [(px+kx, py+ky) for kx, ky in kernel]
                if all(v in region for v in vals):
                    dx, dy = kernel[0][0]+kernel[1][0], kernel[0][1]+kernel[1][1]
                    if (px+dx, py+dy) in region:
                        inner_corners.add(
                            (px+dx, py+dy, inner_kernels.index(kernel)))
                    else:
                        (v1x, v1y), (v2x, v2y) = vals
                        dx, dy = v1x-v2x, v1y-v2y
                        d1 = [(-dx, 0), (0, dy)]
                        d2 = [(dx, 0), (0, -dy)]

                        inner_corners.add((v1x, v1y, inner_kernels.index(d1)))
                        inner_corners.add((v2x, v2y, inner_kernels.index(d2)))

        return len(corners) + len(inner_corners)
    
    
    def process(self, use_sides : bool = False):
        s = 0
        regions = []
        while True:
            plot = self.get_first_unassigned()
            plot_value = self.get(plot)
            
            if plot is None:
                break
            ic(plot, plot_value)
            plots = [plot]
            self.set_assigned(plot)
            region : set[tuple[int,int]] = set()
            failed = 0
            corners = 0
            count = 1
            while len(plots) > 0:
                if use_sides:
                    ic(plot, plots, count, corners, count * corners)
                else:
                    ic(plot, plots, count, failed, count * failed)
                self.print()
                for plot in plots:
                    region.add(plot.pos())
                    d = self.check_dir(plot_value, plot.down(), plots)
                    if d == 1:
                        count+=1
                    elif d == -1:
                        failed+=1
                    u = self.check_dir(plot_value, plot.up(), plots)
                    if u == 1:
                        count+=1
                    elif u == -1:
                        failed+=1
                    l = self.check_dir(plot_value, plot.left(), plots)
                    if l == 1:
                        count+=1
                    elif l == -1:
                        failed+=1
                    r = self.check_dir(plot_value, plot.right(), plots)
                    if r == 1:
                        count+=1
                    elif r == -1:
                        failed+=1
                    
                    plots.remove(plot)
                
            
            
            self.print()
            if not use_sides:
                ic(plot, plots, count, failed, count * failed)
                s += count * failed
            else:
                corners = self.count_corners(region)
                ic(plot, plots, count, corners, count * corners)
                s += count * corners
            
            regions.append((plot_value, region))
            
        ic(regions)
        return s
    


def part1(filename):
    with open(filename) as f:
        g = Grid(f)
        g.print()
        print(f"Part 1 {filename}: {g.process()}")

def part2(filename):
    with open(filename) as f:
        g = Grid(f)
        g.print()
        print(f"Part 2 {filename}: {g.process(True)}")

part1('../input/test12.txt')

ic.disable()
part1('../input/input12.txt')
ic.enable()

part2('../input/test12.txt')


ic.disable()
part2('../input/input12.txt')
ic.enable()

