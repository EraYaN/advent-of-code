const std = @import("std");
const util = @import("../util.zig");

const blue = "blue";
const red = "red";
const green = "green";

const max_red = 12;
const max_green = 13;
const max_blue = 14;

const Hand = struct {
    red: u32,
    green: u32,
    blue: u32,

    pub fn parseFromText(line: []const u8) !Hand {
        var tokens = std.mem.tokenize(u8, line, ",");
        var hand: Hand = .{ .red = 0, .green = 0, .blue = 0 };
        while (tokens.next()) |color| {
            if (std.mem.endsWith(u8, color, red)) {
                var offset = color.len - (red.len) - 1;
                std.debug.print("Found red in hand: '{s}' -> '{s}'\n", .{ color, color[1..offset] });
                hand.red = try std.fmt.parseInt(u32, color[1..offset], 10);
            } else if (std.mem.endsWith(u8, color, green)) {
                var offset = color.len - (green.len) - 1;
                std.debug.print("Found green in hand: '{s}' -> '{s}'\n", .{ color, color[1..offset] });
                hand.green = try std.fmt.parseInt(u32, color[1..offset], 10);
            } else if (std.mem.endsWith(u8, color, blue)) {
                var offset = color.len - (blue.len) - 1;
                std.debug.print("Found blue in hand: '{s}' -> '{s}'\n", .{ color, color[1..offset] });
                hand.blue = try std.fmt.parseInt(u32, color[1..offset], 10);
            } else {
                std.debug.print("Found garbage parsing hand: '{s}' -> '{s}'\n", .{ line, color });
                unreachable;
            }
        }
        return hand;
    }
};

const Game = struct {
    id: u32,
    hands: []Hand,

    pub fn parseFromText(alloc: std.mem.Allocator, line: []const u8) !Game {
        // split on `:`
        const colon = std.mem.indexOf(u8, line, ":").? + 1;
        const game_id = try std.fmt.parseInt(u32, line[5 .. colon - 1], 10);
        const restline = line[colon..];
        std.debug.print("Game ID: {}\nRest of the line: '{s}'\n", .{ game_id, restline });
        var hands = std.ArrayList(Hand).init(alloc);
        defer hands.deinit();
        // split on `;`
        var tokens = std.mem.tokenize(u8, restline, ";");
        while (tokens.next()) |hand| {
            var handObj = try Hand.parseFromText(hand);
            try hands.append(handObj);
        }
        return .{ .id = game_id, .hands = try hands.toOwnedSlice() };
    }
};

fn parseAll(alloc: std.mem.Allocator, input: []const u8) ![]Game {
    var input_text = std.mem.split(u8, input, "\n");

    var list = std.ArrayList(Game).init(alloc);
    defer list.deinit();
    //defer for (list.items) |m| m.deinit();

    while (input_text.next()) |line| {
        var game = try Game.parseFromText(alloc, line);
        try list.append(game);
    }

    return list.toOwnedSlice();
}

fn doRoundPart1(alloc: std.mem.Allocator, games: []Game) !u32 {
    var id_sum: u32 = 0;
    for (games) |game| {
        var impossible = false;
        for (game.hands) |hand| {
            if (hand.red > max_red or hand.green > max_green or hand.blue > max_blue) {
                impossible = true;
                break;
            }
        }
        if (impossible) {
            continue;
        }
        std.debug.print("Game {} is possilbe.\n", .{game.id});
        id_sum += game.id;
    }
    _ = alloc;
    return id_sum;
}

fn doRoundPart2(alloc: std.mem.Allocator, games: []Game) !u32 {
    var power_sum: u32 = 0;
    for (games) |game| {
        var min_red: u32 = 0;
        var min_green: u32 = 0;
        var min_blue: u32 = 0;
        for (game.hands) |hand| {
            if (min_red < hand.red) {
                min_red = hand.red;
            }
            if (min_green < hand.green) {
                min_green = hand.green;
            }
            if (min_blue < hand.blue) {
                min_blue = hand.blue;
            }
        }

        power_sum += min_red * min_green * min_blue;
    }
    _ = alloc;
    return power_sum;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var games = try parseAll(alloc, input);
    defer alloc.free(games);
    defer for (games) |*m| alloc.free(m.hands);
    const part1 = try doRoundPart1(alloc, games);
    const part2 = try doRoundPart2(alloc, games);

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
