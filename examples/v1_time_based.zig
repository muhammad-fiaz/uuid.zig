const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID v1 (Time-Based) ===\n\n", .{});

    const timestamp: u60 = 0x123456789ABCDEF;
    const clock_seq: u14 = 0x1234;
    const node = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };

    const id = uuid.UUID.v1(timestamp, clock_seq, node);
    var buf: [36]u8 = undefined;
    std.debug.print("v1 UUID: {s}\n", .{id.encode(&buf)});
    std.debug.print("Version: {}\n", .{id.version()});
    std.debug.print("Variant: {}\n", .{id.variant()});

    std.debug.print("\nNode bytes: ", .{});
    for (id.bytes[10..16]) |b| {
        std.debug.print("{x:0>2} ", .{b});
    }
    std.debug.print("\n", .{});
}
