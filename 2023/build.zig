const std = @import("std");

pub fn setup_day(
    b: *std.build.Builder,
    target: std.zig.CrossTarget,
    optimize: std.builtin.Mode,
    day: u32,
) void {
    const path = b.fmt("day-{}", .{day});
    const root_src = b.fmt("{s}/{s}.zig", .{ path, path });
    std.fs.cwd().access(root_src, .{ .mode = .read_only }) catch {
        return;
    };

    const exe = b.addExecutable(.{
        .name = path,
        .root_source_file = .{ .path = root_src },
        .target = target,
        .optimize = optimize,
        .main_pkg_path = .{ .path = "" },
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step(b.fmt("run-{}", .{day}), b.fmt("Run day {}", .{day}));
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = root_src },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step(b.fmt("test-{}", .{day}), b.fmt("Test day {}", .{day}));
    test_step.dependOn(&run_unit_tests.step);
}

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const optimize = b.standardOptimizeOption(.{});

    comptime var counter: usize = 1;
    inline while (counter <= 25) {
        setup_day(b, target, optimize, counter);
        counter += 1;
    }
}
