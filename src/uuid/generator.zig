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

    pub fn v4(self: Generator) Io.RandomSecureError!UUID {
        return UUID.v4(self.io);
    }

    pub fn v7(self: Generator) Io.RandomSecureError!UUID {
        return UUID.v7Now(self.io);
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

test "Generator v7" {
    const testing = std.testing;
    const io: Io = std.testing.io;
    const gen = Generator.init(testing.allocator, io);
    const id = try gen.v7();
    try testing.expectEqual(.v7, id.version());
}
