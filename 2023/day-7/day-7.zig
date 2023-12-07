const std = @import("std");
const util = @import("../util.zig");

const HandType = enum {
    FiveOfAKind,
    FourOfAKind,
    FullHouse,
    ThreeOfAKind,
    TwoPair,
    OnePair,
    HighCard,
};

const Bid = struct {
    hand: []const u8,
    bid: u64,
};

const HandTypeScore = struct { hand: HandType, card_score: u64 };

const cards = [_]u8{
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'J',
    'T',
    'Q',
    'K',
    'A',
};

const cards2 = [_]u8{
    'J',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'T',
    'Q',
    'K',
    'A',
};

fn cardScore(c: u8) u64 {
    return switch (c) {
        '2' => 1,
        '3' => 2,
        '4' => 3,
        '5' => 4,
        '6' => 5,
        '7' => 6,
        '8' => 7,
        '9' => 8,
        'T' => 9,
        'J' => 10,
        'Q' => 11,
        'K' => 12,
        'A' => 13,
        else => unreachable,
    };
}

fn cardScore2(c: u8) u64 {
    return switch (c) {
        '2' => 2,
        '3' => 3,
        '4' => 4,
        '5' => 5,
        '6' => 6,
        '7' => 7,
        '8' => 8,
        '9' => 9,
        'T' => 10,
        'J' => 1,
        'Q' => 11,
        'K' => 12,
        'A' => 13,
        else => unreachable,
    };
}

fn handScore2(h: HandType) u64 {
    //const factor = std.math.pow(u64, 13, 6);
    return switch (h) {
        HandType.FiveOfAKind => 7 * 13, // * factor + h.card_score,
        HandType.FourOfAKind => 6 * 13, // * factor + h.card_score,
        HandType.FullHouse => 5 * 13, // * factor + h.card_score,
        HandType.ThreeOfAKind => 4 * 13, // * factor + h.card_score,
        HandType.TwoPair => 3 * 13, // * factor + h.card_score,
        HandType.OnePair => 2 * 13, // * factor + h.card_score,
        HandType.HighCard => 1 * 13, // * factor + h.card_score,
    };
}

fn handScore(h: HandTypeScore) u64 {
    //const factor = std.math.pow(u64, 13, 6);
    return switch (h.hand) {
        HandType.FiveOfAKind => 7 * 13, // * factor + h.card_score,
        HandType.FourOfAKind => 6 * 13, // * factor + h.card_score,
        HandType.FullHouse => 5 * 13, // * factor + h.card_score,
        HandType.ThreeOfAKind => 4 * 13, // * factor + h.card_score,
        HandType.TwoPair => 3 * 13, // * factor + h.card_score,
        HandType.OnePair => 2 * 13, // * factor + h.card_score,
        HandType.HighCard => 1 * 13, // * factor + h.card_score,
    };
}

fn strCount(haystack: []const u8, needle: u8) u64 {
    var count: u64 = 0;
    for (haystack) |c| {
        if (c == needle) {
            count += 1;
        }
    }
    return count;
}

fn strCount2(haystack: []const u8, needle: u8) u64 {
    var count: u64 = 0;
    for (haystack) |c| {
        if (c == needle) {
            count += 1;
        }
    }
    return count;
}

fn findInList(a: std.ArrayList(HandType), b: HandType) bool {
    for (a.items) |item| {
        if (item == b) {
            return true;
        }
    } else return false;
}

fn getHandType(hand: []const u8) HandTypeScore {
    var freq = std.mem.zeroes([cards.len]u64);

    for (cards, 0..) |card, i| {
        const f = strCount(hand, card);
        if (f == 5) {
            return .{ .hand = HandType.FiveOfAKind, .card_score = 0 };
        } else if (f == 4) {
            return .{ .hand = HandType.FourOfAKind, .card_score = 0 };
        }
        freq[i] = f;
    }
    for (0..freq.len) |i| {
        if (freq[i] == 3) {
            for (0..freq.len) |j| {
                if (j == i) {
                    continue;
                }
                if (freq[j] == 2) {
                    return .{ .hand = HandType.FullHouse, .card_score = 0 };
                }
            }
            return .{ .hand = HandType.ThreeOfAKind, .card_score = 0 };
        } else if (freq[i] == 2) {
            for (0..freq.len) |j| {
                if (j == i) {
                    continue;
                }
                if (freq[j] == 3) {
                    return .{ .hand = HandType.FullHouse, .card_score = 0 };
                } else if (freq[j] == 2) {
                    return .{ .hand = HandType.TwoPair, .card_score = 0 };
                }
            }
            return .{ .hand = HandType.OnePair, .card_score = 0 };
        }
    }
    return .{ .hand = HandType.HighCard, .card_score = 0 };
}

fn getHandType2(alloc: std.mem.Allocator, hand: []const u8) !HandType {
    var freq = std.mem.zeroes([cards2.len]u64);

    var joker_count: u64 = strCount(hand, 'J');
    // std.debug.print("{s}\n", .{hand});
    // for (0..freq.len) |i| {
    //     std.debug.print("{c} -> {d}\n", .{ cards2[i], freq[i] });
    // }

    var list = std.ArrayList(HandType).init(alloc);
    defer list.deinit();

    for (cards2, 0..) |card, i| {
        const f = strCount(hand, card);

        if (cards2[i] != 'J') {
            //std.debug.print("{s} ({c}): joker_count: {d} freq {d}\n", .{ hand, cards2[i], joker_count, f });
            if (f == 5 or f + joker_count == 5) {
                try list.append(HandType.FiveOfAKind);
            } else if (f == 4 or f + joker_count == 4) {
                try list.append(HandType.FourOfAKind);
            }
        }
        freq[i] = f;
    }

    outer: for (0..freq.len) |i| {
        if (cards2[i] == 'J') {
            continue;
        }
        joker_count = strCount(hand, 'J');
        //std.debug.print("{s} ({c}): ajoker_count: {d}\n", .{ hand, cards2[i], joker_count });
        if (freq[i] == 3 or freq[i] + joker_count >= 3) {
            joker_count = joker_count - (3 - @min(3, freq[i]));
            //std.debug.print("{s} ({c}): bjoker_count left: {d}\n", .{ hand, cards2[i], joker_count });
            for (0..freq.len) |j| {
                if (j == i or cards2[j] == 'J') {
                    continue;
                }
                if (freq[j] == 2 or freq[j] + joker_count == 2) {
                    try list.append(HandType.FullHouse);
                    continue :outer;
                }
            }
            try list.append(HandType.ThreeOfAKind);
            continue :outer;
        } else if (freq[i] == 2 or freq[i] + joker_count >= 2) {
            joker_count = joker_count - (2 - @min(2, freq[i]));
            //std.debug.print("{s} ({c}): cjoker_count left: {d}\n", .{ hand, cards2[i], joker_count });
            for (0..freq.len) |j| {
                if (j == i or cards2[j] == 'J') {
                    continue;
                }
                if (freq[j] == 3 or freq[j] + joker_count == 3) {
                    try list.append(HandType.FullHouse);
                    continue :outer;
                } else if (freq[j] == 2 or freq[j] + joker_count == 2) {
                    try list.append(HandType.TwoPair);
                    continue :outer;
                }
            }
            try list.append(HandType.OnePair);
            continue :outer;
        }
    }
    //for (list.items) |item| std.debug.print("{s}\n", .{@tagName(item)});

    if (findInList(list, HandType.FiveOfAKind)) {
        return HandType.FiveOfAKind;
    } else if (findInList(list, HandType.FourOfAKind)) {
        return HandType.FourOfAKind;
    } else if (findInList(list, HandType.FullHouse)) {
        return HandType.FullHouse;
    } else if (findInList(list, HandType.ThreeOfAKind)) {
        return HandType.ThreeOfAKind;
    } else if (findInList(list, HandType.TwoPair)) {
        return HandType.TwoPair;
    } else if (findInList(list, HandType.OnePair)) {
        return HandType.OnePair;
    }

    return HandType.HighCard;
}

fn parseAll(alloc: std.mem.Allocator, input: []const u8) ![]Bid {
    var input_text = std.mem.split(u8, input, "\n");

    var list = std.ArrayList(Bid).init(alloc);
    defer list.deinit();
    //defer for (list.items) |m| m.deinit();

    while (input_text.next()) |line| {
        var s = std.mem.split(u8, line, " ");
        var hand = s.next().?;
        std.debug.print("{s} -> ", .{hand});
        var new_hand: []u8 = try alloc.alloc(u8, 5);
        std.mem.copy(u8, new_hand, hand);
        //std.sort.heap(u8, new_hand, {}, cmpByValueCard);
        std.debug.print("{s}\n", .{new_hand});

        try list.append(.{ .hand = new_hand, .bid = try std.fmt.parseInt(u64, s.next().?, 10) });
    }

    return list.toOwnedSlice();
}

fn cmpByValue(context: void, a: Bid, b: Bid) bool {
    var scoreA: u64 = handScore(getHandType(a.hand));
    var scoreB: u64 = handScore(getHandType(b.hand));
    if (scoreA == scoreB) {
        for (a.hand, b.hand) |ca, cb| {
            if (cardScore(ca) > cardScore(cb)) {
                //std.debug.print("A ({s}) {c} > B ({s}) {c}\n", .{ a.hand, ca, b.hand, cb });
                scoreA += 1;
                break;
            } else if (cardScore(ca) < cardScore(cb)) {
                //std.debug.print("A ({s}) {c} < B ({s}) {c}\n", .{ a.hand, ca, b.hand, cb });
                scoreB += 1;
                break;
            }
        }
    }
    return std.sort.asc(u64)(context, scoreA, scoreB);
}

fn cmpByValue2(context: void, a: Bid, b: Bid) bool {
    var scoreA: u64 = handScore2(getHandType2(std.heap.page_allocator, a.hand) catch HandType.HighCard);
    var scoreB: u64 = handScore2(getHandType2(std.heap.page_allocator, b.hand) catch HandType.HighCard);
    if (scoreA == scoreB) {
        for (a.hand, b.hand) |ca, cb| {
            if (cardScore2(ca) > cardScore2(cb)) {
                //std.debug.print("A ({s}) {c} > B ({s}) {c}\n", .{ a.hand, ca, b.hand, cb });
                scoreA += 1;
                break;
            } else if (cardScore2(ca) < cardScore2(cb)) {
                //std.debug.print("A ({s}) {c} < B ({s}) {c}\n", .{ a.hand, ca, b.hand, cb });
                scoreB += 1;
                break;
            }
        }
    }
    return std.sort.asc(u64)(context, scoreA, scoreB);
}

fn cmpByValueCard(context: void, a: u8, b: u8) bool {
    const scoreA = cardScore(a);
    const scoreB = cardScore(b);
    return std.sort.desc(u64)(context, scoreA, scoreB);
}

fn cmpByValueCard2(context: void, a: u8, b: u8) bool {
    const scoreA = cardScore2(a);
    const scoreB = cardScore2(b);
    return std.sort.desc(u64)(context, scoreA, scoreB);
}

fn doRoundPart1(alloc: std.mem.Allocator, hands: []Bid) !u64 {
    _ = alloc;

    std.sort.heap(Bid, hands[0..], {}, cmpByValue);

    var score: u64 = 0;

    for (hands, 1..) |h, r| {
        const hts = getHandType(h.hand);
        score += @as(u64, @intCast(r)) * h.bid;
        std.debug.print("{d}: {s} {d} {s} -> {d}\n", .{ r, h.hand, h.bid, @tagName(hts.hand), @as(u64, @intCast(r)) * h.bid });
    }
    return score;
}

fn doRoundPart2(alloc: std.mem.Allocator, hands: []Bid) !u64 {
    std.sort.heap(Bid, hands[0..], {}, cmpByValue2);

    var score: u64 = 0;

    for (hands, 1..) |h, r| {
        const ht = try getHandType2(alloc, h.hand);
        score += @as(u64, @intCast(r)) * h.bid;
        std.debug.print("{d}: {s} {d} {s} -> {d}\n", .{ r, h.hand, h.bid, @tagName(ht), @as(u64, @intCast(r)) * h.bid });
    }
    return score;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    const hands = try parseAll(alloc, input);
    defer alloc.free(hands);
    defer for (hands) |h| alloc.free(h.hand);

    const part1 = try doRoundPart1(alloc, hands);
    const part2 = try doRoundPart2(alloc, hands);

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
    std.debug.print("\n", .{});
    const sol = try solve(std.testing.allocator, @embedFile("test.txt"));
    std.debug.print("Part 1: {d}\nPart 2: {d}\n", .{ sol[0], sol[1] });
}
