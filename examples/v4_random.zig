const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    std.debug.print("=== UUID v4 (Random) ===\n\n", .{});

    for (0..5) |_| {
        const id = try uuid.UUID.v4(io);
        var buf: [36]u8 = undefined;
        std.debug.print("{s}\n", .{id.encode(&buf)});
    }
}
