const std = @import("std");

pub const version = @import("uuid/version.zig");
pub const variant_mod = @import("uuid/variant.zig");
pub const core = @import("uuid/core.zig");
pub const namespace = @import("uuid/namespace.zig");
pub const parse_mod = @import("uuid/parse.zig");
pub const generator = @import("uuid/generator.zig");
pub const errors = @import("uuid/errors.zig");
pub const hex = @import("uuid/hex.zig");

pub const Version = version.Version;
pub const Variant = variant_mod.Variant;
pub const UUID = core.UUID;
pub const Namespace = namespace.Namespace;
pub const ParseError = errors.ParseError;
pub const Generator = generator.Generator;

pub const parse = parse_mod.parse;
pub const parseCompact = parse_mod.parseCompact;
pub const parseBraced = parse_mod.parseBraced;
pub const parseUrn = parse_mod.parseUrn;

test {
    _ = version;
    _ = variant_mod;
    _ = core;
    _ = namespace;
    _ = parse_mod;
    _ = generator;
    _ = errors;
    _ = hex;
}
