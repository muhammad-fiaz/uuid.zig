const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    std.debug.print("=== UUID Parsing & Formatting ===\n\n", .{});

    const canonical = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");
    var buf: [36]u8 = undefined;
    std.debug.print("Canonical: {s}\n", .{canonical.encode(&buf)});

    const compact = try uuid.parseCompact("550e8400e29b41d4a716446655440000");
    std.debug.print("From compact: {s}\n", .{compact.encode(&buf)});

    const braced = try uuid.parseBraced("{550e8400-e29b-41d4-a716-446655440000}");
    std.debug.print("From braced: {s}\n", .{braced.encode(&buf)});

    const urn = try uuid.parseUrn("urn:uuid:550e8400-e29b-41d4-a716-446655440000");
    std.debug.print("From URN: {s}\n", .{urn.encode(&buf)});

    std.debug.print("\nOutput formats:\n", .{});
    std.debug.print("  Canonical:  {s}\n", .{canonical.encode(&buf)});

    var upper_buf: [36]u8 = undefined;
    std.debug.print("  Uppercase:  {s}\n", .{canonical.encodeUppercase(&upper_buf)});

    var compact_buf: [32]u8 = undefined;
    std.debug.print("  Compact:    {s}\n", .{canonical.encodeCompact(&compact_buf)});

    var braced_buf: [38]u8 = undefined;
    std.debug.print("  Braced:     {s}\n", .{canonical.encodeBraced(&braced_buf)});

    var urn_buf: [45]u8 = undefined;
    std.debug.print("  URN:        {s}\n", .{canonical.encodeUrn(&urn_buf)});
}
