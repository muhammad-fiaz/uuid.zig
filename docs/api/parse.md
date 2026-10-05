# Parse API

UUID parsing functions.

## Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `parse` | `(input: []const u8) ParseError!UUID` | Parse canonical format |
| `parseCompact` | `(input: []const u8) ParseError!UUID` | Parse compact format |
| `parseBraced` | `(input: []const u8) ParseError!UUID` | Parse braced format |
| `parseUrn` | `(input: []const u8) ParseError!UUID` | Parse URN format |
| `parseAll` | `(inputs: []const []const u8, allocator: Allocator) (Allocator.Error \|\| ParseError)![]UUID` | Parse multiple UUIDs (caller owns result) |
| `parseMultiDelim` | `(input: []const u8, delimiter: u8, allocator: Allocator) (Allocator.Error \|\| ParseError)![]UUID` | Parse delimited UUIDs (caller owns result) |

> [!NOTE]
> `parseAll` and `parseMultiDelim` return caller-owned slices. Free them with the same allocator when done.

## Formats

| Format | Example | Length |
|--------|---------|--------|
| Canonical | `550e8400-e29b-41d4-a716-446655440000` | 36 |
| Compact | `550e8400e29b41d4a716446655440000` | 32 |
| Braced | `{550e8400-e29b-41d4-a716-446655440000}` | 38 |
| URN | `urn:uuid:550e8400-e29b-41d4-a716-446655440000` | 45 |

## Errors

| Error | Description |
|-------|-------------|
| `InvalidLength` | Wrong input length |
| `InvalidFormat` | Missing dashes or wrong structure |
| `InvalidCharacter` | Non-hex character |
