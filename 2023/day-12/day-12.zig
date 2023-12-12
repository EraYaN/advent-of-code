const std = @import("std");
const util = @import("../util.zig");

const Group = struct {
    wildcards: u64,
    n: u64,
    line: []const u8,

    pub fn parseFromText(alloc: std.mem.Allocator, line: []const u8) !Group {
        _ = alloc;
        return .{ .wildcards = countInSlice(line, '?'), .n = line.len, .line = line };
    }
};

const factor = 5;

pub fn hash(springs: []const u8, arrangement: []const u8) u64 {
    var hasher = std.hash.Wyhash.init(0);

    hasher.update(springs);
    hasher.update(arrangement);

    return hasher.final();
}

const Row = struct {
    springs: []const u8,
    arrangement: []const u8,
    groups: []Group,

    pub fn getFactoredSprings(self: *const Row, alloc: std.mem.Allocator) ![]const u8 {
        var b = std.ArrayList(u8).init(alloc);
        defer b.deinit();
        for (0..factor) |n| {
            for (self.springs) |s| {
                _ = try b.append(s);
            }
            if (n < factor - 1) {
                try b.append('?');
            }
        }
        return try b.toOwnedSlice();
    }

    pub fn getFactoredArrangement(self: *const Row, alloc: std.mem.Allocator) ![]const u8 {
        var b = std.ArrayList(u8).init(alloc);
        defer b.deinit();
        for (0..factor) |n| {
            _ = n;
            for (self.arrangement) |a| {
                _ = try b.append(a);
            }
        }
        return try b.toOwnedSlice();
    }

    pub fn parseFromText(alloc: std.mem.Allocator, line: []const u8) !Row {
        var split = std.mem.tokenize(u8, line, " ,");

        var springs = split.next().?;
        var arrangement = std.ArrayList(u8).init(alloc);
        var groups = std.ArrayList(Group).init(alloc);
        defer arrangement.deinit();
        defer groups.deinit();
        while (split.next()) |a| {
            try arrangement.append(try std.fmt.parseInt(u8, a, 10));
        }
        var springs_split = std.mem.tokenize(u8, springs, ".");
        while (springs_split.next()) |group| {
            try groups.append(try Group.parseFromText(alloc, group));
        }
        return .{ .springs = springs, .arrangement = try arrangement.toOwnedSlice(), .groups = try groups.toOwnedSlice() };
    }
};

pub fn getTotalArrangements(springs: []const u8, arrangement: []const u8, cache: *std.AutoHashMap(u64, u64)) !u64 {
    var total: u64 = 1;
    _ = total;

    if (springs.len == 0) {
        if (arrangement.len == 0) {
            return 1;
        }
        return 0;
    }

    // test cache
    if (cache.get(hash(springs, arrangement))) |value| {
        return value;
    }

    if (arrangement.len == 0) {
        if (itemsContains(springs, '#')) {
            return 0;
        }
        return 1;
    }

    var result: u64 = 0;

    const first = springs[0];

    if (first == '.' or first == '?') {
        result += try getTotalArrangements(springs[1..], arrangement, cache);
    }

    if (first == '#' or first == '?') {
        if (springs.len >= arrangement[0] and !itemsContains(springs[0..arrangement[0]], '.')) {
            if (arrangement[0] == springs.len) {
                result += try getTotalArrangements(springs[arrangement[0]..], arrangement[1..], cache);
            } else {
                if (springs[arrangement[0]] == '.' or springs[arrangement[0]] == '?') {
                    result += try getTotalArrangements(springs[arrangement[0] + 1 ..], arrangement[1..], cache);
                }
            }
        }
    }

    try cache.put(hash(springs, arrangement), result);
    return result;
}

fn countInSlice(s: []const u8, c: u8) u64 {
    var count: u64 = 0;
    for (s) |c2| {
        if (c2 == c) {
            count += 1;
        }
    }
    return count;
}

fn itemsContains(items: []const u8, value: u8) bool {
    for (items) |item| {
        if (item == value) {
            return true;
        }
    }
    return false;
}

fn parseAll(alloc: std.mem.Allocator, input: []const u8) ![]Row {
    var input_text = std.mem.split(u8, input, "\n");

    var list = std.ArrayList(Row).init(alloc);
    defer list.deinit();
    //defer for (list.items) |m| m.deinit();

    while (input_text.next()) |line| {
        try list.append(try Row.parseFromText(alloc, line));
    }

    return try list.toOwnedSlice();
}

fn doRoundPart1(alloc: std.mem.Allocator, rows: []Row, cache: *std.AutoHashMap(u64, u64)) !u64 {
    std.debug.print("Part 1:\n", .{});
    _ = alloc;
    var total: u64 = 0;
    for (rows) |row| {
        var row_total = try getTotalArrangements(row.springs, row.arrangement, cache);
        std.debug.print("{s} {any} {d}\n", .{ row.springs, row.arrangement, row_total });
        total += row_total;
    }
    return total;
}

fn doRoundPart2(alloc: std.mem.Allocator, rows: []Row, cache: *std.AutoHashMap(u64, u64)) !u64 {
    std.debug.print("Part 2:\n", .{});
    var total: u64 = 0;
    for (rows, 0..) |row, n| {
        var fSprings = try row.getFactoredSprings(alloc);
        defer alloc.free(fSprings);
        var fArrangement = try row.getFactoredArrangement(alloc);
        defer alloc.free(fArrangement);
        var row_total = try getTotalArrangements(fSprings, fArrangement, cache);
        std.debug.print("{d}: {s} {any} {d}\n", .{ n, fSprings, fArrangement, row_total });
        total += row_total;
    }

    return total;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var cache: std.AutoHashMap(u64, u64) = std.AutoHashMap(u64, u64).init(alloc);
    defer cache.deinit();
    var rows = try parseAll(alloc, input);
    defer alloc.free(rows);
    defer for (rows) |r| alloc.free(r.arrangement);
    defer for (rows) |r| alloc.free(r.groups);

    const part1 = try doRoundPart1(alloc, rows, &cache);
    const part2 = try doRoundPart2(alloc, rows, &cache);

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
