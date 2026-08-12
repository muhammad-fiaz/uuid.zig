# Examples

All runnable examples demonstrating `uuid.zig` features.

## Running Examples

```bash
zig build run-basic-usage
zig build run-v1-time-based
zig build run-v3-md5-namespace
zig build run-v4-random
zig build run-v5-sha1-namespace
zig build run-v6-reordered
zig build run-v7-time-ordered
zig build run-v8-application-specific
zig build run-deterministic
zig build run-parsing-formats
zig build run-comparison
zig build run-generator
zig build run-hash-map
zig build run-namespaces
zig build run-version-detection
zig build run-batch-generation
```

## Available Examples

| Example | Description |
|---------|-------------|
| [Basic Usage](/examples/basic-usage) | Generate, parse, and inspect UUIDs |
| [v1 Time-Based](/examples/v1-time-based) | Time-based v1 UUID generation |
| [v3 MD5 Namespace](/examples/v3-md5-namespace) | Deterministic v3 UUID via MD5 |
| [v4 Random](/examples/v4-random) | Generate random v4 UUIDs |
| [v5 SHA-1 Namespace](/examples/v5-sha1-namespace) | Deterministic v5 UUID via SHA-1 |
| [v6 Reordered](/examples/v6-reordered) | Reordered time-based v6 UUIDs |
| [v7 Time-Ordered](/examples/v7-time-ordered) | Time-ordered v7 UUIDs |
| [v8 Application-Specific](/examples/v8-application-specific) | Application-specific v8 UUIDs |
| [Deterministic](/examples/deterministic) | v3, v5, and v8 deterministic generation |
| [Parsing & Formats](/examples/parsing-formats) | Parse and format in all formats |
| [Comparison](/examples/comparison) | Compare, convert, and hash UUIDs |
| [Generator](/examples/generator) | Use the Generator with allocator |
| [Hash Map](/examples/hash-map) | UUID as hash map keys |
| [Namespaces](/examples/namespaces) | RFC 4122 namespace constants |
| [Version Detection](/examples/version-detection) | Detect UUID version and variant |
| [Batch Generation](/examples/batch-generation) | Batch generate v4 and v7 UUIDs |
