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
    const user_data = [_]struct { name: []const u8, email: []const u8 }{
        .{ .name = "Alice Johnson", .email = "alice@example.com" },
        .{ .name = "Bob Smith", .email = "bob@example.com" },
        .{ .name = "Charlie Brown", .email = "charlie@example.com" },
        .{ .name = "Diana Prince", .email = "diana@example.com" },
        .{ .name = "Eve Wilson", .email = "eve@example.com" },
    };

    // Register users with sequential v7 UUIDs
    var users: [user_data.len]User = undefined;

    std.debug.print("Registering users with v7 UUIDs (time-ordered):\n\n", .{});

    for (user_data, 0..) |data, idx| {
        // v7 UUIDs are time-ordered, making them ideal for sequential IDs
        // They sort chronologically even without a database auto-increment
        const user_id = try uuid.UUID.v7Now(io);

        users[idx] = User{
            .id = user_id,
            .name = data.name,
            .email = data.email,
        };

        var id_buf: [36]u8 = undefined;
        std.debug.print("  Registered: {s} <{s}>\n", .{ data.name, data.email });
        std.debug.print("    ID: {s}\n\n", .{user_id.encode(&id_buf)});
    }

    // Simulate database storage - users are stored in order
    std.debug.print("--- Stored Users (in registration order) ---\n\n", .{});

    for (users, 0..) |user, idx| {
        var id_buf: [36]u8 = undefined;
        std.debug.print("  {d}. {s} - {s}\n", .{ idx + 1, user.name, user.id.encode(&id_buf) });
    }

    // Demonstrate that v7 UUIDs maintain order
    std.debug.print("\n--- Sequential Order Verification ---\n\n", .{});

    var all_ordered = true;
    for (users[1..], 0..) |user, idx| {
        const prev = users[idx];
        if (user.id.compare(prev.id) != .gt) {
            all_ordered = false;
            break;
        }
    }

    std.debug.print("  All UUIDs in sequential order: {}\n", .{all_ordered});

    // Simulate looking up a user by ID
    std.debug.print("\n--- User Lookup Simulation ---\n\n", .{});

    const target_user = users[2]; // Look up 3rd user
    var id_buf: [36]u8 = undefined;
    std.debug.print("  Looking up user with ID: {s}\n", .{target_user.id.encode(&id_buf)});

    // In production, this would be a database query
    // SELECT * FROM users WHERE id = ?
    for (users) |user| {
        if (user.id.eql(target_user.id)) {
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

    // Show v7 UUID benefits for sequential storage
    std.debug.print("--- v7 UUID Benefits for Sequential Storage ---\n\n", .{});
    std.debug.print("  1. Time-ordered: UUIDs sort chronologically\n", .{});
    std.debug.print("  2. No central authority needed: Each node can generate unique IDs\n", .{});
    std.debug.print("  3. Database-friendly: B-tree indexes work efficiently with ordered keys\n", .{});
    std.debug.print("  4. URL-safe: Standard UUID format for APIs\n", .{});
    std.debug.print("  5. Globally unique: No collisions across distributed systems\n", .{});

    // Alternative: Using v1 UUIDs with custom timestamp for strict sequencing
    std.debug.print("\n--- Alternative: v1 UUID with Custom Timestamp ---\n\n", .{});

    const base_timestamp: u60 = 0x1EC9414C232AB00; // Example timestamp
    const clock_seq: u14 = 0;
    const node = [6]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };

    for (0..3) |i| {
        // Increment timestamp for each ID
        const timestamp = base_timestamp + @as(u60, @intCast(i));
        const sequential_id = uuid.UUID.v1(timestamp, clock_seq, node);

        var buf: [36]u8 = undefined;
        std.debug.print("  Sequential v1 UUID {d}: {s}\n", .{ i + 1, sequential_id.encode(&buf) });
    }

    std.debug.print("\n  Note: v7 is preferred over v1 for new applications\n", .{});
    std.debug.print("  because v7 uses Unix epoch time and is more efficient.\n", .{});
}
