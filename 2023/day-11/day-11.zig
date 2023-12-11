const std = @import("std");
const util = @import("../util.zig");

const Direction = enum(u8) {
    North = 0,
    East = 1,
    South = 2,
    West = 3,
};

const Coord = struct {
    x: i64,
    y: i64,
};

const width = 1000000;

const Grid = struct {
    grid: []u8,
    galaxies: []Coord,
    rows: []usize,
    cols: []usize,
    x: usize,
    y: usize,

    // pub fn getGalaxyRoute(self: *const Grid, alloc: std.mem.Allocator, g1:Coord, g2:Coord) []u8 {
    //     var route_grid = try alloc.alloc(u8, self.x * self.y);
    //     @memcpy(route_grid, self.grid);

    //     return route_grid;
    // }

    pub fn parseFromText(alloc: std.mem.Allocator, lines: [][]const u8) !Grid {
        var y = lines.len;
        var x = lines[0].len;
        defer alloc.free(lines);
        const base_grid = try alloc.alloc(u8, x * y);
        defer alloc.free(base_grid);
        for (lines, 0..) |line, i| {
            for (line, 0..) |c, j| {
                base_grid[i * x + j] = c;
            }
        }
        var row_list = std.ArrayList(usize).init(alloc);
        defer row_list.deinit();
        var col_list = std.ArrayList(usize).init(alloc);
        defer col_list.deinit();
        var galaxies = std.ArrayList(Coord).init(alloc);
        defer galaxies.deinit();

        for (0..y) |i| {
            //check row
            var row_empty = true;
            for (0..x) |j| {
                if (base_grid[i * x + j] != '.') {
                    row_empty = false;
                }
            }
            if (row_empty) {
                try row_list.append(i + row_list.items.len);
            }
        }

        for (0..x) |j| {
            //check col
            var col_empty = true;
            for (0..y) |i| {
                if (base_grid[i * x + j] != '.') {
                    col_empty = false;
                }
            }
            if (col_empty) {
                try col_list.append(j + col_list.items.len);
            }
        }

        const expanded_x = x + col_list.items.len;
        const expanded_y = y + row_list.items.len;

        const expanded_grid = try alloc.alloc(u8, expanded_x * expanded_y);

        // for (row_list.items) |row| {
        //     std.debug.print("Row: {d}\n", .{row});
        // }

        // for (col_list.items) |col| {
        //     std.debug.print("Col: {d}\n", .{col});
        // }

        for (0..expanded_y) |i| {
            const offset_y = itemsLowerThan(row_list.items, i);
            for (0..expanded_x) |j| {
                const offset_x = itemsLowerThan(col_list.items, j);
                if (itemsContains(row_list.items, i) or itemsContains(col_list.items, j)) {
                    expanded_grid[i * expanded_x + j] = '.';
                } else {
                    const c = base_grid[(i - offset_y) * x + (j - offset_x)];
                    expanded_grid[i * expanded_x + j] = c;
                    if (c == '#') {
                        //std.debug.print("Galaxy: {d}, {d}\n", .{ i, j });
                        try galaxies.append(.{ .x = @as(i64, @intCast(j)), .y = @as(i64, @intCast(i)) });
                    }
                }
            }
        }

        printJustGridWithMarkers(base_grid, x, y, col_list.items, row_list.items);
        printJustGrid(expanded_grid, expanded_x, expanded_y);

        return .{ .grid = expanded_grid, .galaxies = try galaxies.toOwnedSlice(), .rows = try row_list.toOwnedSlice(), .cols = try col_list.toOwnedSlice(), .x = expanded_x, .y = expanded_y };
    }
};

fn itemsLowerThan(items: []usize, value: usize) usize {
    var count: usize = 0;
    for (items) |item| {
        if (item < value) {
            count += 1;
        }
    }
    return count;
}
fn itemsBetween(items: []usize, value1: usize, value2: usize) usize {
    var count: usize = 0;
    for (items) |item| {
        if ((item < value2 and item > value1) or (item < value1 and item > value2)) {
            count += 1;
        }
    }
    return count;
}

fn itemsContains(items: []usize, value: usize) bool {
    for (items) |item| {
        if (item == value) {
            return true;
        }
    }
    return false;
}

fn parseAll(alloc: std.mem.Allocator, input: []const u8) !Grid {
    var input_text = std.mem.split(u8, input, "\n");

    var list = std.ArrayList([]const u8).init(alloc);
    defer list.deinit();
    //defer for (list.items) |m| m.deinit();

    while (input_text.next()) |line| {
        try list.append(line);
    }

    return Grid.parseFromText(alloc, try list.toOwnedSlice());
}

fn printGrid(grid: Grid) void {
    printJustGridWithMarkers(grid.grid, grid.x, grid.y, grid.cols, grid.rows);
}

fn printJustGrid(grid: []u8, x: usize, y: usize) void {
    std.debug.print("Grid: {d}x{d}\n", .{ x, y });
    for (0..y) |i| {
        for (0..x) |j| {
            std.debug.print("{c}", .{grid[i * x + j]});
        }

        std.debug.print("\n", .{});
    }
}

fn printJustGridWithMarkers(grid: []u8, x: usize, y: usize, cols: []usize, rows: []usize) void {
    std.debug.print("Grid: {d}x{d}\n", .{ x, y });
    std.debug.print(" ", .{});
    for (0..x) |j| {
        if (itemsContains(cols, j)) {
            std.debug.print("v", .{});
        } else {
            std.debug.print(" ", .{});
        }
    }
    std.debug.print("\n", .{});
    for (0..y) |i| {
        if (itemsContains(rows, i)) {
            std.debug.print(">", .{});
        } else {
            std.debug.print(" ", .{});
        }
        for (0..x) |j| {
            std.debug.print("{c}", .{grid[i * x + j]});
        }

        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

fn doRoundPart1(alloc: std.mem.Allocator, grid: Grid) !i64 {
    _ = alloc;
    var sum: i64 = 0;
    var pair: u64 = 0;
    if (grid.galaxies.len <= 9) {
        std.debug.print("Number of galaxies: {d}\n", .{grid.galaxies.len});
        for (grid.galaxies, 0..) |g, i| {
            grid.grid[@as(usize, @intCast(g.y)) * grid.x + @as(usize, @intCast(g.x))] = @as(u8, @intCast(i + 1)) + '0';
        }
        printGrid(grid);
    }

    for (0..grid.galaxies.len - 1) |idx1| {
        var g1 = grid.galaxies[idx1];
        for (idx1 + 1..grid.galaxies.len) |idx2| {
            var g2 = grid.galaxies[idx2];
            const d = try std.math.absInt((g1.x - g2.x)) + try std.math.absInt((g1.y - g2.y));
            pair += 1;
            if (grid.galaxies.len <= 9) {
                std.debug.print("{d} ({d},{d}) Galaxy distance: {d}, {d} -> {d}, {d} = {d} -> {d} -> {d}\n", .{ pair, idx1 + 1, idx2 + 1, g1.x, g1.y, g2.x, g2.y, d, sum, sum + d });
            }
            sum += d;
        }
    }
    return sum;
}

fn doRoundPart2(alloc: std.mem.Allocator, grid: Grid) !i64 {
    _ = alloc;
    var sum: i64 = 0;
    var pair: u64 = 0;
    if (grid.galaxies.len <= 9) {
        std.debug.print("Number of galaxies: {d}\n", .{grid.galaxies.len});
        for (grid.galaxies, 0..) |g, i| {
            grid.grid[@as(usize, @intCast(g.y)) * grid.x + @as(usize, @intCast(g.x))] = @as(u8, @intCast(i + 1)) + '0';
        }
        printGrid(grid);
    }

    for (0..grid.galaxies.len - 1) |idx1| {
        var g1 = grid.galaxies[idx1];
        for (idx1 + 1..grid.galaxies.len) |idx2| {
            var g2 = grid.galaxies[idx2];
            const dv: i64 = try std.math.absInt((g1.y - g2.y));
            const dh: i64 = try std.math.absInt((g1.x - g2.x));
            const iv: i64 = @as(i64, @intCast((itemsBetween(grid.rows, @as(usize, @intCast(g1.y)), @as(usize, @intCast(g2.y))))));
            const ih: i64 = @as(i64, @intCast((itemsBetween(grid.cols, @as(usize, @intCast(g1.x)), @as(usize, @intCast(g2.x))))));
            const d = dh + dv + (iv + ih) * (width - 2);
            pair += 1;
            if (grid.galaxies.len <= 9) {
                std.debug.print("{d} ({d},{d}) Galaxy distance: {d}, {d} -> {d}, {d} = {d} -> {d} -> {d} (ex rows: {d}, cols: {d})\n", .{ pair, idx1 + 1, idx2 + 1, g1.x, g1.y, g2.x, g2.y, d, sum, sum + d, iv, ih });
            }
            sum += d;
        }
    }
    return sum;
}

fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]i64 {
    var grid = try parseAll(alloc, input);
    defer alloc.free(grid.grid);
    defer alloc.free(grid.galaxies);
    defer alloc.free(grid.rows);
    defer alloc.free(grid.cols);

    const part1 = try doRoundPart1(alloc, grid);
    const part2 = try doRoundPart2(alloc, grid);

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
