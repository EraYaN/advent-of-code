const std = @import("std");
const util = @import("../util.zig");

const items = [_][]const u8{
    "seed-to-soil",
    "soil-to-fertilizer",
    "fertilizer-to-water",
    "water-to-light",
    "light-to-temperature",
    "temperature-to-humidity",
    "humidity-to-location",
};

const Range = struct {
    src: u64,
    dst: u64,
    len: u64,

    pub fn parseFromText(line: []const u8) !Range {
        var split = std.mem.tokenize(u8, line, " ");
        return .{
            .dst = try std.fmt.parseInt(u64, split.next().?, 10),
            .src = try std.fmt.parseInt(u64, split.next().?, 10),
            .len = try std.fmt.parseInt(u64, split.next().?, 10),
        };
    }

    pub fn containsSrc(self: *const Range, value: u64) bool {
        return self.src <= value and value < self.src + self.len;
    }

    pub fn map(self: *const Range, value: u64) ?u64 {
        if (self.containsSrc(value)) {
            //std.debug.print("Mapping {d} from {d}..{d} to {d}..{d} is {d}\n", .{ value, self.src, self.src + self.len, self.dst, self.dst + self.len, self.dst + (value - self.src) });
            return self.dst + (value - self.src);
        } else {
            return null;
        }
    }
};

const Map = struct {
    name: []const u8,
    ranges: []Range,

    pub fn parseFromText(alloc: std.mem.Allocator, lines: []const u8) !Map {
        var tokenized = std.mem.tokenize(u8, lines, "\n");
        var name: []const u8 = "";
        var ranges = std.ArrayList(Range).init(alloc);
        defer ranges.deinit();
        while (tokenized.next()) |line| {
            if (std.mem.containsAtLeast(u8, line, 1, ":")) {
                name = line[0 .. line.len - 5];
                std.debug.print("Found name: '{s}'\n", .{name});
            } else {
                var r = try Range.parseFromText(line);
                std.debug.print("Found range: {d} {d} {d}\n", r);
                try ranges.append(r);
            }
        }
        return .{ .name = name, .ranges = try ranges.toOwnedSlice() };
    }

    pub fn map(self: *const Map, value: u64) u64 {
        for (self.ranges) |*r| {
            if (r.containsSrc(value)) {
                return r.map(value).?;
            }
        }
        return value;
    }
};

const Almanac = struct {
    seeds: []u64,
    maps: []Map,

    pub fn parseFromText(alloc: std.mem.Allocator, lines: []const u8) !Almanac {
        // split on `:`
        var mapTexts = std.mem.splitSequence(u8, lines, "\n\n");
        var maps = std.ArrayList(Map).init(alloc);
        var seeds = std.ArrayList(u64).init(alloc);
        defer seeds.deinit();

        var seedsText: []const u8 = mapTexts.next().?;
        std.debug.print("seedsText: {s}\n", .{seedsText});
        var seedsSplit = std.mem.tokenize(u8, seedsText, ": ");
        _ = seedsSplit.next().?;
        while (seedsSplit.next()) |seed| {
            std.debug.print("Seed: {s}\n", .{seed});
            try seeds.append(try std.fmt.parseInt(u64, seed, 10));
        }

        while (mapTexts.next()) |mapText| {
            std.debug.print("mapText: {s}\n", .{mapText});
            var mapObj = try Map.parseFromText(alloc, mapText);
            try maps.append(mapObj);
        }

        return .{ .maps = try maps.toOwnedSlice(), .seeds = try seeds.toOwnedSlice() };
    }

    pub fn map(self: *const Almanac, value: u64) u64 {
        //std.debug.print("Getting map: {s}\n", .{map_name});
        var v: u64 = value;
        for (self.maps) |mapObj| {
            v = mapObj.map(v);
        }

        return v;
    }
};

fn parseAll(alloc: std.mem.Allocator, input: []const u8) !Almanac {
    return try Almanac.parseFromText(alloc, input);
}

fn doRoundPart1(alloc: std.mem.Allocator, almanac: Almanac) !u64 {
    _ = alloc;
    var lowest: u64 = std.math.maxInt(u64);
    for (almanac.seeds) |seed| {
        var value: u64 = almanac.map(seed);
        std.debug.print("Seed: {d}\n", .{seed});

        if (value < lowest) {
            lowest = value;
        }
    }

    return lowest;
}

fn doRoundPart2(alloc: std.mem.Allocator, almanac: Almanac) !u64 {
    _ = alloc;

    var lowest: u64 = std.math.maxInt(u64);
    for (0..almanac.seeds.len) |i| {
        if (i % 2 == 1) {
            continue;
        }
        std.debug.print("Seed range: {d} -> {d}\n", .{ almanac.seeds[i], almanac.seeds[i] + almanac.seeds[i + 1] });
        for (almanac.seeds[i]..(almanac.seeds[i] + almanac.seeds[i + 1])) |seed| {
            var value: u64 = almanac.map(seed);

            if (value < lowest) {
                lowest = value;
            }
        }
    }

    return lowest;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var almanac = try parseAll(alloc, input);
    //defer alloc.destroy(almanac);
    defer alloc.free(almanac.seeds);

    defer {
        for (almanac.maps) |*m| {
            alloc.free(m.ranges);
        }
        alloc.free(almanac.maps);
    }
    //defer almanac.maps.deinit();

    const part1 = try doRoundPart1(alloc, almanac);
    const part2 = try doRoundPart2(alloc, almanac);

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
