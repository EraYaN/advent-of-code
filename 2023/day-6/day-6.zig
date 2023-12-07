const std = @import("std");
const util = @import("../util.zig");

const testTime = [_]u64{ 7, 15, 30 };
const testDistance = [_]u64{ 9, 40, 200 };

const inputTime = [_]u64{ 49, 87, 78, 95 };
const inputDistance = [_]u64{ 356, 1378, 1502, 1882 };

const testTime2: u64 = 71530;
const testDistance2: u64 = 940200;

const inputTime2: u64 = 49877895;
const inputDistance2: u64 = 356137815021882;

fn doRoundPart1(alloc: std.mem.Allocator, times: []const u64, distances: []const u64) !u64 {
    _ = alloc;
    var product: u64 = 1;
    const races = times.len;
    for (0..races) |race| {
        const time = times[race];
        const distance = distances[race];
        var waysToBeat: u64 = 0;
        for (0..time) |t| {
            const speed = t;
            const travelTime = time - t;
            const distanceTraveled = speed * travelTime;
            if (distanceTraveled > distance) {
                waysToBeat += 1;
            }
        }
        product *= waysToBeat;
    }

    return product;
}

fn doRoundPart2(alloc: std.mem.Allocator, time: u64, distance: u64) !u64 {
    _ = alloc;

    var waysToBeat: u64 = 0;
    for (0..time) |t| {
        const speed = t;
        const travelTime = time - t;
        const distanceTraveled = speed * travelTime;
        if (distanceTraveled > distance) {
            waysToBeat += 1;
        }
    }

    return waysToBeat;
}

fn solve(alloc: std.mem.Allocator, times: []const u64, distances: []const u64, time2: u64, distance2: u64) ![2]u64 {
    const part1 = try doRoundPart1(alloc, times, distances);
    const part2 = try doRoundPart2(alloc, time2, distance2);

    return .{ part1, part2 };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();

    const sol = try solve(allocator, &inputTime, &inputDistance, inputTime2, inputDistance2);
    std.debug.print("Part 1: {d}\nPart 2: {d}\n", .{ sol[0], sol[1] });

    if (try util.parse_cli_args(allocator)) {
        var result = try util.benchmark(allocator, solve, .{ allocator, &inputTime, &inputDistance, inputTime2, inputDistance2 }, .{ .warmup = 1, .trials = 3 });
        defer result.deinit();
        result.printSummary();
    }
}

test "test-input" {
    std.debug.print("\n", .{});
    const sol = try solve(std.testing.allocator, &testTime, &testDistance, testTime2, testDistance2);
    std.debug.print("Part 1: {d}\nPart 2: {d}\n", .{ sol[0], sol[1] });
}
