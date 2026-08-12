const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    std.debug.print("=== Basic UUID Usage ===\n\n", .{});

    const id = try uuid.UUID.v4(io);
    var buf: [36]u8 = undefined;
    std.debug.print("Generated UUID: {s}\n", .{id.encode(&buf)});

    const parsed = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");
    var buf2: [36]u8 = undefined;
    std.debug.print("Parsed UUID:    {s}\n", .{parsed.encode(&buf2)});

    std.debug.print("\nVersion: {}\n", .{id.version()});
    std.debug.print("Variant: {}\n", .{id.variant()});
    std.debug.print("Is nil: {}\n", .{id.isNil()});

    std.debug.print("\nNil UUID: ", .{});
    var nil_buf: [36]u8 = undefined;
    std.debug.print("{s}\n", .{uuid.UUID.nil.encode(&nil_buf)});

    std.debug.print("\nMax UUID: ", .{});
    var max_buf: [36]u8 = undefined;
    std.debug.print("{s}\n", .{uuid.UUID.max.encode(&max_buf)});
    std.debug.print("Is max: {}\n", .{uuid.UUID.max.isMax()});
}
