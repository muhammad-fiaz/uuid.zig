const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    std.debug.print("=== Batch UUID Generation ===\n\n", .{});

    const count = 10;
    var buf: [36]u8 = undefined;

    std.debug.print("Generating {d} v4 UUIDs:\n", .{count});
    for (0..count) |i| {
        const id = try uuid.UUID.v4(io);
        std.debug.print("  {d: >2}. {s}\n", .{ i + 1, id.encode(&buf) });
    }

    std.debug.print("\nGenerating {d} v7 UUIDs (time-ordered):\n", .{count});
    for (0..count) |i| {
        const id = try uuid.UUID.v7Now(io);
        std.debug.print("  {d: >2}. {s}\n", .{ i + 1, id.encode(&buf) });
    }

    std.debug.print("\nv7 UUIDs are time-ordered, making them ideal for database primary keys.\n", .{});
}
