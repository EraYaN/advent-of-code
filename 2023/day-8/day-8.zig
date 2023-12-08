const std = @import("std");
const util = @import("../util.zig");

const Node = struct {
    name: []const u8,
    left: []const u8,
    right: []const u8,
};

const Map = struct {
    instructions: []const u8,
    nodes: std.StringArrayHashMap(Node),
};

fn parseLine(line: []const u8) Node {
    var s = std.mem.tokenize(u8, line, " =(,)");
    return .{
        .name = s.next().?,
        .left = s.next().?,
        .right = s.next().?,
    };
}

fn parseAll(alloc: std.mem.Allocator, input: []const u8) !Map {
    var input_text = std.mem.split(u8, input, "\n");

    var instr = input_text.next().?;
    _ = input_text.next().?; // empty line

    var map = std.StringArrayHashMap(Node).init(alloc);

    while (input_text.next()) |line| {
        var parsed = parseLine(line);
        try map.put(parsed.name, parsed);
    }

    return .{ .instructions = instr, .nodes = map };
}

fn doRoundPart1(alloc: std.mem.Allocator, map: Map) !u64 {
    _ = alloc;

    var current_step: u64 = 0;
    var current_name: []const u8 = "AAA";

    while (!std.mem.eql(u8, current_name, "ZZZ")) {
        var node = map.nodes.get(current_name);
        if (node != null) {
            //std.debug.print("Node found: {s}\n", .{current_name});
            if (map.instructions[current_step % map.instructions.len] == 'L') {
                current_name = node.?.left;
            } else {
                current_name = node.?.right;
            }
            current_step += 1;
        } else {
            std.debug.print("Node not found: {s}\n", .{current_name});
            return 0;
        }
    }

    return current_step;
}

fn areAllFinished(list: [][]const u8) bool {
    for (list) |item| {
        if (item[2] != 'Z') {
            return false;
        }
    }
    return true;
}

fn gcd(a: u64, b: u64) u64 {
    if (b == 0)
        return a;
    return gcd(b, a % b);
}

fn lcm_two(a: u64, b: u64) u64 {
    return (a / gcd(a, b)) * b;
}

fn lcm(numbers: []const u64) u64 {
    if (numbers.len < 2) {
        return numbers[0];
    }
    var result = lcm_two(numbers[0], numbers[1]);

    var index: usize = 2;
    const length = numbers.len;
    while (index < length) : (index += 1) {
        result = lcm_two(numbers[index], result);
    }

    return result;
}

fn doRoundPart2(alloc: std.mem.Allocator, map: Map) !u64 {
    var current_step: u64 = 0;
    var current_name: []const u8 = "AAA";

    var nodes = std.ArrayList([]const u8).init(alloc);
    defer nodes.deinit();

    for (map.nodes.keys()) |key| {
        std.debug.print("Key: {s}\n", .{key});
        if (key[2] == 'A') {
            std.debug.print("Start key: {s}\n", .{key});
            try nodes.append(key);
        }
    }

    var nodeArr = nodes.items;
    //defer alloc.free(nodeArr);

    var loopLength: []u64 = try alloc.alloc(u64, nodeArr.len);
    defer alloc.free(loopLength);

    for (0..nodeArr.len) |idx| {
        current_step = 0;

        current_name = nodeArr[idx];
        while (current_name[2] != 'Z') {
            var node = map.nodes.get(current_name).?;
            if (map.instructions[current_step % map.instructions.len] == 'L') {
                current_name = node.left;
            } else {
                current_name = node.right;
            }
            current_step += 1;
        }
        loopLength[idx] = current_step;
        std.debug.print("Found loop length {d} for {s} start.\n", .{ current_step, nodeArr[idx] });
    }

    return lcm(loopLength);
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var map = try parseAll(alloc, input);
    defer map.nodes.deinit();
    //defer alloc.free(map);
    //defer for (hands) |h| alloc.free(h.hand);

    const part1 = try doRoundPart1(alloc, map);
    const part2 = try doRoundPart2(alloc, map);

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
    std.debug.print("(1) Part 1: {d}\n (1) Part 2: {d}\n", .{ sol[0], sol[1] });

    const sol2 = try solve(std.testing.allocator, @embedFile("test2.txt"));
    std.debug.print("(2) Part 1: {d}\n (2) Part 2: {d}\n", .{ sol2[0], sol2[1] });

    const sol3 = try solve(std.testing.allocator, @embedFile("test3.txt"));
    std.debug.print("(3) Part 1: {d}\n (3) Part 2: {d}\n", .{ sol3[0], sol3[1] });
}
