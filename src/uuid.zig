//! Public `uuid` module root.
//!
//! The library core is allocation-free and I/O-free except where noted:
//! - `UUID.v4` / `UUID.v7Now` / `Generator.v4` / `Generator.v7` borrow
//!   `std.Io` for entropy and time.
//! - `UUID.toStringAlloc`, `parseAll`, `parseMultiDelim`, and
//!   `Generator.toStringAlloc` borrow an allocator and return caller-owned
//!   memory.
//!
//! `UUID` values are 16-byte copies; sharing them across threads is safe.
//! `Generator` holds no mutable state and is safe to share when its borrowed
//! allocator and `Io` permit concurrent use.

const std = @import("std");

/// Version discriminant module.
pub const version = @import("version.zig");
/// Variant discriminant module.
pub const variant = @import("variant.zig");
/// Core UUID value type module.
pub const core = @import("core.zig");
/// RFC 4122 namespace constants module.
pub const namespace = @import("namespace.zig");
/// String decoding module.
pub const parsing = @import("parse.zig");
/// Stateless generator module.
pub const generator = @import("generator.zig");
/// Error set module.
pub const errors = @import("errors.zig");
/// Hex helper module.
pub const hex = @import("hex.zig");

/// UUID version discriminant.
pub const Version = version.Version;
/// UUID variant discriminant.
pub const Variant = variant.Variant;
/// 128-bit UUID value type.
pub const UUID = core.UUID;
/// Well-known namespace UUIDs.
pub const Namespace = namespace.Namespace;
/// Parsing error set.
pub const ParseError = errors.ParseError;
/// Stateless UUID factory.
pub const Generator = generator.Generator;

/// Canonical length constants re-exported for callers sizing buffers.
pub const canonicalLen = core.canonicalLen;
/// Compact length constant.
pub const compactLen = core.compactLen;
/// Braced length constant.
pub const bracedLen = core.bracedLen;
/// URN length constant.
pub const urnLen = core.urnLen;
/// Raw byte length constant.
pub const byteLen = core.byteLen;

/// Decodes a canonical hyphenated UUID string. Input is borrowed.
pub const parse = parsing.parse;
/// Decodes a 32-digit compact UUID string. Input is borrowed.
pub const parseCompact = parsing.parseCompact;
/// Decodes a braced UUID string. Input is borrowed.
pub const parseBraced = parsing.parseBraced;
/// Decodes a URN UUID string. Input is borrowed.
pub const parseUrn = parsing.parseUrn;
/// Decodes canonical strings into caller-owned slice via `allocator`.
pub const parseAll = parsing.parseAll;
/// Splits on `delimiter` and decodes into caller-owned slice via `allocator`.
pub const parseMultiDelim = parsing.parseMultiDelim;
/// Shape check without decoding. Input is borrowed.
pub const isValid = core.isValid;

test {
    _ = version;
    _ = variant;
    _ = core;
    _ = namespace;
    _ = parsing;
    _ = generator;
    _ = errors;
    _ = hex;
}
