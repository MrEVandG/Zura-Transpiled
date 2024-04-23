const std = @import("std");

const expr = @import("expr.zig");

pub const Stmt = union(enum) {
    pub const Block = struct {
        items: std.ArrayListUnmanaged(*Stmt) = .{},
        pub fn deinit(self: Block, alloc: std.mem.Allocator) void {
            for (self.items.items) |s| s.deinit(alloc);
            self.items.deinit(alloc);
        }
    };

    block: Block,
    exprStmt: struct {
        expr: *expr.Expr,
    },
    varDecl: struct {
        name: []const u8,
        type: []const u8,
        value: *Stmt,
    },

    pub fn format(
        self: Stmt,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = writer;
        _ = options;
        _ = fmt;
        _ = self;
    }
    pub fn deinit(self: *const Stmt, alloc: std.mem.Allocator) void {
        switch (self.*) {
            .block => |block_data| block_data.deinit(alloc),
        }
        alloc.destroy(self);
    }
};
