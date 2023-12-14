const std = @import("std");
const util = @import("../util.zig");

//wrong[h]: 145324
//wrong[l]: 106374

const printDebug = false;

const Grid = struct {
    w: u64,
    h: u64,
    data: []u8,

    pub fn drawGridSimple(self: *const Grid) !void {
        try self.drawGrid(self.w + 1, self.w + 1, self.h + 1, self.h + 1);
    }

    pub fn drawGrid(self: *const Grid, x1: u64, x2: u64, y1: u64, y2: u64) !void {
        var err_stream = std.io.getStdErr();
        var conf: std.io.tty.Config = std.io.tty.detectConfig(err_stream);
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                if ((x == x1 or x == x2) and (y1 == y or y2 == y)) {
                    try conf.setColor(err_stream, .green);
                }
                std.debug.print("{c}", .{self.get(x, y)});
                if ((x == x1 or x == x2) and (y1 == y or y2 == y)) {
                    try conf.setColor(err_stream, .reset);
                }
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }

    pub fn get(self: *const Grid, x: u64, y: u64) u8 {
        if (y * (self.w + 1) + x > self.data.len) {
            std.debug.print("Out of bounds: {d}x{d} -> {d} out of {d}\n", .{ x, y, y * (self.w + 1) + x, self.data.len });
        }
        return self.data[y * (self.w + 1) + x];
    }

    pub fn set(self: *const Grid, x: u64, y: u64, value: u8) void {
        if (y * (self.w + 1) + x > self.data.len) {
            std.debug.print("Out of bounds: {d}x{d} -> {d} out of {d}\n", .{ x, y, y * (self.w + 1) + x, self.data.len });
        }
        self.data[y * (self.w + 1) + x] = value;
    }

    pub fn getFreeSpaceUp(self: *const Grid, x: u64, y: u64) u64 {
        if (y == 0) {
            return 0;
        }
        var current_y: u64 = y - 1;
        while (current_y >= 0) : (current_y -= 1) {
            const c = self.get(x, current_y);
            if (c != '.') {
                return current_y + 1;
            } else {
                if (current_y == 0) {
                    return 0;
                }
            }
        }
        unreachable;
    }

    pub fn getFreeSpaceDown(self: *const Grid, x: u64, y: u64) u64 {
        if (y == self.h - 1) {
            return self.h - 1;
        }
        var current_y: u64 = y + 1;
        while (current_y < self.h) : (current_y += 1) {
            const c = self.get(x, current_y);
            if (c != '.') {
                return current_y - 1;
            } else {
                if (current_y == self.h - 1) {
                    return self.h - 1;
                }
            }
        }
        unreachable;
    }

    pub fn getFreeSpaceLeft(self: *const Grid, x: u64, y: u64) u64 {
        if (x == 0) {
            return 0;
        }
        var current_x: u64 = x - 1;
        while (current_x >= 0) : (current_x -= 1) {
            const c = self.get(current_x, y);
            if (c != '.') {
                return current_x + 1;
            } else {
                if (current_x == 0) {
                    return 0;
                }
            }
        }
        unreachable;
    }

    pub fn getFreeSpaceRight(self: *const Grid, x: u64, y: u64) u64 {
        if (x == self.w - 1) {
            return self.w - 1;
        }
        var current_x: u64 = x + 1;
        while (current_x < self.w) : (current_x += 1) {
            const c = self.get(current_x, y);
            if (c != '.') {
                return current_x - 1;
            } else {
                if (current_x == self.w - 1) {
                    return self.w - 1;
                }
            }
        }
        unreachable;
    }

    pub fn applyTiltUp(self: *Grid) !bool {
        var changed: bool = false;
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                if (self.get(x, y) == 'O') {
                    const new_y = self.getFreeSpaceUp(x, y);
                    if (new_y == y) {
                        continue;
                    }
                    changed = true;
                    self.set(x, y, '.');
                    self.set(x, new_y, 'O');
                    if (self.h <= 10 and printDebug) {
                        std.debug.print("Found round stone in column {d} at {d} rolling up to {d}\n", .{ x, y, new_y });
                        try self.drawGrid(x, x, y, new_y);
                    }
                }
            }
        }
        return changed;
    }

    pub fn applyTiltDown(self: *Grid) !bool {
        var changed: bool = false;
        for (0..self.h) |y_offset| {
            const y = self.h - y_offset - 1;
            for (0..self.w) |x_offset| {
                const x = self.h - x_offset - 1;
                if (self.get(x, y) == 'O') {
                    const new_y = self.getFreeSpaceDown(x, y);
                    if (new_y == y) {
                        continue;
                    }
                    changed = true;
                    self.set(x, y, '.');
                    self.set(x, new_y, 'O');
                    if (self.h <= 10 and printDebug) {
                        std.debug.print("Found round stone in column {d} at {d} rolling down to {d}\n", .{ x, y, new_y });
                        try self.drawGrid(x, x, y, new_y);
                    }
                }
            }
        }
        return changed;
    }

    pub fn applyTiltLeft(self: *Grid) !bool {
        var changed: bool = false;
        for (0..self.w) |x| {
            for (0..self.h) |y| {
                if (self.get(x, y) == 'O') {
                    const new_x = self.getFreeSpaceLeft(x, y);
                    if (new_x == x) {
                        continue;
                    }
                    changed = true;
                    self.set(x, y, '.');
                    self.set(new_x, y, 'O');
                    if (self.w <= 10 and printDebug) {
                        std.debug.print("Found round stone in row {d} at {d} rolling left to {d}\n", .{ y, x, new_x });
                        try self.drawGrid(x, new_x, y, y);
                    }
                }
            }
        }
        return changed;
    }

    pub fn applyTiltRight(self: *Grid) !bool {
        var changed: bool = false;
        for (0..self.w) |x_offset| {
            const x = self.w - x_offset - 1;
            for (0..self.h) |y_offset| {
                const y = self.h - y_offset - 1;
                if (self.get(x, y) == 'O') {
                    const new_x = self.getFreeSpaceRight(x, y);
                    if (new_x == x) {
                        continue;
                    }
                    changed = true;
                    self.set(x, y, '.');
                    self.set(new_x, y, 'O');
                    if (self.w <= 10 and printDebug) {
                        std.debug.print("Found round stone in row {d} at {d} rolling right to {d}\n", .{ y, x, new_x });
                        try self.drawGrid(x, new_x, y, y);
                    }
                }
            }
        }
        return changed;
    }

    pub fn applyTilt(self: *Grid) !bool {
        var changedUp = try self.applyTiltUp();
        //try self.drawGridSimple();
        var changedLeft = try self.applyTiltLeft();
        //try self.drawGridSimple();
        var changedDown = try self.applyTiltDown();
        //try self.drawGridSimple();
        var changedRight = try self.applyTiltRight();
        //try self.drawGridSimple();
        return changedUp or changedLeft or changedDown or changedRight;
    }

    pub fn getStoneLoad(self: *Grid) u64 {
        var sum: u64 = 0;
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                if (self.get(x, y) == 'O') {
                    sum += self.h - y;
                }
            }
        }
        return sum;
    }

    pub fn parseFromText(alloc: std.mem.Allocator, pattern: []const u8) !Grid {
        var x: u64 = 0;
        var y: u64 = 0;

        for (pattern) |c| {
            if (c == '\n') {
                y += 1;
            } else {
                if (y == 0) {
                    x += 1;
                }
            }
        }

        y += 1;

        // var patternBuf = try alloc.alloc(u8, pattern.len - (y - 1));
        // var patternIdx: usize = 0;
        // _ = patternIdx;
        // for (0..pattern.len) |i| {
        //     if (pattern[i] == '\n') {
        //         @memcpy(patternBuf[patternBuf], &pattern[i + 1]);
        //     }
        // }
        // pattern = pattern[0 .. y - 1];
        //std.debug.print("Parsed pattern: ({d}x{d})\n'{s}'\n\n", .{ x, y, pattern });

        return .{ .data = try alloc.dupe(u8, pattern), .w = x, .h = y };
    }
};

fn parseAll(alloc: std.mem.Allocator, input: []const u8) !Grid {
    return try Grid.parseFromText(alloc, input);
}

fn doRoundPart1(alloc: std.mem.Allocator, grid: *Grid) !u64 {
    _ = alloc;
    std.debug.print("Part 1:\n", .{});

    _ = try grid.applyTiltUp();

    return grid.getStoneLoad();
}

fn doRoundPart2(alloc: std.mem.Allocator, grid: *Grid) !u64 {
    std.debug.print("Part 2:\n", .{});
    const iterations: u64 = 1_000_000_000;
    var i: u64 = 0;
    var cycles: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(alloc);
    defer cycles.deinit();
    defer for (cycles.items) |cycle| {
        alloc.free(cycle);
    };
    var found_cycle: bool = false;
    while (i < iterations) : (i += 1) {
        //std.debug.print("Round {d}:\n", .{i});
        //if (i % 10000 == 0) {
        std.debug.print("Round {d} out of {d} ({d:.3}%) (score: {d}).\n", .{ i, iterations, @as(f64, @floatFromInt(i)) * 100 / @as(f64, @floatFromInt(iterations)), grid.getStoneLoad() });
        //}
        if (!try grid.applyTilt()) {
            std.debug.print("Round without changes {d}.\n", .{i});
        } else if (!found_cycle) {
            var cycle: []const u8 = try alloc.dupe(u8, grid.data);
            innerfor: for (cycles.items, 0..) |c, cycle_idx| {
                if (std.mem.eql(u8, c, cycle)) {
                    std.debug.print("Found cycle at {d} of length {d} at place {d} in cycles out of {d}.\n", .{ i, i - cycle_idx, cycle_idx, cycles.items.len });
                    const cycle_length = i - cycle_idx;
                    const remaining = (iterations - cycle_idx) % cycle_length;
                    std.debug.print("Setting current iteration to {d}.\n", .{iterations - remaining});
                    i = iterations - remaining;
                    found_cycle = true;
                    break :innerfor;
                }
            }
            try cycles.append(cycle);
        }
        //try grid.drawGrid(grid.w + 1, grid.w + 1, grid.h + 1, grid.h + 1);
    }

    return grid.getStoneLoad();
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var grid = try parseAll(alloc, input);
    var grid2 = try parseAll(alloc, input);
    defer alloc.free(grid.data);
    defer alloc.free(grid2.data);

    const part1 = try doRoundPart1(alloc, &grid);
    const part2 = try doRoundPart2(alloc, &grid2);

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

    // const sol2 = try solve(std.testing.allocator, @embedFile("test2.txt"));
    // std.debug.print("(2) Part 1: {d}\n(2) Part 2: {d}\n", .{ sol2[0], sol2[1] });

    // const sol3 = try solve(std.testing.allocator, @embedFile("test3.txt"));
    // std.debug.print("(3) Part 1: {d}\n(3) Part 2: {d}\n", .{ sol3[0], sol3[1] });

    // const sol4 = try solve(std.testing.allocator, @embedFile("test4.txt"));
    // std.debug.print("(4) Part 1: {d}\n(4) Part 2: {d}\n", .{ sol4[0], sol4[1] });

    // const sol5 = try solve(std.testing.allocator, @embedFile("test5.txt"));
    // std.debug.print("(5) Part 1: {d}\n(5) Part 2: {d}\n", .{ sol5[0], sol5[1] });
}
