# Custom Generation

`uuid.zig` keeps the common APIs simple while making every deterministic and custom path explicitly configurable.

## Custom Node and Clock Sequence (v1 and v6)

The timestamp, clock sequence, and node identifier are all explicit parameters. Nothing is auto-detected, so no machine-specific information leaks by default.

```zig
const timestamp: u60 = 0x123456789ABCDEF; // 100ns since 1582-10-15
const clock_seq: u14 = 0x1234;            // 14-bit clock sequence
const node = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };

const id1 = uuid.UUID.v1(timestamp, clock_seq, node);
const id6 = uuid.UUID.v6(timestamp, clock_seq, node);
```

## Custom Timestamp and Randomness (v7)

`UUID.v7` accepts an explicit millisecond timestamp and explicit random words. This makes tests fully deterministic without depending on the wall clock or the OS randomness source.

```zig
const timestamp_ms: u48 = 0x123456789ABC;
const rand_a: u12 = 0x456;
const rand_b = [_]u8{ 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA };
const id = uuid.UUID.v7(timestamp_ms, rand_a, rand_b);
```

For the current time with cryptographically secure randomness, use `UUID.v7Now(io)`.

## Custom v8 Payload

`UUID.v8` accepts a full 16-byte application-defined payload. The version (8) and RFC variant bits are set automatically.

```zig
const custom = [_]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
                      0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10 };
const id = uuid.UUID.v8(custom);
```

## Custom Namespace

Namespace-based versions accept any `UUID` as the namespace, not just the predefined constants.

```zig
const custom_namespace = uuid.UUID.fromBytes(.{
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
    0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF,
});
const id3 = uuid.UUID.v3(custom_namespace, "name");
const id5 = uuid.UUID.v5(custom_namespace, "name");
```

## Custom Randomness Source

Advanced users can supply their own randomness. Use Zig's `std.Io` instance with `io.randomSecure` for cryptographically secure bytes, or drive `UUID.v4`/`UUID.v7` from any source you control.

```zig
var bytes: [16]u8 = undefined;
try io.randomSecure(&bytes);
bytes[6] = 0x40 | (bytes[6] & 0x0F);
bytes[8] = 0x80 | (bytes[8] & 0x3F);
const id = uuid.UUID.fromBytes(bytes);
```

::: warning
Deterministic or user-controlled randomness is **not** cryptographically secure. Never label custom random sources as secure unless they genuinely are.
:::
