//! Parsing errors for UUID string decoding.
//!
//! All parsing entry points borrow their input and never allocate.
//! Allocation failures are reported separately through
//! `std.mem.Allocator.Error` on APIs that allocate.

/// Errors returned when decoding a UUID from its string representation.
pub const ParseError = error{
    /// Input length does not match any supported representation.
    InvalidLength,
    /// Hyphens, braces, or the `urn:uuid:` prefix are misplaced.
    InvalidFormat,
    /// A non-hexadecimal digit appears where a hex digit is required.
    InvalidCharacter,
};
