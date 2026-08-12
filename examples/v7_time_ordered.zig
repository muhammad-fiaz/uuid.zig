const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    std.debug.print("=== UUID v7 (Time-Ordered) ===\n\n", .{});

    for (0..5) |_| {
        const id = try uuid.UUID.v7Now(io);
        var buf: [36]u8 = undefined;
        std.debug.print("{s}\n", .{id.encode(&buf)});
    }

    std.debug.print("\nCustom timestamp v7:\n", .{});
    const custom = uuid.UUID.v7(0x123456789ABC, 0x456, [_]u8{ 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA });
    var buf: [36]u8 = undefined;
    std.debug.print("{s}\n", .{custom.encode(&buf)});
}
