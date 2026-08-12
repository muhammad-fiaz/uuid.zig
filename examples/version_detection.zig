const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID Version Detection ===\n\n", .{});

    var buf: [36]u8 = undefined;

    const v1 = uuid.UUID.v1(0x123456789ABCDEF, 0x1234, [_]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF });
    std.debug.print("v1: {s} (version: {}, variant: {})\n", .{ v1.encode(&buf), v1.version(), v1.variant() });

    const v3 = uuid.UUID.v3(uuid.Namespace.dns, "example.com");
    std.debug.print("v3: {s} (version: {}, variant: {})\n", .{ v3.encode(&buf), v3.version(), v3.variant() });

    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    const v4 = try uuid.UUID.v4(io);
    std.debug.print("v4: {s} (version: {}, variant: {})\n", .{ v4.encode(&buf), v4.version(), v4.variant() });

    const v5 = uuid.UUID.v5(uuid.Namespace.dns, "example.com");
    std.debug.print("v5: {s} (version: {}, variant: {})\n", .{ v5.encode(&buf), v5.version(), v5.variant() });

    const v6 = uuid.UUID.v6(0x123456789ABCDEF, 0x1234, [_]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF });
    std.debug.print("v6: {s} (version: {}, variant: {})\n", .{ v6.encode(&buf), v6.version(), v6.variant() });

    const v7 = uuid.UUID.v7(0x123456789ABC, 0x456, [_]u8{ 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA });
    std.debug.print("v7: {s} (version: {}, variant: {})\n", .{ v7.encode(&buf), v7.version(), v7.variant() });

    const v8 = uuid.UUID.v8([_]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 });
    std.debug.print("v8: {s} (version: {}, variant: {})\n", .{ v8.encode(&buf), v8.version(), v8.variant() });

    std.debug.print("\nnil: {s} (version: {}, isNil: {})\n", .{ uuid.UUID.nil.encode(&buf), uuid.UUID.nil.version(), uuid.UUID.nil.isNil() });
}
