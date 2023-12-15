const std = @import("std");
const util = @import("../util.zig");

const CustomHashMap = struct {
    hashTable: []std.StringArrayHashMap(u8),

    pub fn hash(s: []const u8) u64 {
        var h: u64 = 0;
        for (s) |c| {
            h += @as(u64, @intCast(c));
            h *= 17;
            h %= 256;
        }
        return h;
    }

    pub fn make(alloc: std.mem.Allocator) !CustomHashMap {
        var chm = CustomHashMap{
            .hashTable = try alloc.alloc(std.StringArrayHashMap(u8), 256),
        };
        for (0..256) |i| {
            var arrL = std.StringArrayHashMap(u8).init(alloc);
            chm.hashTable[i] = arrL;
        }
        return chm;
    }
};

fn parseAll(alloc: std.mem.Allocator, input: []const u8) ![][]const u8 {
    var tokens = std.mem.tokenize(u8, input, ",");

    var t = std.ArrayList([]const u8).init(alloc);
    defer t.deinit();
    // ...
    while (tokens.next()) |token| {
        try t.append(token);
    }
    return t.toOwnedSlice();
}

fn doRoundPart1(alloc: std.mem.Allocator, tokens: [][]const u8) !u64 {
    _ = alloc;
    std.debug.print("Part 1:\n", .{});
    var sum: u64 = 0;
    for (tokens) |token| {
        var h = CustomHashMap.hash(token);
        std.debug.print("{s} -> {d}\n", .{ token, h });
        sum += h;
    }
    return sum;
}

fn doRoundPart2(alloc: std.mem.Allocator, tokens: [][]const u8) !u64 {
    std.debug.print("Part 2:\n", .{});
    var hashMap = try CustomHashMap.make(alloc);

    defer alloc.free(hashMap.hashTable);
    defer for (0..hashMap.hashTable.len) |h| {
        hashMap.hashTable[h].deinit();
    };

    for (tokens) |token| {
        var subtokens = std.mem.tokenize(u8, token, "=-");
        var name = subtokens.next().?;
        var value = subtokens.next();
        var h = CustomHashMap.hash(name);
        if (value) |v| {
            // set
            //std.debug.print("set: {s} -> {d} -> {s}\n", .{ name, h, v });
            try hashMap.hashTable[h].put(name, v[0] - '0');
        } else {
            // unset
            //std.debug.print("unset: {s} -> {d}\n", .{ name, h });
            _ = hashMap.hashTable[h].orderedRemove(name);
        }
    }
    var sum: u64 = 0;
    for (0..hashMap.hashTable.len) |idx| {
        //std.debug.print("box {d} {d}\n", .{ idx, hashMap.hashTable[idx].count() });
        for (hashMap.hashTable[idx].keys(), 0..) |key, i| {
            var v = hashMap.hashTable[idx].get(key);
            if (v) |value| {
                var score = @as(u64, @intCast(value)) * (idx + 1) * (i + 1);
                //std.debug.print("box {d}, slot {d} -> lens {s} {d} -> {d}\n", .{ idx, i + 1, key, value, score });
                sum += score;
            }
        }
    }
    return sum;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var tokens = try parseAll(alloc, input);
    defer alloc.free(tokens);

    const part1 = try doRoundPart1(alloc, tokens);
    const part2 = try doRoundPart2(alloc, tokens);

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
