const std = @import("std");
const util = @import("../util.zig");

const stdin = std.io.getStdIn().reader();

//wrong[h]: 145324
//wrong[l]: 106374

const printDebug = false;

const Direction = enum(u8) {
    North = 0,
    East = 1,
    South = 2,
    West = 3,
};

const Beam = struct {
    x: u64,
    y: u64,
    dir: Direction,
};

const Grid = struct {
    w: u64,
    h: u64,
    data: []u8,
    directions: []std.ArrayList(Direction),
    beams: std.ArrayList(Beam),
    alloc: std.mem.Allocator,

    fn hasBeam(self: *const Grid, x: u64, y: u64) bool {
        for (self.beams.items) |beam| {
            if (beam.x == x and beam.y == y) {
                return true;
            }
        }
        return false;
    }

    pub fn getEnergizedTiles(self: *const Grid) !u64 {
        var count: u64 = 0;
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                var dir = self.getDirection(x, y);
                if (dir.items.len > 0) {
                    count += 1;
                }
            }
        }
        return count;
    }

    pub fn drawGrid(self: *const Grid) !void {
        var err_stream = std.io.getStdErr();
        var conf: std.io.tty.Config = std.io.tty.detectConfig(err_stream);
        for (0..self.h) |y| {
            for (0..self.w) |x| {
                var c = self.get(x, y);
                var setColor = false;
                var isBeam = self.hasBeam(x, y);
                if (c == '.') {
                    var directions = self.getDirection(x, y);
                    const len = directions.items.len;
                    setColor = len > 0;
                    if (len == 1) {
                        switch (directions.items[0]) {
                            .North => c = '^',
                            .East => c = '>',
                            .South => c = 'v',
                            .West => c = '<',
                        }
                    } else if (len > 1 and len < 10) {
                        c = @as(u8, @intCast(len)) + '0';
                    } else if (len >= 10) {
                        c = '*';
                    }
                }
                if (setColor) {
                    try conf.setColor(err_stream, .green);
                }
                if (isBeam) {
                    try conf.setColor(err_stream, .red);
                }
                std.debug.print("{c}", .{c});
                if (setColor or isBeam) {
                    try conf.setColor(err_stream, .reset);
                }
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }

    fn proccessNewBeamDirection(self: *const Grid, beam: *Beam, start: bool) struct { remove: bool, extraDirection: ?Direction } {
        var nextTile: ?u8 = null;
        if (start) {
            nextTile = self.tryGet(beam.x, beam.y);
        } else {
            nextTile = switch (beam.dir) {
                .North => if (beam.y > 0) self.tryGet(beam.x, beam.y - 1) else null,
                .East => self.tryGet(beam.x + 1, beam.y),
                .South => self.tryGet(beam.x, beam.y + 1),
                .West => if (beam.x > 0) self.tryGet(beam.x - 1, beam.y) else null,
            };
        }
        if (nextTile == null) {
            if (printDebug)
                std.debug.print("Beam out of bounds: {d}x{d} -> {any}\n", .{ beam.x, beam.y, beam.dir });
            return .{ .remove = true, .extraDirection = null };
        }
        if (!start) {
            switch (beam.dir) {
                .North => beam.*.y -= 1,
                .East => beam.*.x += 1,
                .South => beam.*.y += 1,
                .West => beam.*.x -= 1,
            }
        }
        if (nextTile == '\\') {
            switch (beam.dir) {
                .North => beam.*.dir = .West,
                .East => beam.*.dir = .South,
                .South => beam.*.dir = .East,
                .West => beam.*.dir = .North,
            }
        }
        if (nextTile == '/') {
            switch (beam.dir) {
                .North => beam.*.dir = .East,
                .East => beam.*.dir = .North,
                .South => beam.*.dir = .West,
                .West => beam.*.dir = .South,
            }
        }
        if (nextTile == '-' and (beam.dir == .North or beam.dir == .South)) {
            beam.*.dir = .West;
            return .{ .remove = false, .extraDirection = .East };
            //try newBeams.append(.{ .x = beam.x, .y = beam.y, .dir = .East });
        }
        if (nextTile == '|' and (beam.dir == .East or beam.dir == .West)) {
            beam.*.dir = .North;
            return .{ .remove = false, .extraDirection = .South };
            //try newBeams.append(.{ .x = beam.x, .y = beam.y, .dir = .South });
        }
        return .{ .remove = false, .extraDirection = null };
    }

    pub fn advanceBeams(self: *Grid) !void {
        var newBeams = std.ArrayList(Beam).init(self.alloc);
        defer newBeams.deinit();
        var removedItems: usize = 0;
        for (0..self.beams.items.len) |i| {
            var idx = i - removedItems;
            var beam = &self.beams.items[idx];

            var pRes = self.proccessNewBeamDirection(beam, false);

            if (pRes.remove) {
                _ = self.beams.orderedRemove(idx);
                removedItems += 1;
                continue;
            }

            if (pRes.extraDirection) |newDir| {
                try newBeams.append(.{ .x = beam.x, .y = beam.y, .dir = newDir });
            }

            var positionDirections = self.getDirection(beam.x, beam.y);
            var found = false;
            for (positionDirections.items) |dir| {
                if (dir == beam.dir) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                try positionDirections.append(beam.dir);
            } else {
                if (printDebug)
                    std.debug.print("Found duplicate direction at {d}x{d} -> {any}\n", .{ beam.x, beam.y, beam.dir });
                _ = self.beams.orderedRemove(idx);

                removedItems += 1;
            }
        }
        if (printDebug)
            std.debug.print("New beams: {d}; Removed beams: {d}\n", .{ newBeams.items.len, removedItems });
        for (newBeams.items) |beam| {
            var positionDirections = self.getDirection(beam.x, beam.y);
            var found = false;
            for (positionDirections.items) |dir| {
                if (dir == beam.dir) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                try positionDirections.append(beam.dir);

                try self.beams.append(beam);
            } else {
                if (printDebug)
                    std.debug.print("Found duplicate direction at {d}x{d} -> {any}\n", .{ beam.x, beam.y, beam.dir });

                try self.beams.append(beam);
            }
        }
    }

    pub fn tryGet(self: *const Grid, x: u64, y: u64) ?u8 {
        if (x < 0 or y < 0 or x >= self.w or y >= self.h) {
            return null;
        }
        return self.get(x, y);
    }

    pub fn get(self: *const Grid, x: u64, y: u64) u8 {
        if (y * (self.w + 1) + x > self.data.len) {
            std.debug.print("Out of bounds: {d}x{d} -> {d} out of {d}\n", .{ x, y, y * (self.w + 1) + x, self.data.len });
        }
        return self.data[y * (self.w + 1) + x];
    }

    pub fn getDirection(self: *const Grid, x: u64, y: u64) *std.ArrayList(Direction) {
        if (y * (self.w + 1) + x > self.data.len) {
            std.debug.print("Out of bounds: {d}x{d} -> {d} out of {d}\n", .{ x, y, y * (self.w + 1) + x, self.data.len });
        }
        return &self.directions[y * (self.w + 1) + x];
    }

    pub fn set(self: *const Grid, x: u64, y: u64, value: u8) void {
        if (y * (self.w + 1) + x > self.data.len) {
            std.debug.print("Out of bounds: {d}x{d} -> {d} out of {d}\n", .{ x, y, y * (self.w + 1) + x, self.data.len });
        }
        self.data[y * (self.w + 1) + x] = value;
    }

    pub fn parseFromText(alloc: std.mem.Allocator, pattern: []const u8) !Grid {
        var x: u64 = 0;
        var y: u64 = 0;

        var directions = try alloc.alloc(std.ArrayList(Direction), pattern.len);
        var startDirection: Direction = .East;

        for (pattern, 0..) |c, i| {
            if (c == '\n') {
                y += 1;
            } else {
                if (y == 0) {
                    x += 1;
                }
            }
            directions[i] = std.ArrayList(Direction).init(alloc);
        }

        y += 1;

        var c = pattern[0];

        if (c == '\\' or c == '|') {
            startDirection = .South;
        }
        if (c == '/') {
            startDirection = .North;
        }
        try directions[0].append(startDirection);
        var beams = std.ArrayList(Beam).init(alloc);
        try beams.append(.{ .x = 0, .y = 0, .dir = startDirection });
        return .{ .data = try alloc.dupe(u8, pattern), .w = x, .h = y, .beams = beams, .directions = directions, .alloc = alloc };
    }

    fn getEdge(self: *const Grid, x: u64, y: u64) Direction {
        if (x == 0) {
            return .West;
        }
        if (x == self.w - 1) {
            return .East;
        }
        if (y == 0) {
            return .North;
        }
        if (y == self.h - 1) {
            return .South;
        }
        unreachable;
    }

    pub fn run(self: *Grid) !void {
        var i: u64 = 0;
        while (self.beams.items.len > 0) : (i += 1) {
            try self.advanceBeams();
            if (printDebug) {
                std.debug.print("Iteration: {d}; Beams: {d}\n", .{ i, self.beams.items.len });
                try self.drawGrid();
                try stdin.skipUntilDelimiterOrEof('\n');
            }
        }
    }

    pub fn reset(self: *Grid, x: usize, y: usize, startVertical: bool) !void {
        for (0..self.data.len) |i| {
            self.directions[i].clearAndFree();
        }
        self.beams.clearAndFree();

        var startDirection: Direction = .East;
        switch (self.getEdge(x, y)) {
            .North => {
                if (x == 0 and !startVertical) {
                    startDirection = .East;
                } else if (x == self.w - 1 and !startVertical) {
                    startDirection = .West;
                } else {
                    startDirection = .South;
                }
            },
            .East => {
                if (y == 0 and startVertical) {
                    startDirection = .South;
                } else if (y == self.h - 1 and !startVertical) {
                    startDirection = .North;
                } else {
                    startDirection = .West;
                }
            },
            .South => {
                if (x == 0 and !startVertical) {
                    startDirection = .East;
                } else if (x == self.w - 1 and !startVertical) {
                    startDirection = .West;
                } else {
                    startDirection = .North;
                }
            },
            .West => {
                if (y == 0 and startVertical) {
                    startDirection = .South;
                } else if (y == self.h - 1 and !startVertical) {
                    startDirection = .North;
                } else {
                    startDirection = .East;
                }
            },
        }

        var newBeam: Beam = .{ .x = x, .y = y, .dir = startDirection };
        if (x == 0 and y == 1) std.debug.print("Resetting at {d}x{d} -> {any}\n", .{ x, y, newBeam.dir });
        var pRes = self.proccessNewBeamDirection(&newBeam, true);
        if (x == 0 and y == 1) std.debug.print("After processing at {d}x{d} -> {any}\n", .{ x, y, newBeam.dir });
        if (pRes.remove) {
            return;
        }
        try self.beams.append(newBeam);
        try self.getDirection(x, y).append(newBeam.dir);

        if (pRes.extraDirection) |newDir| {
            try self.beams.append(.{ .x = x, .y = y, .dir = newDir });
            try self.getDirection(x, y).append(newDir);
        }
    }

    pub fn deinit(self: *Grid) void {
        self.beams.deinit();
        for (self.directions) |*d| d.deinit();
        self.alloc.free(self.data);
        self.alloc.free(self.directions);
    }
};

fn parseAll(alloc: std.mem.Allocator, input: []const u8) !Grid {
    return try Grid.parseFromText(alloc, input);
}

fn doRoundPart1(alloc: std.mem.Allocator, grid: *Grid) !u64 {
    _ = alloc;
    std.debug.print("Part 1:\n", .{});

    //try grid.drawGrid();
    try grid.run();
    if (printDebug) try grid.drawGrid();

    return grid.getEnergizedTiles();
}

fn doRoundPart2(alloc: std.mem.Allocator, grid: *Grid) !u64 {
    _ = alloc;
    std.debug.print("Part 2:\n", .{});

    var max: u64 = 0;

    for (0..grid.w) |x| {
        try grid.reset(x, 0, true);
        try grid.run();
        var newMax = try grid.getEnergizedTiles();
        if (newMax > max) {
            max = newMax;
            std.debug.print("New max: {d}x{d} -> {d} (v)\n", .{ x, 0, max });
            if (printDebug) try grid.drawGrid();
        }
        try grid.reset(x, grid.h - 1, true);
        try grid.run();
        var newMax2 = try grid.getEnergizedTiles();
        if (newMax2 > max) {
            max = newMax2;
            std.debug.print("New max: {d}x{d} -> {d} (v)\n", .{ x, grid.h - 1, max });
            if (printDebug) try grid.drawGrid();
        }
    }

    for (0..grid.h) |y| {
        try grid.reset(0, y, false);
        try grid.run();
        var newMax = try grid.getEnergizedTiles();
        if (newMax > max) {
            max = newMax;
            std.debug.print("New max: {d}x{d} -> {d} (h)\n", .{ 0, y, max });
            if (printDebug) try grid.drawGrid();
        }
        try grid.reset(grid.h - 1, 0, false);
        try grid.run();
        var newMax2 = try grid.getEnergizedTiles();
        if (newMax2 > max) {
            max = newMax2;
            std.debug.print("New max: {d}x{d} -> {d} (h)\n", .{ grid.h - 1, 0, max });
            if (printDebug) try grid.drawGrid();
        }
    }

    return max;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var grid = try parseAll(alloc, input);
    defer grid.deinit();

    const part1 = try doRoundPart1(alloc, &grid);
    const part2 = try doRoundPart2(alloc, &grid);

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
