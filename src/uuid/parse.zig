const std = @import("std");
const UUID = @import("core.zig").UUID;
const ParseError = @import("errors.zig").ParseError;
const hexToByte = @import("hex.zig").hexToByte;

pub fn parse(input: []const u8) ParseError!UUID {
    if (input.len != 36) return error.InvalidLength;

    if (input[8] != '-' or input[13] != '-' or input[18] != '-' or input[23] != '-') {
        return error.InvalidFormat;
    }

    var result: [16]u8 = undefined;
    const positions = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 14, 15, 16, 17, 19, 20, 21, 22, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35 };

    for (0..16) |i| {
        const hi = try hexToByte(input[positions[i * 2]]);
        const lo = try hexToByte(input[positions[i * 2 + 1]]);
        result[i] = (hi << 4) | lo;
    }

    return .{ .bytes = result };
}

pub fn parseCompact(input: []const u8) ParseError!UUID {
    if (input.len != 32) return error.InvalidLength;

    var result: [16]u8 = undefined;
    for (0..16) |i| {
        result[i] = try hexToByte(input[i * 2]) * 16 + try hexToByte(input[i * 2 + 1]);
    }
    return .{ .bytes = result };
}

pub fn parseBraced(input: []const u8) ParseError!UUID {
    if (input.len != 38 or input[0] != '{' or input[37] != '}') return error.InvalidFormat;
    return parse(input[1..37]);
}

pub fn parseUrn(input: []const u8) ParseError!UUID {
    if (input.len != 45) return error.InvalidLength;
    if (!std.mem.eql(u8, input[0..9], "urn:uuid:")) return error.InvalidFormat;
    return parse(input[9..45]);
}

pub fn parseAll(inputs: []const []const u8, allocator: std.mem.Allocator) (std.mem.Allocator.Error || ParseError)![]UUID {
    const ids = try allocator.alloc(UUID, inputs.len);
    errdefer allocator.free(ids);
    for (inputs, 0..) |input, i| {
        ids[i] = try parse(input);
    }
    return ids;
}

pub fn parseMultiDelim(input: []const u8, delimiter: u8) ParseError![]UUID {
    var list = std.ArrayListUnmanaged(UUID){};
    var start: usize = 0;
    for (input, 0..) |c, i| {
        if (c == delimiter) {
            const id = try parse(input[start..i]);
            try list.append(std.heap.page_allocator, id);
            start = i + 1;
        }
    }
    if (start < input.len) {
        const id = try parse(input[start..]);
        try list.append(std.heap.page_allocator, id);
    }
    return list.items;
}

test "parse canonical" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [36]u8 = undefined;
    const str = id.encode(&buffer);
    const parsed = try parse(str);
    try testing.expect(id.eql(parsed));
}

test "parse compact" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [32]u8 = undefined;
    const str = id.encodeCompact(&buffer);
    const parsed = try parseCompact(str);
    try testing.expect(id.eql(parsed));
}

test "parse braced" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [38]u8 = undefined;
    const str = id.encodeBraced(&buffer);
    const parsed = try parseBraced(str);
    try testing.expect(id.eql(parsed));
}

test "parse URN" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [45]u8 = undefined;
    const str = id.encodeUrn(&buffer);
    const parsed = try parseUrn(str);
    try testing.expect(id.eql(parsed));
}

test "parse error - invalid length" {
    const testing = std.testing;
    try testing.expectError(error.InvalidLength, parse("short"));
    try testing.expectError(error.InvalidLength, parse("9073926b-929f-31c2-abc9-fad77ae3e8eb-extra"));
}

test "parse error - invalid format" {
    const testing = std.testing;
    try testing.expectError(error.InvalidFormat, parse("9073926b929f-31c2-abc9-fad77ae3e8e01"));
}

test "parse error - invalid characters" {
    const testing = std.testing;
    try testing.expectError(error.InvalidCharacter, parse("gggggggg-gggg-gggg-gggg-gggggggggggg"));
}

test "parse uppercase" {
    const testing = std.testing;
    const id = try parse("550E8400-E29B-41D4-A716-446655440000");
    try testing.expectEqual(.v4, id.version());
    var buffer: [36]u8 = undefined;
    try testing.expectEqualStrings("550e8400-e29b-41d4-a716-446655440000", id.encode(&buffer));
}

test "parse mixed-case" {
    const testing = std.testing;
    const id = try parse("550e8400-e29b-41D4-a716-446655440000");
    try testing.expectEqual(.v4, id.version());
    var buffer: [36]u8 = undefined;
    const out = id.encode(&buffer);
    for (out) |c| {
        if (c != '-') {
            try testing.expect((c >= '0' and c <= '9') or (c >= 'a' and c <= 'f'));
        }
    }
}

test "parse mixed-case round-trip" {
    const testing = std.testing;
    const lower = try parse("550e8400-e29b-41d4-a716-446655440000");
    const upper = try parse("550E8400-E29B-41D4-A716-446655440000");
    try testing.expect(lower.eql(upper));
}

test "round-trip parse encode" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [36]u8 = undefined;
    const formatted = id.encode(&buffer);
    const parsed = try parse(formatted);
    try testing.expect(id.eql(parsed));
}

test "round-trip compact parse encode" {
    const testing = std.testing;
    const Namespace = @import("namespace.zig").Namespace;
    const id = UUID.v3(Namespace.dns, "www.example.com");
    var buffer: [32]u8 = undefined;
    const compact = id.encodeCompact(&buffer);
    const parsed = try parseCompact(compact);
    var out: [32]u8 = undefined;
    try testing.expectEqualStrings(compact, parsed.encodeCompact(&out));
}
