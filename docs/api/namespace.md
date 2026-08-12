# Namespace

RFC 4122 predefined namespace UUIDs for v3/v5 generation.

## Constants

| Constant | Value |
|----------|-------|
| `Namespace.dns` | `6ba7b810-9dad-11d1-80b4-00c04fd430c8` |
| `Namespace.url` | `6ba7b811-9dad-11d1-80b4-00c04fd430c8` |
| `Namespace.oid` | `6ba7b812-9dad-11d1-80b4-00c04fd430c8` |
| `Namespace.x500` | `6ba7b814-9dad-11d1-80b4-00c04fd430c8` |

## Usage

```zig
const id_dns = uuid.UUID.v3(uuid.Namespace.dns, "www.example.com");
const id_url = uuid.UUID.v5(uuid.Namespace.url, "www.example.com");
```
