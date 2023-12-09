const std = @import("std");
const util = @import("../util.zig");

const History = []i64;

fn parseLine(alloc: std.mem.Allocator, line: []const u8) !History {
    var s = std.mem.tokenize(u8, line, " ");
    var list = std.ArrayList(i64).init(alloc);
    defer list.deinit();

    while (s.next()) |token| {
        var num = try std.fmt.parseInt(i64, token, 10);
        try list.append(num);
    }

    return list.toOwnedSlice();
}

fn parseAll(alloc: std.mem.Allocator, input: []const u8) ![]History {
    var input_text = std.mem.split(u8, input, "\n");

    var list = std.ArrayList(History).init(alloc);
    defer list.deinit();

    while (input_text.next()) |line| {
        var parsed = try parseLine(alloc, line);
        try list.append(parsed);
    }

    return list.toOwnedSlice();
}

fn isAllZero(history: History) bool {
    for (history) |col| {
        if (col != 0) return false;
    }
    return true;
}

fn getDerivative(alloc: std.mem.Allocator, history: History) !History {
    var derivative = try alloc.alloc(i64, history.len - 1);

    for (0..history.len - 1) |i| {
        derivative[i] = history[i + 1] - history[i];
    }

    return derivative;
}

fn printHistory(history: History) void {
    for (history) |col| {
        std.debug.print("{d} ", .{col});
    }
    std.debug.print("\n", .{});
}

fn getNextValue(alloc: std.mem.Allocator, history: History) !i64 {
    var localHistory = history;
    //printHistory(history);

    var derivatives = std.ArrayList(History).init(alloc);
    defer derivatives.deinit();
    defer for (derivatives.items) |d| alloc.free(d);

    while (!isAllZero(localHistory)) {
        var derivative = try getDerivative(alloc, localHistory);
        localHistory = derivative;
        try derivatives.append(derivative);
        //printHistory(localHistory);
    }

    var next_value: i64 = 0;

    var i: usize = derivatives.items.len;
    while (i > 0) {
        i -= 1;
        // loop body
        var hist = derivatives.items[i];
        //printHistory(hist);
        next_value = hist[hist.len - 1] + next_value;
        //std.debug.print("next_value: {d}\n", .{next_value});
    }
    //std.debug.print("final_new_value: {d}\n", .{history[history.len - 1] + next_value});
    return history[history.len - 1] + next_value;
}

fn getPrevValue(alloc: std.mem.Allocator, history: History) !i64 {
    var localHistory = history;
    printHistory(history);

    var derivatives = std.ArrayList(History).init(alloc);
    defer derivatives.deinit();
    defer for (derivatives.items) |d| alloc.free(d);

    while (!isAllZero(localHistory)) {
        var derivative = try getDerivative(alloc, localHistory);
        localHistory = derivative;
        try derivatives.append(derivative);
        //printHistory(localHistory);
    }

    var prev_value: i64 = 0;

    var i: usize = derivatives.items.len;
    while (i > 0) {
        i -= 1;
        // loop body
        var hist = derivatives.items[i];
        //printHistory(hist);
        prev_value = hist[0] - prev_value;
        //std.debug.print("prev_value: {d}\n", .{prev_value});
    }
    //std.debug.print("final_new_value: {d}\n", .{history[0] - prev_value});
    return history[0] - prev_value;
}

fn doRoundPart1(alloc: std.mem.Allocator, histories: []History) !i64 {
    var sum: i64 = 0;
    for (histories) |row| {
        sum += try getNextValue(alloc, row);
    }
    return sum;
}

fn doRoundPart2(alloc: std.mem.Allocator, histories: []History) !i64 {
    var sum: i64 = 0;
    for (histories) |row| {
        sum += try getPrevValue(alloc, row);
    }
    return sum;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]i64 {
    var histories = try parseAll(alloc, input);
    defer alloc.free(histories);
    defer for (histories) |h| alloc.free(h);

    const part1 = try doRoundPart1(alloc, histories);
    const part2 = try doRoundPart2(alloc, histories);

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
    std.debug.print("Part 1: {d}\nPart 2: {d}\n", .{ sol[0], sol[1] });
}
