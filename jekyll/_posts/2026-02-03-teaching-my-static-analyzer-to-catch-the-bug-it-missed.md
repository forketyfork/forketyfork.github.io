---
title: "Teaching My Static Analyzer to Catch the Bug It Missed"
date: 2026-02-03
tags: [Zig, Static Analysis, zwanzig, Architect]
---

I found a stack use-after-return bug in [Architect](https://github.com/forketyfork/architect) today. Then I taught [zwanzig](https://github.com/forketyfork/zwanzig), my Zig static analyzer, to catch it.

## The crash

Cmd+clicking links in the terminal would occasionally crash the app:

```
EXC_BAD_ACCESS / SIGSEGV
KERN_INVALID_ADDRESS at 0x0000000000000010
```

The crash happened in `_platform_memmove` called from `process.Child.spawn`. Classic memory corruption - the stack trace points at libc internals and tells you nothing useful.

## The bug

Here's the problematic code (simplified):

```zig
fn openUrl(allocator: std.mem.Allocator, url: []const u8) !void {
    const thread_allocator = std.heap.c_allocator;
    const owned_url = try thread_allocator.dupe(u8, url);

    const child = std.process.Child.init(
        &.{ "open", owned_url },  // <- stack-allocated argv
        allocator
    );

    const thread = try std.Thread.spawn(.{}, openUrlThread, .{ thread_allocator, child, owned_url });
    thread.detach();
}

fn openUrlThread(thread_allocator: std.mem.Allocator, child: std.process.Child, owned_url: []u8) void {
    var process = child;
    _ = process.spawnAndWait() catch {};
    thread_allocator.free(owned_url);
}
```

`&.{ "open", owned_url }` creates a temporary array on the stack. `Child.init` stores a pointer to this array. When `child` is passed to the thread, the struct is copied, but it still holds a pointer to the original stack memory. The function returns, reclaiming the stack frame. Thread tries to spawn using the now-invalid argv pointer. Crash.

## The fix

Put the argv array in a heap-allocated context struct:

```zig
const ThreadContext = struct {
    allocator: std.mem.Allocator,
    url: []const u8,
    argv: [2][]const u8,

    fn deinit(self: *ThreadContext) void {
        self.allocator.free(self.url);
        self.allocator.destroy(self);
    }
};

fn openUrl(_: std.mem.Allocator, url: []const u8) !void {
    const thread_allocator = std.heap.c_allocator;

    const ctx = try thread_allocator.create(ThreadContext);
    errdefer thread_allocator.destroy(ctx);

    ctx.allocator = thread_allocator;
    ctx.url = try thread_allocator.dupe(u8, url);
    errdefer thread_allocator.free(ctx.url);

    ctx.argv = .{ "open", ctx.url };

    const thread = try std.Thread.spawn(.{}, openUrlThread, .{ctx});
    thread.detach();
}

fn openUrlThread(ctx: *ThreadContext) void {
    defer ctx.deinit();
    var child = std.process.Child.init(&ctx.argv, ctx.allocator);
    _ = child.spawnAndWait() catch {};
}
```

The context lives on the heap and owns everything the thread needs. The Child is created inside the thread function, so its argv pointer points to heap memory that remains valid.

## Teaching zwanzig

Finding this bug manually was annoying. Intermittent crash, stack trace pointing nowhere useful, actual cause buried under several layers of indirection.

I wanted zwanzig to catch this. The pattern: a pointer to something on the stack gets passed to a detached thread, and the function returns before the thread finishes.

I wrote a checker called `stack-escape-engine`:

1. Tracks values with stack-backed origins (local variables, temporary arrays)
2. Follows pointers through function calls and struct fields
3. Flags when such values escape via `Thread.spawn` + `detach`
4. Ignores cases where the thread is joined (not detached)

It catches the exact pattern from the bug:

```zig
// zwanzig catches this:
const child = std.process.Child.init(&.{ "open", owned_url }, allocator);
const thread = try std.Thread.spawn(.{}, openUrlThread, .{ allocator, child, owned_url });
thread.detach();  // <- "Stack-backed value escapes via thread"
```

It also handles argv constructed via switch (the actual cross-platform code uses one), helpers wrapping the spawn call, etc. The test suite covers the patterns I could think of.

## Why bother

Every time I fix something subtle, I ask: could a tool have caught this? Sometimes no - the bug needs runtime context or is too dynamic. But stack escapes via thread captures? That's a pattern. Patterns can be detected.

If you're writing Zig:

```bash
git clone https://github.com/forketyfork/zwanzig
cd zwanzig && zig build
./zig-out/bin/zwanzig /path/to/your/project
```

The `stack-escape-engine` checker is on by default in v0.6.0+.

---

**Links:**
- [Architect #191](https://github.com/forketyfork/architect/pull/191) - the bug fix
- [zwanzig #54](https://github.com/forketyfork/zwanzig/pull/54) - the new checker (+3,233 / -271 lines)
- [zwanzig on GitHub](https://github.com/forketyfork/zwanzig)
