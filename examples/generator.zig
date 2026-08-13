const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    std.debug.print("=== UUID Generator (All Methods) ===\n\n", .{});

    const gen = uuid.Generator.init(allocator, io);

    // v1 - Time-based
    const id1 = gen.v1(0x1EC9414C232AB00, 0x33C8, .{ 0x9F, 0x6B, 0xDE, 0xC7, 0x41, 0xFB });
    var buf: [36]u8 = undefined;
    std.debug.print("v1: {s}\n", .{id1.encode(&buf)});

    // v3 - MD5 namespace
    const id3 = gen.v3(uuid.Namespace.dns, "example.com");
    std.debug.print("v3: {s}\n", .{id3.encode(&buf)});

    // v4 - Random
    const id4 = try gen.v4();
    std.debug.print("v4: {s}\n", .{id4.encode(&buf)});

    // v5 - SHA-1 namespace
    const id5 = gen.v5(uuid.Namespace.dns, "example.com");
    std.debug.print("v5: {s}\n", .{id5.encode(&buf)});

    // v6 - Reordered time-based
    const id6 = gen.v6(0x1EC9414C232AB00, 0x33C8, .{ 0x9F, 0x6B, 0xDE, 0xC7, 0x41, 0xFB });
    std.debug.print("v6: {s}\n", .{id6.encode(&buf)});

    // v7 - Time-ordered (current time)
    const id7 = try gen.v7();
    std.debug.print("v7: {s}\n", .{id7.encode(&buf)});

    // v7 with custom timestamp
    const id7_custom = gen.v7WithTimestamp(0x017F22E279B0, 0xCC3, .{ 0x18, 0xC4, 0xDC, 0x0C, 0x0C, 0x07, 0x39, 0x8F, 0x00, 0x00 });
    std.debug.print("v7 (custom): {s}\n", .{id7_custom.encode(&buf)});

    // v8 - Application-specific
    const id8 = gen.v8(.{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 });
    std.debug.print("v8: {s}\n", .{id8.encode(&buf)});

    // toString - Allocated string
    const str = try gen.toString(id4);
    defer allocator.free(str);
    std.debug.print("\nAllocated string: {s}\n", .{str});
}
