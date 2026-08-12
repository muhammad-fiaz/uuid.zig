---
layout: home

hero:
  name: uuid.zig
  text: UUID Library for Zig
  tagline: Production-ready, high-performance UUID generation, parsing, and formatting for Zig 0.16.0.
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: API Reference
      link: /api/
    - theme: alt
      text: GitHub
      link: https://github.com/muhammad-fiaz/uuid.zig

features:
  - title: All UUID Versions
    details: Full support for v1 (time-based), v3 (MD5), v4 (random), v5 (SHA-1), v6 (reordered time), v7 (epoch time), and v8 (application-specific).
  - title: Zero-Allocation Core
    details: Generate, parse, format, and compare UUIDs without any heap allocation. Only the Generator type uses an allocator for string conversion.
  - title: Strict Parsing
    details: Parse UUIDs in canonical, compact, braced, and URN formats with comprehensive error detection for invalid characters, lengths, and formats.
  - title: Multiple Output Formats
    details: Format UUIDs as canonical, uppercase, compact, braced, or URN strings. All formatters write to caller-provided buffers.
  - title: Cryptographic Security
    details: v4 and v7 UUIDs use std.Io.randomSecure for cryptographically secure random bytes.
  - title: Deterministic Generation
    details: v3 and v5 UUIDs are deterministic given the same namespace and name. Custom timestamps enable reproducible testing.
---
