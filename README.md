<div align="center">

<img  height="250" alt="image logo" src="https://github.com/user-attachments/assets/e5d199c0-2163-419f-bdfd-15624a722df6" />


# UUID.zig

<a href="https://muhammad-fiaz.github.io/uuid.zig/"><img src="https://img.shields.io/badge/docs-muhammad--fiaz.github.io-blue" alt="Documentation"></a>
<a href="https://ziglang.org/"><img src="https://img.shields.io/badge/Zig-0.16.0-orange.svg?logo=zig" alt="Zig Version"></a>
<a href="https://github.com/muhammad-fiaz/uuid.zig"><img src="https://img.shields.io/github/stars/muhammad-fiaz/uuid.zig" alt="GitHub stars"></a>
<a href="https://github.com/muhammad-fiaz/uuid.zig/issues"><img src="https://img.shields.io/github/issues/muhammad-fiaz/uuid.zig" alt="GitHub issues"></a>
<a href="https://github.com/muhammad-fiaz/uuid.zig/pulls"><img src="https://img.shields.io/github/issues-pr/muhammad-fiaz/uuid.zig" alt="GitHub pull requests"></a>
<a href="https://github.com/muhammad-fiaz/uuid.zig"><img src="https://img.shields.io/github/last-commit/muhammad-fiaz/uuid.zig" alt="GitHub last commit"></a>
<a href="https://github.com/muhammad-fiaz/uuid.zig"><img src="https://img.shields.io/github/license/muhammad-fiaz/uuid.zig" alt="License"></a>
<a href="https://github.com/muhammad-fiaz/uuid.zig/actions/workflows/ci.yml"><img src="https://github.com/muhammad-fiaz/uuid.zig/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
<img src="https://img.shields.io/badge/platforms-linux%20%7C%20windows%20%7C%20macos-blue" alt="Supported Platforms">
<a href="https://github.com/muhammad-fiaz/uuid.zig/releases/latest"><img src="https://img.shields.io/github/v/release/muhammad-fiaz/uuid.zig?label=Latest%20Release&style=flat-square" alt="Latest Release"></a>
<a href="https://pay.muhammadfiaz.com"><img src="https://img.shields.io/badge/Sponsor-pay.muhammadfiaz.com-ff69b4?style=flat&logo=heart" alt="Sponsor"></a>
<a href="https://github.com/sponsors/muhammad-fiaz"><img src="https://img.shields.io/badge/Sponsor-GitHub-pink?style=social&logo=github" alt="GitHub Sponsors"></a>
<a href="https://hits.sh/muhammad-fiaz/uuid.zig/"><img src="https://hits.sh/muhammad-fiaz/uuid.zig.svg?label=Visitors&extraCount=0&color=green" alt="Repo Visitors"></a>

<p><em>A production-ready, high-performance UUID library for Zig.</em></p>

<b><a href="https://muhammad-fiaz.github.io/uuid.zig/">Documentation</a> |
<a href="https://muhammad-fiaz.github.io/uuid.zig/api/">API Reference</a> |
<a href="https://muhammad-fiaz.github.io/uuid.zig/guide/getting-started">Quick Start</a> |
<a href="CONTRIBUTING.md">Contributing</a></b>

</div>

`uuid.zig` is a modern, high-performance UUID library for Zig, providing everything needed to generate, parse, format, and compare UUIDs across all standard versions.

> [!TIP]
> If you build with uuid.zig, make sure to give it a star.

---

<details>
<summary><strong>Features</strong> (click to expand)</summary>

| Feature | Description |
|---------|-------------|
| **UUID v1** | Time-based UUID generation with custom timestamp, clock sequence, and node. |
| **UUID v3** | Deterministic UUID via MD5 namespace hashing. |
| **UUID v4** | Cryptographically secure random UUID via `std.Io`. |
| **UUID v5** | Deterministic UUID via SHA-1 namespace hashing. |
| **UUID v6** | Reordered time-based UUID for better database indexing. |
| **UUID v7** | Unix epoch time-based UUID with monotonic random sort order. |
| **UUID v8** | Application-specific UUID with custom 16-byte payload. |
| **Nil UUID** | The zero UUID (`00000000-0000-0000-0000-000000000000`). |
| **Max UUID** | The max UUID (`ffffffff-ffff-ffff-ffff-ffffffffffff`). |
| **Strict Parsing** | Canonical, compact, braced, and URN format parsing with error detection. |
| **Multiple Formats** | Canonical, uppercase, compact, braced, and URN output formats. |
| **Zero-Allocation** | Core operations (generate, parse, format, compare) require no allocator. |
| **Cryptographic Random** | Secure randomness via `std.Io.randomSecure`. |
| **Hash Algorithms** | MD5 (v3) and SHA-1 (v5) via Zig standard library. |
| **Deterministic Generation** | Custom timestamps for reproducible UUIDs and testing. |
| **Namespace Constants** | RFC 4122 namespace UUIDs (DNS, URL, OID, X.500). |
| **Modular Codebase** | Separated concerns: version, variant, core, parse, format, generator, hex, namespace, errors. |

</details>

---

<details>
<summary><strong>Prerequisites and Supported Platforms</strong> (click to expand)</summary>

## Prerequisites

Before using `uuid.zig`, ensure you have the following:

| Requirement | Version | Notes |
|-------------|---------|-------|
| **Zig** | **0.16.0** (recommended) | Download from [ziglang.org](https://ziglang.org/download/) |
| **Operating System** | Windows 10+, Linux, macOS | Cross-platform support |

---

## Supported Platforms

`uuid.zig` is validated on these architectures:

| Platform | x86_64 (64-bit) | aarch64 (ARM64) | x86 (32-bit) |
|----------|-----------------|-----------------|--------------|
| **Linux** | Yes | Yes | Yes |
| **Windows** | Yes | Yes | Yes |
| **macOS** | Yes | Yes (Apple Silicon) | No |

### Cross-Compilation

Zig makes cross-compilation easy. Build for any target from any host:

```bash
# Build for Linux ARM64 from Windows
zig build -Dtarget=aarch64-linux

# Build for Windows from Linux
zig build -Dtarget=x86_64-windows

# Build for macOS Apple Silicon from Linux
zig build -Dtarget=aarch64-macos
```

</details>

---

## Installation

### Method 1: Zig Fetch (Recommended)

```bash
zig fetch --save https://github.com/muhammad-fiaz/uuid.zig/archive/refs/tags/v0.0.1.tar.gz
```

### Method 2: Zig Fetch (Main Branch)

```bash
zig fetch --save git+https://github.com/muhammad-fiaz/uuid.zig.git
```

### Method 3: Manual `build.zig.zon` Configuration

Add the dependency to your `build.zig.zon` file.

```zig
.dependencies = .{
    .uuid = .{
        .url = "https://github.com/muhammad-fiaz/uuid.zig/archive/refs/tags/v0.0.1.tar.gz",
        .hash = "...", // Run `zig fetch --save <url>` to generate the hash.
    },
},
```

### Method 4: Local Source Checkout

Clone the repository locally.

```bash
git clone https://github.com/muhammad-fiaz/uuid.zig.git
cd uuid.zig
zig build
```

To use a local checkout from another project, add a path dependency to your `build.zig.zon`:

```zig
.dependencies = .{
    .uuid = .{
        .path = "../uuid.zig",
    },
},
```

### Wire into `build.zig`

After adding the dependency, import the module in your `build.zig`:

```zig
const uuid_dep = b.dependency("uuid", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("uuid", uuid_dep.module("uuid"));
```

## Quick Start

```zig
const std = @import("std");
const uuid = @import("uuid");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    // Generate v4 UUID
    const id = try uuid.UUID.v4(io);
    var buf: [36]u8 = undefined;
    std.debug.print("UUID: {s}\n", .{id.encode(&buf)});

    // Parse UUID
    const parsed = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");

    // Compare
    if (id.eql(parsed)) {
        std.debug.print("Equal!\n", .{});
    }
}
```

## API Overview

### Generate

```zig
// v4 (random)
const id = try uuid.UUID.v4(io);

// v7 (time-ordered, random)
const id = try uuid.UUID.v7Now(io);

// v3 (deterministic, MD5)
const id = uuid.UUID.v3(uuid.Namespace.dns, "example.com");

// v5 (deterministic, SHA-1)
const id = uuid.UUID.v5(uuid.Namespace.dns, "example.com");

// v1 (time-based)
const id = uuid.UUID.v1(timestamp, clock_seq, node);

// v6 (reordered time-based)
const id = uuid.UUID.v6(timestamp, clock_seq, node);

// v7 (custom timestamp)
const id = uuid.UUID.v7(timestamp_ms, rand_a, rand_b);

// v8 (application-specific)
const id = uuid.UUID.v8(custom_bytes);
```

### Parse

```zig
const id = try uuid.parse("550e8400-e29b-41d4-a716-446655440000");
const id = try uuid.parseCompact("550e8400e29b41d4a716446655440000");
const id = try uuid.parseBraced("{550e8400-e29b-41d4-a716-446655440000}");
const id = try uuid.parseUrn("urn:uuid:550e8400-e29b-41d4-a716-446655440000");
```

### Format

```zig
var buf: [36]u8 = undefined;
const canonical = id.encode(&buf);          // xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
const uppercase = id.encodeUppercase(&buf); // XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

var compact_buf: [32]u8 = undefined;
const compact = id.encodeCompact(&compact_buf); // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

var braced_buf: [38]u8 = undefined;
const braced = id.encodeBraced(&braced_buf); // {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}

var urn_buf: [45]u8 = undefined;
const urn = id.encodeUrn(&urn_buf); // urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### Inspect

```zig
const version = id.version();   // .v4
const variant = id.variant();   // .rfc
const is_nil = id.isNil();      // false
const is_max = id.isMax();      // false
```

### Compare

```zig
if (id1.eql(id2)) { ... }
const order = id1.compare(id2); // .lt, .eq, .gt
```

### Convert

```zig
const bytes = id.toBytes();      // [16]u8
const id = uuid.UUID.fromBytes(bytes);
const int = id.toU128();         // u128
const id = uuid.UUID.fromU128(int);
```

### Hash

```zig
const hash_val = id.hash(); // u64
```

## Namespace Constants

```zig
const dns = uuid.Namespace.dns;
const url = uuid.Namespace.url;
const oid = uuid.Namespace.oid;
const x500 = uuid.Namespace.x500;
```

## Allocator Model

Core UUID operations are allocation-free. The `Generator` type holds an allocator for operations that allocate:

```zig
const gen = uuid.Generator.init(allocator, io);
const str = try gen.toString(id);
defer allocator.free(str);
```

## Examples

The `examples/` directory contains **17 runnable examples** demonstrating all features:

| Example | Description |
|---------|-------------|
| [`basic_usage`](examples/basic_usage.zig) | Basic UUID generation, parsing, and inspection |
| [`v1_time_based`](examples/v1_time_based.zig) | Time-based v1 UUID generation |
| [`v3_md5_namespace`](examples/v3_md5_namespace.zig) | Deterministic v3 UUID via MD5 namespace hashing |
| [`v4_random`](examples/v4_random.zig) | Generate random v4 UUIDs |
| [`v5_sha1_namespace`](examples/v5_sha1_namespace.zig) | Deterministic v5 UUID via SHA-1 namespace hashing |
| [`v6_reordered`](examples/v6_reordered.zig) | Reordered time-based v6 UUID generation |
| [`v7_time_ordered`](examples/v7_time_ordered.zig) | Time-ordered v7 UUID generation |
| [`v8_application_specific`](examples/v8_application_specific.zig) | Application-specific v8 UUID generation |
| [`deterministic`](examples/deterministic.zig) | Deterministic v3, v5, and v8 generation |
| [`parsing_formats`](examples/parsing_formats.zig) | Parse and format UUIDs in all formats |
| [`comparison`](examples/comparison.zig) | Compare, convert, and hash UUIDs |
| [`generator`](examples/generator.zig) | Use the Generator with allocator |
| [`hash_map`](examples/hash_map.zig) | UUID as hash map keys |
| [`namespaces`](examples/namespaces.zig) | RFC 4122 namespace constants |
| [`version_detection`](examples/version_detection.zig) | Detect UUID version and variant |
| [`batch_generation`](examples/batch_generation.zig) | Batch generate v4 and v7 UUIDs |
| [`sequential_ids`](examples/sequential_ids.zig) | Sequential UUIDs for user registration and database storage |

To run any example:

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
zig build run-sequential-ids
```

## Validation

```bash
# Run all tests
zig build test

# Format source files
zig build fmt

# Check formatting
zig build fmt-check
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass: `zig build test`
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.
