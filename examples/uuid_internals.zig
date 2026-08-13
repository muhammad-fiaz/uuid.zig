const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();

    std.debug.print("=== UUID Internals ===\n\n", .{});

    // v2 - DCE Security (POSIX UID/GID)
    std.debug.print("--- v2 (DCE Security) ---\n", .{});
    const posix_uid = uuid.UUID.v2(1, 1000, .{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF });
    var buf: [36]u8 = undefined;
    std.debug.print("POSIX UID (domain=1, id=1000): {s}\n", .{posix_uid.encode(&buf)});
    std.debug.print("Version: {}, Variant: {}\n\n", .{ posix_uid.version(), posix_uid.variant() });

    // Timestamp extraction
    std.debug.print("--- Timestamp Extraction ---\n", .{});
    const v1 = uuid.UUID.v1(0x1EC9414C232AB00, 0x33C8, .{ 0x9F, 0x6B, 0xDE, 0xC7, 0x41, 0xFB });
    std.debug.print("v1 UUID: {s}\n", .{v1.encode(&buf)});
    std.debug.print("  Timestamp: 0x{X}\n", .{v1.timestampV1()});
    std.debug.print("  ClockSeq: 0x{X}\n", .{v1.clockSeq()});
    std.debug.print("  Node: ", .{});
    for (v1.node()) |b| {
        std.debug.print("{X:0>2} ", .{b});
    }
    std.debug.print("\n\n", .{});

    const v7 = uuid.UUID.v7(0x017F22E279B0, 0xCC3, .{ 0x18, 0xC4, 0xDC, 0x0C, 0x0C, 0x07, 0x39, 0x8F, 0x00, 0x00 });
    std.debug.print("v7 UUID: {s}\n", .{v7.encode(&buf)});
    std.debug.print("  Timestamp (ms): 0x{X}\n\n", .{v7.timestampV7()});

    // Sorting
    std.debug.print("--- Sorting UUIDs ---\n", .{});
    var ids = [_]uuid.UUID{
        uuid.UUID.v3(uuid.Namespace.dns, "charlie.com"),
        uuid.UUID.v3(uuid.Namespace.dns, "alice.com"),
        uuid.UUID.v3(uuid.Namespace.dns, "bob.com"),
    };
    uuid.UUID.sort(&ids);
    for (ids) |id| {
        std.debug.print("  {s}\n", .{id.encode(&buf)});
    }

    // Validation
    std.debug.print("\n--- UUID Validation ---\n", .{});
    const valid_inputs = [_][]const u8{
        "550e8400-e29b-41d4-a716-446655440000",
        "550e8400e29b41d4a716446655440000",
        "{550e8400-e29b-41d4-a716-446655440000}",
        "urn:uuid:550e8400-e29b-41d4-a716-446655440000",
    };
    for (valid_inputs) |input| {
        std.debug.print("  \"{s}\" -> {}\n", .{ input, uuid.isValid(input) });
    }

    const invalid_inputs = [_][]const u8{
        "not-a-uuid",
        "550e8400-e29b-41d4-a716",
        "550e8400-e29b-41d4-a716-446655440000-extra",
    };
    for (invalid_inputs) |input| {
        std.debug.print("  \"{s}\" -> {}\n", .{ input, uuid.isValid(input) });
    }

    // Batch parsing
    std.debug.print("\n--- Batch Parsing ---\n", .{});
    const inputs = [_][]const u8{
        "550e8400-e29b-41d4-a716-446655440000",
        "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
        "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    };
    const parsed = try uuid.parseAll(&inputs, gpa.allocator());
    defer gpa.allocator().free(parsed);
    for (parsed) |id| {
        std.debug.print("  {s}\n", .{id.encode(&buf)});
    }
}
