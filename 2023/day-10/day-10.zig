const std = @import("std");
const util = @import("../util.zig");

const Direction = enum(u8) {
    North = 0,
    East = 1,
    South = 2,
    West = 3,
};

const Grid = struct {
    grid: []u8,
    distances: []i32,
    x: usize,
    y: usize,

    pub fn get(self: *const Grid, x: usize, y: usize) u8 {
        if (x >= self.x or y >= self.y) {
            return '.';
        }
        return self.grid[y * self.x + x];
    }
    pub fn set(self: *const Grid, x: usize, y: usize, val: u8) !void {
        if (x >= self.x or y >= self.y) {
            return error.OutOfBounds;
        }
        self.grid[y * self.x + x] = val;
    }

    pub fn getDist(self: *const Grid, x: usize, y: usize) i32 {
        if (x >= self.x or y >= self.y) {
            return '.';
        }
        return self.distances[y * self.x + x];
    }
    pub fn setDist(self: *const Grid, x: usize, y: usize, val: i32) !void {
        if (x >= self.x or y >= self.y) {
            return error.OutOfBounds;
        }
        self.distances[y * self.x + x] = val;
    }

    pub fn findStart(self: *const Grid) !struct { x: usize, y: usize } {
        for (0..self.y) |y| {
            for (0..self.x) |x| {
                if (self.get(x, y) == 'S') {
                    return .{ .x = x, .y = y };
                }
            }
        }
        return error.NotFound;
    }

    pub fn floodFill(self: *const Grid, x: usize, y: usize, idx: i32) !void {
        if (x >= self.x or y >= self.y) {
            return;
        }
        const d = self.getDist(x, y);
        if (d == -1) {
            try self.setDist(x, y, idx);
        } else if (d > idx) {
            //std.debug.print("Coord ({d},{d}) overwriting old distance {d} with {d}\n", .{ x, y, d, idx });
            try self.setDist(x, y, idx);
        } else {
            return;
        }
        if (self.isConnected(x, y, .North) and y > 0 and self.getDist(x, y - 1) == -1) {
            //std.debug.print("Coord ({d},{d}) is connected to the north\n", .{ x, y });
            try self.floodFill(x, y - 1, idx + 1);
        } else if (self.isConnected(x, y, .East) and self.getDist(x + 1, y) == -1) {
            //std.debug.print("Coord ({d},{d}) is connected to the east\n", .{ x, y });
            try self.floodFill(x + 1, y, idx + 1);
        } else if (self.isConnected(x, y, .South) and self.getDist(x, y + 1) == -1) {
            //std.debug.print("Coord ({d},{d}) is connected to the south\n", .{ x, y });
            try self.floodFill(x, y + 1, idx + 1);
        } else if (self.isConnected(x, y, .West) and x > 0 and self.getDist(x - 1, y) == -1) {
            //std.debug.print("Coord ({d},{d}) is connected to the west\n", .{ x, y });
            try self.floodFill(x - 1, y, idx + 1);
        }
    }

    pub fn findEnd(self: *const Grid) !struct { x: usize, y: usize, d: i32 } {
        var maxDist: i32 = -1;
        var maxX: usize = 0;
        var maxY: usize = 0;
        for (0..self.y) |y| {
            for (0..self.x) |x| {
                if (self.getDist(x, y) > maxDist) {
                    maxX = x;
                    maxY = y;
                    maxDist = self.getDist(x, y);
                }
            }
        }
        return .{ .x = maxX, .y = maxY, .d = maxDist };
    }

    fn isConnected(self: *const Grid, x: usize, y: usize, dir: Direction) bool {
        if (x >= self.x or y >= self.y) {
            return false;
        }
        const c = self.get(x, y);
        return switch (dir) {
            .North => (c == '|' or c == 'J' or c == 'L' or c == 'S') and (y > 0 and (self.get(x, y - 1) == '|' or self.get(x, y - 1) == '7' or self.get(x, y - 1) == 'F')),
            .East => (c == '-' or c == 'F' or c == 'L' or c == 'S') and (self.get(x + 1, y) == '-' or self.get(x + 1, y) == '7' or self.get(x + 1, y) == 'J'),
            .South => (c == '|' or c == 'F' or c == '7' or c == 'S') and (self.get(x, y + 1) == '|' or self.get(x, y + 1) == 'J' or self.get(x, y + 1) == 'L'),
            .West => (c == '-' or c == 'J' or c == '7' or c == 'S') and (x > 0 and (self.get(x - 1, y) == '-' or self.get(x - 1, y) == 'F' or self.get(x - 1, y) == 'L')),
        };
    }

    pub fn parseFromText(alloc: std.mem.Allocator, lines: [][]const u8) !Grid {
        var y = lines.len;
        var x = lines[0].len;
        defer alloc.free(lines);
        const grid = try alloc.alloc(u8, x * y);
        const distances = try alloc.alloc(i32, x * y);
        for (lines, 0..) |line, i| {
            for (line, 0..) |c, j| {
                grid[i * x + j] = c;
                distances[i * x + j] = -1;
            }
        }

        return .{ .grid = grid, .distances = distances, .x = x, .y = y };
    }
};

fn parseAll(alloc: std.mem.Allocator, input: []const u8) !Grid {
    var input_text = std.mem.split(u8, input, "\n");

    var list = std.ArrayList([]const u8).init(alloc);
    defer list.deinit();
    //defer for (list.items) |m| m.deinit();

    while (input_text.next()) |line| {
        try list.append(line);
    }

    return Grid.parseFromText(alloc, try list.toOwnedSlice());
}

fn printGrid(grid: Grid) void {
    for (0..grid.y) |y| {
        for (0..grid.x) |x| {
            std.debug.print("{c}", .{grid.get(x, y)});
        }
        std.debug.print("   ", .{});
        for (0..grid.x) |x| {
            std.debug.print(" ({d}) ", .{grid.getDist(x, y)});
        }
        std.debug.print("\n", .{});
    }
}

fn printJustGrid(grid: *const Grid) void {
    for (0..grid.y) |y| {
        for (0..grid.x) |x| {
            std.debug.print("{c}", .{grid.get(x, y)});
        }

        std.debug.print("\n", .{});
    }
}

fn doRoundPart1(alloc: std.mem.Allocator, grid: Grid) !i32 {
    _ = alloc;
    var startCoords = try grid.findStart();
    std.debug.print("Start: ({d}, {d})\n", .{ startCoords.x, startCoords.y });
    try grid.floodFill(startCoords.x, startCoords.y, 0);
    var endCoords = try grid.findEnd();
    printGrid(grid);
    return @divFloor(endCoords.d, 2) + @mod(endCoords.d, 2);
}

fn doRoundPart2(alloc: std.mem.Allocator, grid: Grid) !i32 {
    //grid is already floodFilled in part 1
    var endCoords = try grid.findEnd();
    var crossings: i32 = 0;
    var internals: i32 = 0;
    var crossingsArr = try alloc.alloc(u8, grid.x * grid.y);
    defer alloc.free(crossingsArr);
    for (0..grid.y) |y| {
        crossings = 0;
        for (0..grid.x) |x| {
            var c = grid.getDist(x, y);
            var cBelow = grid.getDist(x, y + 1);
            if (c != -1 and cBelow != -1) {
                const loopSize: u32 = @as(u32, @intCast(endCoords.d + 1));
                const diff: u32 = @as(u32, @intCast(@max(c, cBelow) - @min(c, cBelow))) % loopSize;
                //std.debug.print("({d},{d}) ({d} - {d}) % {d} = {d}\n", .{ x, y, c, cBelow, loopSize, diff });
                if ((diff == 1 and c < cBelow or diff == loopSize - 1 and c > cBelow)) {
                    crossings -= 1;
                    crossingsArr[y * grid.x + x] = 'D';
                } else if ((diff == 1 and c > cBelow or diff == loopSize - 1 and c < cBelow)) {
                    crossings += 1;
                    crossingsArr[y * grid.x + x] = 'U';
                } else {
                    crossingsArr[y * grid.x + x] = 'L';
                }
            } else if (c == -1) {
                if (crossings != 0) {
                    try grid.set(x, y, 'I');
                    internals += 1;
                }
                crossingsArr[y * grid.x + x] = '.';
            } else {
                crossingsArr[y * grid.x + x] = 'L';
            }
        }
    }
    printJustGrid(&grid);
    for (0..grid.y) |y| {
        for (0..grid.x) |x| {
            std.debug.print("{c}", .{crossingsArr[y * grid.x + x]});
        }

        std.debug.print("\n", .{});
    }
    return internals;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]i64 {
    var grid = try parseAll(alloc, input);
    defer alloc.free(grid.grid);
    defer alloc.free(grid.distances);

    const part1 = try doRoundPart1(alloc, grid);
    const part2 = try doRoundPart2(alloc, grid);

    return .{ part1, part2 };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();

    const sol = try solve(allocator, @embedFile("input.txt"));
    std.debug.print("Part 1: {d}\nPart 2: {d}\n", .{ sol[0], sol[1] });

    if (try util.parse_cli_args(allocator)) {
        var result = try util.benchmark(allocator, solve, .{ allocator, @embedFile("input.txt") }, .{ .warmup = 3, .trials = 50 });
        defer result.deinit();
        result.printSummary();
    }
}

test "test-input" {
    std.debug.print("\nStarting test...\n", .{});
    const sol = try solve(std.testing.allocator, @embedFile("test.txt"));
    std.debug.print("(1) Part 1: {d}\n(1) Part 2: {d}\n", .{ sol[0], sol[1] });

    const sol2 = try solve(std.testing.allocator, @embedFile("test2.txt"));
    std.debug.print("(2) Part 1: {d}\n(2) Part 2: {d}\n", .{ sol2[0], sol2[1] });

    const sol3 = try solve(std.testing.allocator, @embedFile("test3.txt"));
    std.debug.print("(3) Part 1: {d}\n(3) Part 2: {d}\n", .{ sol3[0], sol3[1] });

    const sol4 = try solve(std.testing.allocator, @embedFile("test4.txt"));
    std.debug.print("(4) Part 1: {d}\n(4) Part 2: {d}\n", .{ sol4[0], sol4[1] });

    const sol5 = try solve(std.testing.allocator, @embedFile("test5.txt"));
    std.debug.print("(5) Part 1: {d}\n(5) Part 2: {d}\n", .{ sol5[0], sol5[1] });
}
