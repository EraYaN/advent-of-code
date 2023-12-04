const std = @import("std");
const util = @import("../util.zig");

const Card = struct {
    id: u64,
    numbers: []u64,
    winning_numbers: []u64,

    pub fn getPoints(self: *const Card) u64 {
        var points: u64 = 0;
        for (self.winning_numbers) |winning_number| {
            for (self.numbers) |number| {
                if (number == winning_number) {
                    //std.debug.print("Found {} in card {}\n", .{ number, self.id });
                    if (points == 0) {
                        points = 1;
                    } else {
                        points *= 2;
                    }
                }
            }
        }
        std.debug.print("{} points in card {}\n", .{ points, self.id });
        return points;
    }

    pub fn getNumerOfWinningNumbers(self: *const Card) u64 {
        var points: u64 = 0;
        for (self.winning_numbers) |winning_number| {
            for (self.numbers) |number| {
                if (number == winning_number) {
                    //std.debug.print("Found {} in card {}\n", .{ number, self.id });
                    points += 1;
                }
            }
        }
        //std.debug.print("{} winnning numbers in card {}\n", .{ points, self.id });
        return points;
    }

    pub fn parseFromText(alloc: std.mem.Allocator, line: []const u8) !Card {
        // split on `:`
        const colon = std.mem.indexOf(u8, line, ":").? + 1;
        const lastSpace = std.mem.lastIndexOf(u8, line[0..colon], " ").?;
        const card_id_text = line[lastSpace + 1 .. colon - 1];
        std.debug.print("Card ID: '{s}'\n", .{card_id_text});
        const card_id = try std.fmt.parseInt(u64, card_id_text, 10);
        const restline = line[colon..];
        std.debug.print("Card ID: {}\nRest of the line: '{s}'\n", .{ card_id, restline });
        var numbersArr = std.ArrayList(u64).init(alloc);
        var winningNumbersArr = std.ArrayList(u64).init(alloc);
        defer numbersArr.deinit();
        defer winningNumbersArr.deinit();

        var split = std.mem.split(u8, restline, " | ");
        var winning = true;
        while (split.next()) |subcard| {
            var numbers = std.mem.tokenize(u8, subcard, " ");
            while (numbers.next()) |number| {
                var num = try std.fmt.parseInt(u64, number, 10);
                if (winning) {
                    std.debug.print("Winning Number: '{s}' -> '{d}'\n", .{ number, num });
                    try winningNumbersArr.append(num);
                } else {
                    std.debug.print("Number: '{s}' -> '{d}'\n", .{ number, num });
                    try numbersArr.append(num);
                }

                //try card.numbers.append(num);
            }
            winning = false;
        }

        return .{ .id = card_id, .numbers = try numbersArr.toOwnedSlice(), .winning_numbers = try winningNumbersArr.toOwnedSlice() };
    }
};

fn parseAll(alloc: std.mem.Allocator, input: []const u8) ![]Card {
    var input_text = std.mem.split(u8, input, "\n");

    var list = std.ArrayList(Card).init(alloc);
    defer list.deinit();
    //defer for (list.items) |m| m.deinit();

    while (input_text.next()) |line| {
        var game = try Card.parseFromText(alloc, line);
        try list.append(game);
    }

    return list.toOwnedSlice();
}

fn doRoundPart1(alloc: std.mem.Allocator, cards: []Card) !u64 {
    _ = alloc;
    var points_sum: u64 = 0;
    for (cards) |card| {
        points_sum += card.getPoints();
    }
    return points_sum;
}

fn getTotalCards(card: Card, cards: []Card) u64 {
    var total_cards: u64 = 1;
    const winning_numbers = card.getNumerOfWinningNumbers();
    if (winning_numbers > 0) {
        const final_card = @min(card.id + winning_numbers, cards.len);
        //std.debug.print("Card {} has {} winning numbers, final card ID is {}\n", .{ card.id, winning_numbers, final_card });
        for (card.id..final_card) |i| {
            //std.debug.print("Processing copy of card {} for source card {}\n", .{ cards[i].id, card.id });
            total_cards += getTotalCards(cards[i], cards);
        }
    }
    return total_cards;
}

fn doRoundPart2(alloc: std.mem.Allocator, cards: []Card) !u64 {
    _ = alloc;
    var total_cards: u64 = 0;
    for (cards) |card| {
        total_cards += getTotalCards(card, cards);
    }

    return total_cards;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var cards = try parseAll(alloc, input);
    defer alloc.free(cards);
    defer for (cards) |*m| {
        alloc.free(m.numbers);
        alloc.free(m.winning_numbers);
    };
    const part1 = try doRoundPart1(alloc, cards);
    const part2 = try doRoundPart2(alloc, cards);

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
