const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;
const UUID = @import("core.zig").UUID;

pub const Generator = struct {
    allocator: Allocator,
    io: Io,

    pub fn init(allocator: Allocator, io: Io) Generator {
        return .{ .allocator = allocator, .io = io };
    }

    pub fn v1(self: Generator, timestamp: u60, clock_seq: u14, node: [6]u8) UUID {
        _ = self;
        return UUID.v1(timestamp, clock_seq, node);
    }

    pub fn v3(self: Generator, namespace: UUID, name: []const u8) UUID {
        _ = self;
        return UUID.v3(namespace, name);
    }

    pub fn v4(self: Generator) Io.RandomSecureError!UUID {
        return UUID.v4(self.io);
    }

    pub fn v5(self: Generator, namespace: UUID, name: []const u8) UUID {
        _ = self;
        return UUID.v5(namespace, name);
    }

    pub fn v6(self: Generator, timestamp: u60, clock_seq: u14, node: [6]u8) UUID {
        _ = self;
        return UUID.v6(timestamp, clock_seq, node);
    }

    pub fn v7(self: Generator) Io.RandomSecureError!UUID {
        return UUID.v7Now(self.io);
    }

    pub fn v7WithTimestamp(self: Generator, timestamp_ms: u48, rand_a: u12, rand_b: [10]u8) UUID {
        _ = self;
        return UUID.v7(timestamp_ms, rand_a, rand_b);
    }

    pub fn v8(self: Generator, custom: [16]u8) UUID {
        _ = self;
        return UUID.v8(custom);
    }

    pub fn toString(self: Generator, uuid: UUID) Allocator.Error![]u8 {
        return uuid.toString(self.allocator);
    }
};

test "Generator init" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const gen = Generator.init(testing.allocator, io);
    const id = try gen.v4();
    try testing.expectEqual(.v4, id.version());
}

test "Generator v1" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const gen = Generator.init(testing.allocator, io);
    const id = gen.v1(0x123456789ABCDEF, 0x1234, .{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF });
    try testing.expectEqual(.v1, id.version());
}

test "Generator v3" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const Namespace = @import("namespace.zig").Namespace;
    const gen = Generator.init(testing.allocator, io);
    const id = gen.v3(Namespace.dns, "example.com");
    try testing.expectEqual(.v3, id.version());
}

test "Generator v5" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const Namespace = @import("namespace.zig").Namespace;
    const gen = Generator.init(testing.allocator, io);
    const id = gen.v5(Namespace.dns, "example.com");
    try testing.expectEqual(.v5, id.version());
}

test "Generator v6" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const gen = Generator.init(testing.allocator, io);
    const id = gen.v6(0x123456789ABCDEF, 0x1234, .{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF });
    try testing.expectEqual(.v6, id.version());
}

test "Generator v7" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const gen = Generator.init(testing.allocator, io);
    const id = try gen.v7();
    try testing.expectEqual(.v7, id.version());
}

test "Generator v8" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const gen = Generator.init(testing.allocator, io);
    const id = gen.v8(.{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 });
    try testing.expectEqual(.v8, id.version());
}

test "Generator toString" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const gen = Generator.init(testing.allocator, io);
    const id = try gen.v4();
    const str = try gen.toString(id);
    defer testing.allocator.free(str);
    try testing.expectEqual(@as(usize, 36), str.len);
}
