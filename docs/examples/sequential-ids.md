# Sequential IDs

Generate sequential UUIDs for user registration and database storage.

## Overview

When building applications that need unique identifiers for users, orders, or any
entities, sequential UUIDs (v7) provide an excellent solution. They are time-ordered,
globally unique, and work efficiently with database indexes.

## Code

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

    const User = struct {
        id: uuid.UUID,
        name: []const u8,
        email: []const u8,
    };

    // Register users with v7 UUIDs
    const user_data = [_]struct { name: []const u8, email: []const u8 }{
        .{ .name = "Alice Johnson", .email = "alice@example.com" },
        .{ .name = "Bob Smith", .email = "bob@example.com" },
        .{ .name = "Charlie Brown", .email = "charlie@example.com" },
    };

    var users: [user_data.len]User = undefined;

    for (user_data, 0..) |data, idx| {
        // v7 UUIDs are time-ordered, ideal for sequential IDs
        const user_id = try uuid.UUID.v7Now(io);

        users[idx] = User{
            .id = user_id,
            .name = data.name,
            .email = data.email,
        };

        var id_buf: [36]u8 = undefined;
        std.debug.print("Registered: {s} -> {s}\n", .{
            data.name,
            user_id.encode(&id_buf),
        });
    }

    // Users are stored in chronological order
    for (users, 0..) |user, idx| {
        var id_buf: [36]u8 = undefined;
        std.debug.print("{d}. {s} - {s}\n", .{
            idx + 1,
            user.name,
            user.id.encode(&id_buf),
        });
    }
}
```

## Run

```bash
zig build run-sequential-ids
```

## Why v7 for Sequential IDs?

| Benefit | Description |
|---------|-------------|
| Time-ordered | UUIDs sort chronologically without extra columns |
| No central authority | Each node generates unique IDs independently |
| Database-friendly | B-tree indexes work efficiently with ordered keys |
| URL-safe | Standard UUID format works in APIs |
| Globally unique | No collisions across distributed systems |

## Database Schema

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL
);
```

## Batch Insert

```sql
BEGIN TRANSACTION;
INSERT INTO users (id, name, email) VALUES ('019ff869-6c60-7f33-...', 'Alice', 'alice@example.com');
INSERT INTO users (id, name, email) VALUES ('019ff869-6c60-7e4b-...', 'Bob', 'bob@example.com');
COMMIT;
```
