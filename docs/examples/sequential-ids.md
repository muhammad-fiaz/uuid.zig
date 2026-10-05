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

    std.debug.print("=== Sequential UUID Generation for Users ===\n\n", .{});

    // Simulate a user registration system
    // Each user gets a v7 UUID which is time-ordered and sequential
    const User = struct {
        id: uuid.UUID,
        name: []const u8,
        email: []const u8,
    };

    // Simulated user data
    const userData = [_]struct { name: []const u8, email: []const u8 }{
        .{ .name = "Alice Johnson", .email = "alice@example.com" },
        .{ .name = "Bob Smith", .email = "bob@example.com" },
        .{ .name = "Charlie Brown", .email = "charlie@example.com" },
        .{ .name = "Diana Prince", .email = "diana@example.com" },
        .{ .name = "Eve Wilson", .email = "eve@example.com" },
    };

    // Register users with sequential v7 UUIDs
    var users: [userData.len]User = undefined;

    std.debug.print("Registering users with v7 UUIDs (time-ordered):\n\n", .{});

    for (userData, 0..) |data, idx| {
        // v7 UUIDs are time-ordered, making them ideal for sequential IDs
        // They sort chronologically even without a database auto-increment
        const userId = try uuid.UUID.v7Now(io);

        users[idx] = User{
            .id = userId,
            .name = data.name,
            .email = data.email,
        };

        var idBuf: [36]u8 = undefined;
        std.debug.print("  Registered: {s} <{s}>\n", .{ data.name, data.email });
        std.debug.print("    ID: {s}\n\n", .{userId.encode(&idBuf)});
    }

    // Simulate database storage - users are stored in order
    std.debug.print("--- Stored Users (in registration order) ---\n\n", .{});

    for (users, 0..) |user, idx| {
        var idBuf: [36]u8 = undefined;
        std.debug.print("  {d}. {s} - {s}\n", .{ idx + 1, user.name, user.id.encode(&idBuf) });
    }

    // Demonstrate that v7 UUIDs maintain order
    std.debug.print("\n--- Sequential Order Verification ---\n\n", .{});

    var allOrdered = true;
    for (users[1..], 0..) |user, idx| {
        const prev = users[idx];
        if (user.id.compare(prev.id) != .gt) {
            allOrdered = false;
            break;
        }
    }

    std.debug.print("  All UUIDs in sequential order: {}\n", .{allOrdered});

    // Simulate looking up a user by ID
    std.debug.print("\n--- User Lookup Simulation ---\n\n", .{});

    const targetUser = users[2]; // Look up 3rd user
    var idBuf: [36]u8 = undefined;
    std.debug.print("  Looking up user with ID: {s}\n", .{targetUser.id.encode(&idBuf)});

    // In production, this would be a database query
    // SELECT * FROM users WHERE id = ?
    for (users) |user| {
        if (user.id.eql(targetUser.id)) {
            std.debug.print("  Found: {s} <{s}>\n", .{ user.name, user.email });
            break;
        }
    }

    // Show how v7 UUIDs can be used as primary keys
    std.debug.print("\n--- Database Schema Example ---\n\n", .{});
    std.debug.print("  CREATE TABLE users (\n", .{});
    std.debug.print("    id UUID PRIMARY KEY,\n", .{});
    std.debug.print("    name VARCHAR(255) NOT NULL,\n", .{});
    std.debug.print("    email VARCHAR(255) UNIQUE NOT NULL\n", .{});
    std.debug.print("  );\n\n", .{});

    // Demonstrate batch insertion scenario
    std.debug.print("--- Batch Insert Simulation ---\n\n", .{});
    std.debug.print("  BEGIN TRANSACTION;\n", .{});

    for (users) |user| {
        var buf: [36]u8 = undefined;
        std.debug.print("  INSERT INTO users (id, name, email) VALUES ('{s}', '{s}', '{s}');\n", .{
            user.id.encode(&buf),
            user.name,
            user.email,
        });
    }

    std.debug.print("  COMMIT;\n\n", .{});

    // Alternative: Using v1 UUIDs with custom timestamp for strict sequencing
    std.debug.print("\n--- Alternative: v1 UUID with Custom Timestamp ---\n\n", .{});

    const baseTimestamp: u60 = 0x1EC9414C232AB00; // Example timestamp
    const clockSequence: u14 = 0;
    const node = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };

    for (0..3) |i| {
        // Increment timestamp for each ID
        const timestamp = baseTimestamp + @as(u60, @intCast(i));
        const sequentialId = uuid.UUID.v1(timestamp, clockSequence, node);

        var buf: [36]u8 = undefined;
        std.debug.print("  Sequential v1 UUID {d}: {s}\n", .{ i + 1, sequentialId.encode(&buf) });
    }

    std.debug.print("\n  Note: v7 is preferred over v1 for new applications\n", .{});
    std.debug.print("  because v7 uses Unix epoch time and is more efficient.\n", .{});
}
```

## Run

```bash
zig build run-sequential-ids
```

## Output

```text
=== Sequential UUID Generation for Users ===

Registering users with v7 UUIDs (time-ordered):

  Registered: Alice Johnson <alice@example.com>
    ID: 01a10ae8-3732-7d9b-a12d-8c1018295d4f

  Registered: Bob Smith <bob@example.com>
    ID: 01a10ae8-3732-7d25-a4a6-7ca80be9cb55

  Registered: Charlie Brown <charlie@example.com>
    ID: 01a10ae8-3732-73b3-bf6a-528ba272eba8

  Registered: Diana Prince <diana@example.com>
    ID: 01a10ae8-3732-7542-a635-ee274b4421d7

  Registered: Eve Wilson <eve@example.com>
    ID: 01a10ae8-3732-740b-b2f8-947ee20b2890

--- Stored Users (in registration order) ---

  1. Alice Johnson - 01a10ae8-3732-7d9b-a12d-8c1018295d4f
  2. Bob Smith - 01a10ae8-3732-7d25-a4a6-7ca80be9cb55
  3. Charlie Brown - 01a10ae8-3732-73b3-bf6a-528ba272eba8
  4. Diana Prince - 01a10ae8-3732-7542-a635-ee274b4421d7
  5. Eve Wilson - 01a10ae8-3732-740b-b2f8-947ee20b2890

--- Sequential Order Verification ---

  All UUIDs in sequential order: false

--- User Lookup Simulation ---

  Looking up user with ID: 01a10ae8-3732-73b3-bf6a-528ba272eba8
  Found: Charlie Brown <charlie@example.com>

--- Database Schema Example ---

  CREATE TABLE users (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
  );

--- Batch Insert Simulation ---

  BEGIN TRANSACTION;
  INSERT INTO users (id, name, email) VALUES ('01a10ae8-3732-7d9b-a12d-8c1018295d4f', 'Alice Johnson', 'alice@example.com');
  INSERT INTO users (id, name, email) VALUES ('01a10ae8-3732-7d25-a4a6-7ca80be9cb55', 'Bob Smith', 'bob@example.com');
  INSERT INTO users (id, name, email) VALUES ('01a10ae8-3732-73b3-bf6a-528ba272eba8', 'Charlie Brown', 'charlie@example.com');
  INSERT INTO users (id, name, email) VALUES ('01a10ae8-3732-7542-a635-ee274b4421d7', 'Diana Prince', 'diana@example.com');
  INSERT INTO users (id, name, email) VALUES ('01a10ae8-3732-740b-b2f8-947ee20b2890', 'Eve Wilson', 'eve@example.com');
  COMMIT;

--- Alternative: v1 UUID with Custom Timestamp ---

  Sequential v1 UUID 1: c232ab00-9414-11ec-8000-aabbccddeeff
  Sequential v1 UUID 2: c232ab01-9414-11ec-8000-aabbccddeeff
  Sequential v1 UUID 3: c232ab02-9414-11ec-8000-aabbccddeeff

  Note: v7 is preferred over v1 for new applications
  because v7 uses Unix epoch time and is more efficient.
```

> [!NOTE]
> User registration IDs embed the current time plus fresh randomness, so they differ on every run. The v1 sequence at the end is deterministic.

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
INSERT INTO users (id, name, email) VALUES ('01a10ae8-3732-7d9b-a12d-8c1018295d4f', 'Alice Johnson', 'alice@example.com');
INSERT INTO users (id, name, email) VALUES ('01a10ae8-3732-7d25-a4a6-7ca80be9cb55', 'Bob Smith', 'bob@example.com');
COMMIT;
```
