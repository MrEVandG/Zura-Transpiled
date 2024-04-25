const std = @import("std");

const expr = @import("expr.zig");

pub const Stmt = union(enum) {
    pub const Block = struct {
        items: std.ArrayListUnmanaged(*Stmt) = .{},
        pub fn deinit(self: Block, alloc: std.mem.Allocator) void {
            for (self.items.items) |s| s.deinit(alloc);
        }
    };

    block: Block,
    ExprStmt: struct {
        expr: *expr.Expr,
    },
    VarDecl: struct {
        name: []const u8,
        type: []const u8,
    },

    pub fn format(
        self: Stmt,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .block => |v| {
                for (v.items.items) |s| {
                    try writer.print("{any}", .{s});
                }
            },
            else => {},
        }
    }
    pub fn deinit(self: *const Stmt, alloc: std.mem.Allocator) void {
        switch (self.*) {
            .block => |block_data| block_data.deinit(alloc),
            else => {},
        }
        alloc.destroy(self);
    }
};
