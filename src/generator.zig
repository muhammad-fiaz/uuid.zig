//! Convenience generator bundling an allocator with an I/O context.
//!
//! `Generator` itself holds no mutable UUID state; every `v*` method is a
//! thin wrapper over the corresponding `UUID` constructor. A single instance
//! may be shared across threads provided the borrowed `allocator` and `io`
//! are safe for concurrent use. Only `toStringAlloc` allocates.

const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;
const UUID = @import("core.zig").UUID;

/// Stateless UUID factory.
///
/// `allocator` is borrowed and used only by `toStringAlloc`; `io` is
/// borrowed and used only by entropy/time methods (`v4`, `v7`). Neither is
/// destroyed by the generator, and both must outlive it.
pub const Generator = struct {
    allocator: Allocator,
    io: Io,

    /// Borrows `allocator` and `io` without taking ownership of either.
    pub fn init(allocator: Allocator, io: Io) Generator {
        return .{ .allocator = allocator, .io = io };
    }

    /// Time-based (v1) UUID. Pure; ignores receiver state.
    pub fn v1(self: Generator, timestamp: u60, clockSequence: u14, nodeId: [6]u8) UUID {
        _ = self;
        return UUID.v1(timestamp, clockSequence, nodeId);
    }

    /// Deterministic (v3) UUID. Pure; ignores receiver state.
    pub fn v3(self: Generator, namespace: UUID, name: []const u8) UUID {
        _ = self;
        return UUID.v3(namespace, name);
    }

    /// Random (v4) UUID via the generator's borrowed `io`.
    pub fn v4(self: Generator) Io.RandomSecureError!UUID {
        return UUID.v4(self.io);
    }

    /// Deterministic (v5) UUID. Pure; ignores receiver state.
    pub fn v5(self: Generator, namespace: UUID, name: []const u8) UUID {
        _ = self;
        return UUID.v5(namespace, name);
    }

    /// Reordered time-based (v6) UUID. Pure; ignores receiver state.
    pub fn v6(self: Generator, timestamp: u60, clockSequence: u14, nodeId: [6]u8) UUID {
        _ = self;
        return UUID.v6(timestamp, clockSequence, nodeId);
    }

    /// Time-ordered (v7) UUID using current time via the generator's `io`.
    pub fn v7(self: Generator) Io.RandomSecureError!UUID {
        return UUID.v7Now(self.io);
    }

    /// Time-ordered (v7) UUID from explicit components. Pure.
    pub fn v7WithTimestamp(self: Generator, timestampMs: u48, randA: u12, randB: [10]u8) UUID {
        _ = self;
        return UUID.v7(timestampMs, randA, randB);
    }

    /// Application-specific (v8) UUID. Pure; ignores receiver state.
    pub fn v8(self: Generator, custom: [16]u8) UUID {
        _ = self;
        return UUID.v8(custom);
    }

    /// Allocates the canonical string for `uuid` with the generator's allocator.
    ///
    /// The returned 36-byte slice is owned by the caller; free it with the
    /// same allocator when done.
    pub fn toStringAlloc(self: Generator, uuid: UUID) Allocator.Error![]u8 {
        return uuid.toStringAlloc(self.allocator);
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

test "Generator v7WithTimestamp" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const gen = Generator.init(testing.allocator, io);
    const id = gen.v7WithTimestamp(0x017F22E279B0, 0xCC3, .{ 0x18, 0xC4, 0xDC, 0x0C, 0x0C, 0x07, 0x39, 0x8F, 0x00, 0x00 });
    try testing.expectEqual(.v7, id.version());
}

test "Generator v8" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const gen = Generator.init(testing.allocator, io);
    const id = gen.v8(.{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 });
    try testing.expectEqual(.v8, id.version());
}

test "Generator toStringAlloc" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const gen = Generator.init(testing.allocator, io);
    const id = try gen.v4();
    const str = try gen.toStringAlloc(id);
    defer testing.allocator.free(str);
    try testing.expectEqual(@as(usize, 36), str.len);
}
