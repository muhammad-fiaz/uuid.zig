const std = @import("std");
const UUID = @import("core.zig").UUID;

pub fn format(self: UUID, buffer: []u8) []u8 {
    const hex = "0123456789abcdef";
    const b = self.bytes;
    const result = [36]u8{
        hex[b[0] >> 4],   hex[b[0] & 0x0F],
        hex[b[1] >> 4],   hex[b[1] & 0x0F],
        hex[b[2] >> 4],   hex[b[2] & 0x0F],
        hex[b[3] >> 4],   hex[b[3] & 0x0F],
        '-',              hex[b[4] >> 4],
        hex[b[4] & 0x0F], hex[b[5] >> 4],
        hex[b[5] & 0x0F], '-',
        hex[b[6] >> 4],   hex[b[6] & 0x0F],
        hex[b[7] >> 4],   hex[b[7] & 0x0F],
        '-',              hex[b[8] >> 4],
        hex[b[8] & 0x0F], hex[b[9] >> 4],
        hex[b[9] & 0x0F], '-',
        hex[b[10] >> 4],  hex[b[10] & 0x0F],
        hex[b[11] >> 4],  hex[b[11] & 0x0F],
        hex[b[12] >> 4],  hex[b[12] & 0x0F],
        hex[b[13] >> 4],  hex[b[13] & 0x0F],
        hex[b[14] >> 4],  hex[b[14] & 0x0F],
        hex[b[15] >> 4],  hex[b[15] & 0x0F],
    };
    @memcpy(buffer[0..36], &result);
    return buffer[0..36];
}

pub fn formatUppercase(self: UUID, buffer: []u8) []u8 {
    const hex = "0123456789ABCDEF";
    const b = self.bytes;
    const result = [36]u8{
        hex[b[0] >> 4],   hex[b[0] & 0x0F],
        hex[b[1] >> 4],   hex[b[1] & 0x0F],
        hex[b[2] >> 4],   hex[b[2] & 0x0F],
        hex[b[3] >> 4],   hex[b[3] & 0x0F],
        '-',              hex[b[4] >> 4],
        hex[b[4] & 0x0F], hex[b[5] >> 4],
        hex[b[5] & 0x0F], '-',
        hex[b[6] >> 4],   hex[b[6] & 0x0F],
        hex[b[7] >> 4],   hex[b[7] & 0x0F],
        '-',              hex[b[8] >> 4],
        hex[b[8] & 0x0F], hex[b[9] >> 4],
        hex[b[9] & 0x0F], '-',
        hex[b[10] >> 4],  hex[b[10] & 0x0F],
        hex[b[11] >> 4],  hex[b[11] & 0x0F],
        hex[b[12] >> 4],  hex[b[12] & 0x0F],
        hex[b[13] >> 4],  hex[b[13] & 0x0F],
        hex[b[14] >> 4],  hex[b[14] & 0x0F],
        hex[b[15] >> 4],  hex[b[15] & 0x0F],
    };
    @memcpy(buffer[0..36], &result);
    return buffer[0..36];
}

pub fn formatCompact(self: UUID, buffer: []u8) []u8 {
    const hex = "0123456789abcdef";
    const b = self.bytes;
    for (0..16) |i| {
        buffer[i * 2] = hex[b[i] >> 4];
        buffer[i * 2 + 1] = hex[b[i] & 0x0F];
    }
    return buffer[0..32];
}

pub fn formatBraced(self: UUID, buffer: []u8) []u8 {
    buffer[0] = '{';
    _ = self.format(buffer[1..37]);
    buffer[37] = '}';
    return buffer[0..38];
}

pub fn formatUrn(self: UUID, buffer: []u8) []u8 {
    @memcpy(buffer[0..9], "urn:uuid:");
    _ = self.format(buffer[9..45]);
    return buffer[0..45];
}

pub fn formatWriter(self: UUID, writer: *std.Io.Writer) std.Io.Writer.Error!void {
    const hex = "0123456789abcdef";
    const b = self.bytes;
    const result = [36]u8{
        hex[b[0] >> 4],   hex[b[0] & 0x0F],
        hex[b[1] >> 4],   hex[b[1] & 0x0F],
        hex[b[2] >> 4],   hex[b[2] & 0x0F],
        hex[b[3] >> 4],   hex[b[3] & 0x0F],
        '-',              hex[b[4] >> 4],
        hex[b[4] & 0x0F], hex[b[5] >> 4],
        hex[b[5] & 0x0F], '-',
        hex[b[6] >> 4],   hex[b[6] & 0x0F],
        hex[b[7] >> 4],   hex[b[7] & 0x0F],
        '-',              hex[b[8] >> 4],
        hex[b[8] & 0x0F], hex[b[9] >> 4],
        hex[b[9] & 0x0F], '-',
        hex[b[10] >> 4],  hex[b[10] & 0x0F],
        hex[b[11] >> 4],  hex[b[11] & 0x0F],
        hex[b[12] >> 4],  hex[b[12] & 0x0F],
        hex[b[13] >> 4],  hex[b[13] & 0x0F],
        hex[b[14] >> 4],  hex[b[14] & 0x0F],
        hex[b[15] >> 4],  hex[b[15] & 0x0F],
    };
    try writer.writeAll(&result);
}

pub fn toString(self: UUID, allocator: std.mem.Allocator) std.mem.Allocator.Error![]u8 {
    const buf = try allocator.alloc(u8, 36);
    _ = self.format(buf);
    return buf;
}
