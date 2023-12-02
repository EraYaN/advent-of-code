const std = @import("std");
const util = @import("../util.zig");

const one = "one";
const two = "two";
const three = "three";
const four = "four";
const five = "five";
const six = "six";
const seven = "seven";
const eight = "eight";
const nine = "nine";

fn parseAll(alloc: std.mem.Allocator, input: []const u8) ![][]const u8 {
    var input_text = std.mem.split(u8, input, "\n");

    var list = std.ArrayList([]const u8).init(alloc);
    defer list.deinit();
    //defer for (list.items) |m| m.deinit();

    while (input_text.next()) |line| {
        try list.append(line);
    }

    return list.toOwnedSlice();
}

fn doRoundPart1(alloc: std.mem.Allocator, lines: [][]const u8) !u32 {
    var firstIdx: u8 = 0;
    var lastIdx: u8 = 0;

    const zeroChar = @as(u32, '0');

    var list = std.ArrayList(u32).init(alloc);
    defer list.deinit();

    for (lines) |line| {
        firstIdx = 0;
        lastIdx = 0;
        if (line.len == 0) continue;
        for (line) |char| {
            if (char >= '0' and char <= '9') {
                if (firstIdx == 0) firstIdx = char;
                lastIdx = char;
            }
        }
        if (lastIdx > zeroChar and firstIdx > zeroChar) {
            var number = (@as(u32, lastIdx) - zeroChar) + (@as(u32, firstIdx) - zeroChar) * 10;
            std.debug.print("lines: {s}, -> firstIdx {c}, lastIdx {c}, number: {}\n", .{ line, firstIdx, lastIdx, number });
            try list.append(number);
        }
    }

    var sum: u32 = 0;
    for (list.items) |i| {
        sum += i;
    }
    std.debug.print("Sum: {}\n", .{sum});
    return sum;
}

fn doRoundPart2(alloc: std.mem.Allocator, lines: [][]const u8) !u32 {
    var firstIdx: u8 = 0;
    var lastIdx: u8 = 0;

    const zeroChar = @as(u32, '0');

    var list = std.ArrayList(u32).init(alloc);
    defer list.deinit();

    for (lines) |line| {
        firstIdx = 0;
        lastIdx = 0;
        if (line.len == 0) continue;
        for (0..line.len) |idx| {
            var char = line[idx];
            var slice = line[idx..];
            if (std.mem.startsWith(u8, slice, one)) {
                char = '1';
            } else if (std.mem.startsWith(u8, slice, two)) {
                char = '2';
            } else if (std.mem.startsWith(u8, slice, three)) {
                char = '3';
            } else if (std.mem.startsWith(u8, slice, four)) {
                char = '4';
            } else if (std.mem.startsWith(u8, slice, five)) {
                char = '5';
            } else if (std.mem.startsWith(u8, slice, six)) {
                char = '6';
            } else if (std.mem.startsWith(u8, slice, seven)) {
                char = '7';
            } else if (std.mem.startsWith(u8, slice, eight)) {
                char = '8';
            } else if (std.mem.startsWith(u8, slice, nine)) {
                char = '9';
            }
            if (char >= '0' and char <= '9') {
                if (firstIdx == 0) firstIdx = char;
                lastIdx = char;
            }
        }
        if (lastIdx > zeroChar and firstIdx > zeroChar) {
            var number = (@as(u32, lastIdx) - '0') + (@as(u32, firstIdx) - '0') * 10;
            std.debug.print("lines: {s}, -> firstIdx {c}, lastIdx {c}, number: {}\n", .{ line, firstIdx, lastIdx, number });
            try list.append(number);
        }
    }

    var sum: u32 = 0;
    for (list.items) |i| {
        sum += i;
    }
    std.debug.print("Sum: {}\n", .{sum});
    return sum;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var lines = try parseAll(alloc, input);
    defer alloc.free(lines);

    const part1 = try doRoundPart1(alloc, lines);
    const part2 = try doRoundPart2(alloc, lines);

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
    std.debug.print("Test1: Part 1: {d}\nPart 2: {d}\n", .{ sol[0], sol[1] });
    const sol2 = try solve(std.testing.allocator, @embedFile("test2.txt"));
    std.debug.print("Test 2: Part 1: {d}\nPart 2: {d}\n", .{ sol2[0], sol2[1] });
}
