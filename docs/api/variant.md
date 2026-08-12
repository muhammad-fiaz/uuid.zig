# Variant

Enum representing UUID variants.

## Definition

```zig
pub const Variant = enum {
    ncs, rfc, microsoft, future,
    // ...
};
```

## Variants

| Variant | Description |
|---------|-------------|
| `.ncs` | NCS backward compatibility |
| `.rfc` | RFC 4122 (most common) |
| `.microsoft` | Microsoft backward compatibility |
| `.future` | Reserved for future |

## Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `fromByte` | `(b: u8) Variant` | Determine variant from byte |
