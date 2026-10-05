# Installation

## Prerequisites

| Requirement | Version |
|-------------|---------|
| **Zig** | **0.17.0** |

> [!NOTE]
> For Zig 0.16.0, use `uuid.zig` version `0.0.1`.

## Method 1: Zig Fetch (Recommended)

```bash
zig fetch --save https://github.com/muhammad-fiaz/uuid.zig/archive/refs/tags/0.0.2.tar.gz
```

For Zig 0.16.0, use:

```bash
zig fetch --save https://github.com/muhammad-fiaz/uuid.zig/archive/refs/tags/0.0.1.tar.gz
```

## Method 2: Zig Fetch (Main Branch)

```bash
zig fetch --save git+https://github.com/muhammad-fiaz/uuid.zig.git
```

## Method 3: Manual `build.zig.zon`

Add the dependency to your `build.zig.zon`:

```zig
.dependencies = .{
    .uuid = .{
        .url = "https://github.com/muhammad-fiaz/uuid.zig/archive/refs/tags/0.0.2.tar.gz",
        .hash = "...", // Run `zig fetch --save <url>` to generate.
    },
},
```

For Zig 0.16.0, use:

```zig
.dependencies = .{
    .uuid = .{
        .url = "https://github.com/muhammad-fiaz/uuid.zig/archive/refs/tags/0.0.1.tar.gz",
        .hash = "...", // Run `zig fetch --save <url>` to generate.
    },
},
```

## Method 4: Local Source

```bash
git clone https://github.com/muhammad-fiaz/uuid.zig.git
cd uuid.zig
zig build
```

Use a path dependency:

```zig
.dependencies = .{
    .uuid = .{
        .path = "../uuid.zig",
    },
},
```

## Wire into `build.zig`

```zig
const uuid_dep = b.dependency("uuid", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("uuid", uuid_dep.module("uuid"));
```

## Cross-Compilation

```bash
# Linux ARM64 from Windows
zig build -Dtarget=aarch64-linux

# Windows from Linux
zig build -Dtarget=x86_64-windows

# macOS Apple Silicon from Linux
zig build -Dtarget=aarch64-macos
```
