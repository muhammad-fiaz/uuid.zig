# Comparison & Conversion

## Equality

```zig
if (id1.eql(id2)) {
    std.debug.print("UUIDs are equal\n", .{});
}
```

## Ordering

```zig
const order = id1.compare(id2); // .lt, .eq, .gt
```

## Byte Conversion

```zig
// To bytes
const bytes = id.toBytes(); // [16]u8

// From bytes
const id = uuid.UUID.fromBytes(bytes);
```

## Integer Conversion

```zig
// To u128
const int_val = id.toU128(); // u128

// From u128
const id = uuid.UUID.fromU128(int_val);
```

## Hashing

```zig
const hash_val = id.hash(); // u64
```

Useful for hash maps:

```zig
var map = std.AutoHashMap(uuid.UUID, Value).init(allocator);
try map.put(id, value);
```

## Version & Variant Inspection

```zig
const version = id.version();   // .v1, .v3, .v4, .v5, .v6, .v7, .v8, .nil, .unknown
const variant = id.variant();   // .ncs, .rfc, .microsoft, .future
const is_nil = id.isNil();      // true/false
```
