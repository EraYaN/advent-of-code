const std = @import("std");
const util = @import("../util.zig");

const blue = "blue";
const red = "red";
const green = "green";

const max_red = 12;
const max_green = 13;
const max_blue = 14;

pub fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

pub fn isSymbol(c: u8) bool {
    return ((c >= '!' and c <= '-') or (c == '/') or (c >= ':' and c <= '@') or (c >= '[' and c <= '`') or (c >= '{' and c <= '~'));
}

const Number = struct {
    num: u32,
    idx: u32,
    x: usize,
    y: usize,
};

const Grid = struct {
    grid: []u8,
    x: usize,
    y: usize,

    pub fn get(self: *const Grid, x: usize, y: usize) u8 {
        if (x >= self.x or y >= self.y) {
            return '.';
        }
        return self.grid[y * self.x + x];
    }

    pub fn hasSymbolsAround(self: *const Grid, x: usize, y: usize, num_len: usize) bool {
        var x_min = x;
        if (x > 0) {
            x_min = x - 1;
        }
        var y_min = y;
        if (y > 0) {
            y_min = y - 1;
        }
        for (y_min..@min(self.y, y + 2)) |y_local| {
            for (x_min..@min(self.x, x + num_len + 1)) |x_local| {
                var c = self.get(x_local, y_local);
                if (isSymbol(c)) {
                    return true;
                }
            }
        }
        return false;
    }

    pub fn findNumbersAround(self: *const Grid, alloc: std.mem.Allocator, x: usize, y: usize) ![]Number {
        var x_min = x;
        if (x > 0) {
            x_min = x - 1;
        }
        var y_min = y;
        if (y > 0) {
            y_min = y - 1;
        }
        var list = std.ArrayList(Number).init(alloc);
        defer list.deinit();
        for (y_min..@min(self.y, y + 2)) |y_local| {
            for (x_min..@min(self.x, x + 2)) |x_local| {
                var c = self.get(x_local, y_local);
                if (isDigit(c)) {
                    var number = self.getNumber(alloc, x_local, y_local, true) catch {
                        continue;
                    };
                    var found = false;
                    for (list.items) |m| {
                        if (m.x == number.x and m.y == number.y) {
                            found = true;
                        }
                    }
                    if (!found) {
                        try list.append(number);
                    }
                }
            }
        }
        return list.toOwnedSlice();
    }

    pub fn getNumber(self: *const Grid, alloc: std.mem.Allocator, x: usize, y: usize, find_full: bool) !Number {
        var c = self.get(x, y);
        var digit: []u8 = try alloc.alloc(u8, 5);
        defer alloc.free(digit);
        var idx: u32 = 0;
        if (isDigit(c)) {
            if (x > 0 and isDigit(self.get(x - 1, y))) {
                if (find_full) {
                    return getNumber(self, alloc, x - 1, y, find_full);
                } else {
                    return error.NotFullNumber;
                }
            }
            for (x..@min(self.x, x + 5)) |x_local| {
                if (isDigit(self.get(x_local, y))) {
                    digit[idx] = self.get(x_local, y);
                    idx += 1;
                } else {
                    break;
                }
            }
        } else {
            return error.UnexpectedCharacter;
        }
        return .{ .num = try std.fmt.parseInt(u32, digit[0..idx], 10), .idx = idx, .x = x, .y = y };
    }

    pub fn parseFromText(alloc: std.mem.Allocator, lines: [][]const u8) !Grid {
        var y = lines.len;
        var x = lines[0].len;
        defer alloc.free(lines);
        const grid = try alloc.alloc(u8, x * y);
        for (lines, 0..) |line, i| {
            for (line, 0..) |c, j| {
                grid[i * x + j] = c;
            }
        }

        return .{ .grid = grid, .x = x, .y = y };
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

fn doRoundPart1(alloc: std.mem.Allocator, grid: Grid) !u32 {
    var sum: u32 = 0;
    for (0..grid.y) |y| {
        for (0..grid.x) |x| {
            var s = grid.getNumber(alloc, x, y, false) catch {
                continue;
            };
            if (grid.hasSymbolsAround(x, y, s.idx)) {
                std.debug.print("({d}, {d}) = {d} ({d})\n", .{ x, y, s.num, s.idx });
                sum += s.num;
            }
        }
    }
    return sum;
}

fn doRoundPart2(alloc: std.mem.Allocator, grid: Grid) !u32 {
    var ratio_sum: u32 = 0;
    for (0..grid.y) |y| {
        for (0..grid.x) |x| {
            var c = grid.get(x, y);
            if (c == '*') {
                std.debug.print("Part 2: ({d}, {d}) = *\n", .{ x, y });
                var numbers = try grid.findNumbersAround(alloc, x, y);
                defer alloc.free(numbers);
                if (numbers.len == 2) {
                    var product: u32 = 1;
                    for (numbers) |s| {
                        std.debug.print("Part 2: ({d}, {d}) = {d} ({d})\n", .{ s.x, s.y, s.num, s.idx });
                        product *= s.num;
                    }
                    ratio_sum += product;
                }
            }
        }
    }
    return ratio_sum;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var grid = try parseAll(alloc, input);
    //defer alloc.destroy(grid);
    defer alloc.free(grid.grid);
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
        var result = try util.benchmark(allocator, solve, .{ allocator, @embedFile("input.txt") }, .{ .warmup = 10, .trials = 1000 });
        defer result.deinit();
        result.printSummary();
    }
}

test "test-input" {
    std.debug.print("\n", .{});
    const sol = try solve(std.testing.allocator, @embedFile("test.txt"));
    std.debug.print("Part 1: {d}\nPart 2: {d}\n", .{ sol[0], sol[1] });
}
