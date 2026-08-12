# Version

Enum representing UUID versions.

## Definition

```zig
pub const Version = enum {
    v1, v2, v3, v4, v5, v6, v7, v8,
    nil, unknown,
    // ...
};
```

## Variants

| Variant | Value | Description |
|---------|-------|-------------|
| `.v1` | 1 | Time-based |
| `.v2` | 2 | DCE Security |
| `.v3` | 3 | MD5 namespace |
| `.v4` | 4 | Random |
| `.v5` | 5 | SHA-1 namespace |
| `.v6` | 6 | Reordered time |
| `.v7` | 7 | Epoch time |
| `.v8` | 8 | Application-specific |
| `.nil` | 0 | Nil UUID |
| `.unknown` | 0 | Unknown version |

## Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `toInt` | `(v: Version) u8` | Convert to integer |
| `fromInt` | `(value: u8) Version` | Create from integer |
