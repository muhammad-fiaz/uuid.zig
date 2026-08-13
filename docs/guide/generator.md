# Generator

The `Generator` type provides an allocator-aware wrapper for UUID operations that need to allocate memory.

## Initialization

```zig
const gen = uuid.Generator.init(allocator, io);
```

## Generate

```zig
const id = gen.v1(timestamp, clock_seq, node);  // Time-based
const id = gen.v3(namespace, name);             // MD5 namespace
const id = try gen.v4();                         // Random
const id = gen.v5(namespace, name);             // SHA-1 namespace
const id = gen.v6(timestamp, clock_seq, node);  // Reordered time
const id = try gen.v7();                         // Time-ordered
const id = gen.v7WithTimestamp(ts, rand_a, rand_b); // v7 with custom timestamp
const id = gen.v8(custom_bytes);                // Application-specific
```

## String Conversion

```zig
const str = try gen.toString(id);
defer allocator.free(str);
std.debug.print("UUID: {s}\n", .{str});
```

## When to Use

- You need to allocate strings from UUIDs
- You want a convenient wrapper around all UUID generation methods
- You are building a higher-level API that manages its own allocator

## When Not to Use

For zero-allocation operations, use the `UUID` methods directly:

```zig
// Zero allocation - use directly
var buf: [36]u8 = undefined;
const str = id.encode(&buf);

// With allocation - use Generator
const str = try gen.toString(id);
defer allocator.free(str);
```
