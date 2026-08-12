# Generator

The `Generator` type provides an allocator-aware wrapper for UUID operations that need to allocate memory.

## Initialization

```zig
const gen = uuid.Generator.init(allocator, io);
```

## Generate

```zig
const id = try gen.v4();       // Random UUID
const id = try gen.v7();    // Time-ordered UUID
```

## String Conversion

```zig
const str = try gen.toString(id);
defer allocator.free(str);
std.debug.print("UUID: {s}\n", .{str});
```

## When to Use

- You need to allocate strings from UUIDs
- You want a convenient wrapper around `UUID.v4` and `UUID.v7Now`
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
