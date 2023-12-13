const std = @import("std");
const util = @import("../util.zig");

const Direction = enum {
    Horizontal,
    Vertical,
};

const Reflection = struct {
    // n is the line above or before the reflection
    n: usize,
    dir: Direction,
    pattern: *const Pattern,
    hasSmudge: bool,
    smudgeX: usize,
    smudgeY: usize,

    pub fn drawReflection(self: *const Reflection) void {
        if (self.dir == Direction.Horizontal) {
            std.debug.print("Horizontal reflection at {d}\n", .{self.n + 1});
        } else {
            std.debug.print("Vertical reflection at {d}\n", .{self.n + 1});
        }
        std.debug.print("'", .{});
        for (0..self.pattern.*.w) |x| {
            if ((self.n == x or self.n + 1 == x) and self.dir == Direction.Vertical) {
                std.debug.print("v", .{});
            } else {
                std.debug.print(" ", .{});
            }
        }
        std.debug.print("'\n", .{});

        for (0..self.pattern.*.h) |y| {
            if ((self.n == y or self.n + 1 == y) and self.dir == Direction.Horizontal) {
                std.debug.print(">", .{});
            } else {
                std.debug.print(" ", .{});
            }

            for (0..self.pattern.*.w) |x| {
                if (self.hasSmudge and y == self.smudgeY and x == self.smudgeX) {
                    std.debug.print("O", .{});
                } else {
                    std.debug.print("{c}", .{self.pattern.*.get(x, y)});
                }
            }

            if ((self.n == y or self.n + 1 == y) and self.dir == Direction.Horizontal) {
                std.debug.print("<", .{});
            } else {
                std.debug.print(" ", .{});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("'", .{});
        for (0..self.pattern.*.w) |x| {
            if ((self.n == x or self.n + 1 == x) and self.dir == Direction.Vertical) {
                std.debug.print("^", .{});
            } else {
                std.debug.print(" ", .{});
            }
        }
        std.debug.print("'\n", .{});
    }
};

const Pattern = struct {
    w: u64,
    h: u64,
    data: []const u8,

    pub fn get(self: *const Pattern, x: u64, y: u64) u8 {
        if (y * (self.w + 1) + x > self.data.len) {
            std.debug.print("Out of bounds: {d}x{d} -> {d} out of {d}\n", .{ x, y, y * (self.w + 1) + x, self.data.len });
        }
        return self.data[y * (self.w + 1) + x];
    }

    pub fn getHorizontalReflection(self: *const Pattern, require_smudge: bool) ?Reflection {
        for (0..self.h) |y| {
            var res = self.isReflectionHorizontal(y, require_smudge);
            if (res.isRef and (!require_smudge or res.hasSmudge)) {
                return .{ .n = y, .dir = Direction.Horizontal, .pattern = self, .hasSmudge = res.hasSmudge, .smudgeX = res.x, .smudgeY = res.y };
            }
        }
        return null;
    }

    pub fn getVerticalReflection(self: *const Pattern, require_smudge: bool) ?Reflection {
        for (0..self.w) |x| {
            var res = self.isReflectionVertical(x, require_smudge);
            if (res.isRef and (!require_smudge or res.hasSmudge)) {
                return .{ .n = x, .dir = Direction.Vertical, .pattern = self, .hasSmudge = res.hasSmudge, .smudgeX = res.x, .smudgeY = res.y };
            }
        }
        return null;
    }

    pub fn isReflectionHorizontal(self: *const Pattern, n: usize, allow_smudge: bool) struct { isRef: bool, hasSmudge: bool, x: usize, y: usize } {
        if (n >= self.h - 1) {
            return .{ .isRef = false, .hasSmudge = false, .x = 0, .y = 0 }; // can't be on the bottom
        }
        var hasSmudge: bool = false;
        var smudgeX: usize = 0;
        var smudgeY: usize = 0;
        //std.debug.print("Checking upto offset: min({d}, {d}) -> {d}\n", .{ n, self.h - 2 - n, @min(n, self.h - 2 - n) });
        for (0..@min(n, (self.h - 2 - n)) + 1) |offset| {
            const top_line = n - offset;
            const bottom_line = n + offset + 1;
            //std.debug.print("Checking line: {d} and {d} for offset {d} from start {d}\n", .{ top_line, bottom_line, offset, n });

            // for (0..self.w) |x| {
            //     std.debug.print("{c}", .{self.get(x, top_line)});
            // }
            // std.debug.print("\n", .{});
            // for (0..self.w) |x| {
            //     std.debug.print("{c}", .{self.get(x, bottom_line)});
            // }
            // std.debug.print("\n", .{});
            for (0..self.w) |x| {
                //std.debug.print("x({d}): '{c}' == '{c}' => {any}\n", .{ x, self.get(x, top_line), self.get(x, bottom_line), self.get(x, top_line) == self.get(x, bottom_line) });
                if (self.get(x, top_line) != self.get(x, bottom_line)) {
                    if (allow_smudge and !hasSmudge) {
                        hasSmudge = true;
                        smudgeX = x;
                        smudgeY = bottom_line;
                    } else {
                        return .{ .isRef = false, .hasSmudge = hasSmudge, .x = smudgeX, .y = smudgeY };
                    }
                }
            }
        }
        return .{ .isRef = true, .hasSmudge = hasSmudge, .x = smudgeX, .y = smudgeY };
    }

    pub fn isReflectionVertical(self: *const Pattern, n: usize, allow_smudge: bool) struct { isRef: bool, hasSmudge: bool, x: usize, y: usize } {
        if (n >= self.w - 1) {
            return .{ .isRef = false, .hasSmudge = false, .x = 0, .y = 0 }; // can't be on the right
        }
        var hasSmudge: bool = false;
        var smudgeX: usize = 0;
        var smudgeY: usize = 0;

        //std.debug.print("Checking upto offset: min({d}, {d}) -> {d}\n", .{ n, self.w - 2 - n, @min(n, self.w - 2 - n) });
        for (0..@min(n, (self.w - 2 - n)) + 1) |offset| {
            const top_line = n - offset;
            const bottom_line = n + offset + 1;
            //std.debug.print("Checking line: {d} and {d} for offset {d} from start {d}\n", .{ top_line, bottom_line, offset, n });

            // for (0..self.h) |y| {
            //     std.debug.print("{c} {c}\n", .{ self.get(top_line, y), self.get(bottom_line, y) });
            // }
            for (0..self.h) |y| {
                //std.debug.print("x({d}): '{c}' == '{c}' => {any}\n", .{ x, self.get(x, top_line), self.get(x, bottom_line), self.get(x, top_line) == self.get(x, bottom_line) });
                if (self.get(top_line, y) != self.get(bottom_line, y)) {
                    if (allow_smudge and !hasSmudge) {
                        smudgeX = bottom_line;
                        smudgeY = y;
                        hasSmudge = true;
                    } else {
                        return .{ .isRef = false, .hasSmudge = hasSmudge, .x = smudgeX, .y = smudgeY };
                    }
                }
            }
        }
        return .{ .isRef = true, .hasSmudge = hasSmudge, .x = smudgeX, .y = smudgeY };
    }

    pub fn parseFromText(alloc: std.mem.Allocator, pattern: []const u8) !Pattern {
        _ = alloc;
        var x: u64 = 0;
        var y: u64 = 0;

        for (pattern) |c| {
            if (c == '\n') {
                y += 1;
            } else {
                if (y == 0) {
                    x += 1;
                }
            }
        }

        y += 1;

        // var patternBuf = try alloc.alloc(u8, pattern.len - (y - 1));
        // var patternIdx: usize = 0;
        // _ = patternIdx;
        // for (0..pattern.len) |i| {
        //     if (pattern[i] == '\n') {
        //         @memcpy(patternBuf[patternBuf], &pattern[i + 1]);
        //     }
        // }
        // pattern = pattern[0 .. y - 1];
        std.debug.print("Parsed pattern: ({d}x{d})\n'{s}'\n\n", .{ x, y, pattern });

        return .{ .data = pattern, .w = x, .h = y };
    }
};

fn parseAll(alloc: std.mem.Allocator, input: []const u8) ![]Pattern {
    var input_text = std.mem.split(u8, input, "\n\n");

    var list = std.ArrayList(Pattern).init(alloc);
    defer list.deinit();
    //defer for (list.items) |m| m.deinit();

    while (input_text.next()) |pat| {
        try list.append(try Pattern.parseFromText(alloc, pat));
    }

    return try list.toOwnedSlice();
}

fn doRoundPart1(alloc: std.mem.Allocator, patterns: []Pattern) !u64 {
    _ = alloc;
    std.debug.print("Part 1:\n", .{});

    var hori: u64 = 0;
    var vert: u64 = 0;

    for (patterns) |pat| {
        var r = pat.getHorizontalReflection(false);
        var vr = pat.getVerticalReflection(false);

        if (r) |ref| {
            std.debug.print("Got horizontal reflection along: {d}\n", .{ref.n});
            hori += ref.n + 1;
        } else if (vr) |ref| {
            std.debug.print("Got vertical reflection along: {d}\n", .{ref.n});
            vert += ref.n + 1;
        }
    }
    return vert + 100 * hori;
}

fn doRoundPart2(alloc: std.mem.Allocator, patterns: []Pattern) !u64 {
    _ = alloc;
    std.debug.print("Part 2:\n", .{});
    var hori: u64 = 0;
    var vert: u64 = 0;

    for (patterns, 0..) |pat, i| {
        var r = pat.getHorizontalReflection(true);
        var vr = pat.getVerticalReflection(true);
        if (r != null and vr != null) {
            var resh = r.?;
            var resv = vr.?;
            resh.drawReflection();
            resv.drawReflection();
            if ((resh.hasSmudge and resv.hasSmudge)) {
                std.debug.print("{d}: Got both reflections along: {d} and {d} (score: {d})\n", .{ i, resh.n + 1, resv.n + 1, (resh.n + 1) * 100 + (resv.n + 1) });
                hori += resh.n + 1;
                vert += resv.n + 1;
            } else if (resh.hasSmudge) {
                std.debug.print("{d}: Got horizontal reflection along (vertical didn't have a smudge): {d} (vert:{d}) (score: {d})\n", .{ i, resh.n + 1, resv.n + 1, (resh.n + 1) * 100 });
                hori += resh.n + 1;
            } else if (resv.hasSmudge) {
                std.debug.print("{d}: Got vertical reflection along (horizontal didn't have a smudge): {d} (hori:{d})\n", .{ i, resv.n + 1, resh.n + 1 });
                vert += resv.n + 1;
            } else {
                std.debug.print("{d}: Got both reflections without smudges along: {d} and {d} (score: {d})\n", .{ i, resh.n + 1, resv.n + 1, (resh.n + 1) * 100 + (resv.n + 1) });
                hori += resh.n + 1;
                vert += resv.n + 1;
            }
        } else if (r) |ref| {
            ref.drawReflection();
            std.debug.print("{d}: Got horizontal reflection along: {d} (score: {d})\n", .{ i, ref.n + 1, (ref.n + 1) * 100 });
            hori += ref.n + 1;
        } else if (vr) |ref| {
            ref.drawReflection();
            std.debug.print("{d}: Got vertical reflection along: {d}\n", .{ i, ref.n + 1 });
            vert += ref.n + 1;
        }
    }
    return vert + 100 * hori;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var patterns = try parseAll(alloc, input);
    defer alloc.free(patterns);

    const part1 = try doRoundPart1(alloc, patterns);
    const part2 = try doRoundPart2(alloc, patterns);

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
