# UUID Versions

`uuid.zig` supports all standard UUID versions.

## v1 - Time-Based

Uses a 60-bit timestamp, 14-bit clock sequence, and 6-byte node.

```zig
const id = uuid.UUID.v1(timestamp, clock_seq, node);
```

## v3 - MD5 Namespace

Deterministic UUID derived from MD5 hash of namespace + name.

```zig
const id = uuid.UUID.v3(uuid.Namespace.dns, "www.example.com");
```

## v4 - Random

Cryptographically secure random UUID.

```zig
const id = try uuid.UUID.v4(io);
```

## v5 - SHA-1 Namespace

Deterministic UUID derived from SHA-1 hash of namespace + name.

```zig
const id = uuid.UUID.v5(uuid.Namespace.dns, "www.example.com");
```

## v6 - Reordered Time-Based

Like v1 but with reordered time fields for better database indexing.

```zig
const id = uuid.UUID.v6(timestamp, clock_seq, node);
```

## v7 - Unix Epoch Time-Based

Time-ordered UUID with millisecond timestamp and random bits.

```zig
// Auto-generated timestamp
const id = try uuid.UUID.v7Now(io);

// Custom timestamp
const id = uuid.UUID.v7(timestamp_ms, rand_a, rand_b);
```

## v8 - Application-Specific

Custom 16-byte payload with version and variant bits set.

```zig
const custom = [_]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
                      0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 };
const id = uuid.UUID.v8(custom);
```

## Nil UUID

The zero UUID: `00000000-0000-0000-0000-000000000000`.

```zig
const nil = uuid.UUID.nil;
const is_nil = nil.isNil(); // true
```

## Namespace Constants

RFC 4122 predefined namespaces for v3/v5:

```zig
const dns = uuid.Namespace.dns;
const url = uuid.Namespace.url;
const oid = uuid.Namespace.oid;
const x500 = uuid.Namespace.x500;
```
