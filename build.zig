const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const uuid_mod = b.addModule("uuid", .{
        .root_source_file = b.path("src/uuid.zig"),
    });

    const examples = [_]struct { name: []const u8, path: []const u8 }{
        .{ .name = "basic-usage", .path = "examples/basic_usage.zig" },
        .{ .name = "v1-time-based", .path = "examples/v1_time_based.zig" },
        .{ .name = "v3-md5-namespace", .path = "examples/v3_md5_namespace.zig" },
        .{ .name = "v4-random", .path = "examples/v4_random.zig" },
        .{ .name = "v5-sha1-namespace", .path = "examples/v5_sha1_namespace.zig" },
        .{ .name = "v6-reordered", .path = "examples/v6_reordered.zig" },
        .{ .name = "v7-time-ordered", .path = "examples/v7_time_ordered.zig" },
        .{ .name = "v8-application-specific", .path = "examples/v8_application_specific.zig" },
        .{ .name = "deterministic", .path = "examples/deterministic.zig" },
        .{ .name = "parsing-formats", .path = "examples/parsing_formats.zig" },
        .{ .name = "comparison", .path = "examples/comparison.zig" },
        .{ .name = "generator", .path = "examples/generator.zig" },
        .{ .name = "hash-map", .path = "examples/hash_map.zig" },
        .{ .name = "namespaces", .path = "examples/namespaces.zig" },
        .{ .name = "version-detection", .path = "examples/version_detection.zig" },
        .{ .name = "batch-generation", .path = "examples/batch_generation.zig" },
        .{ .name = "sequential-ids", .path = "examples/sequential_ids.zig" },
        .{ .name = "uuid-internals", .path = "examples/uuid_internals.zig" },
    };

    const run_all_examples = b.step("run-all-examples", "Run all examples sequentially");
    var previous_run_step: ?*std.Build.Step = null;

    inline for (examples) |example| {
        const exe = b.addExecutable(.{
            .name = example.name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(example.path),
                .target = target,
                .optimize = optimize,
            }),
        });
        exe.root_module.addImport("uuid", uuid_mod);

        const install_exe = b.addInstallArtifact(exe, .{});
        const example_step = b.step("example-" ++ example.name, "Build " ++ example.name ++ " example");
        example_step.dependOn(&install_exe.step);

        const run_exe = b.addRunArtifact(exe);
        run_exe.step.dependOn(&install_exe.step);
        if (b.args) |args| run_exe.addArgs(args);
        const run_step = b.step("run-" ++ example.name, "Run " ++ example.name ++ " example");
        run_step.dependOn(&run_exe.step);

        const run_all_exe = b.addRunArtifact(exe);
        if (previous_run_step) |prev| {
            run_all_exe.step.dependOn(prev);
        }
        previous_run_step = &run_all_exe.step;
    }

    if (previous_run_step) |last| {
        run_all_examples.dependOn(last);
    }

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/uuid.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");

    const builtin = @import("builtin");
    if (target.result.os.tag == builtin.os.tag and target.result.cpu.arch == builtin.cpu.arch) {
        test_step.dependOn(&run_tests.step);
    } else {
        const install_tests = b.addInstallArtifact(tests, .{});
        test_step.dependOn(&install_tests.step);
    }

    const docs_step = b.step("docs", "Generate documentation");
    const docs_obj = b.addObject(.{
        .name = "uuid",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/uuid.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs_obj.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    docs_step.dependOn(&install_docs.step);

    const test_all_step = b.step("test-all", "Run all tests and examples");
    test_all_step.dependOn(test_step);
    test_all_step.dependOn(run_all_examples);

    const lib = b.addLibrary(.{
        .name = "uuid",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/uuid.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(lib);
}
