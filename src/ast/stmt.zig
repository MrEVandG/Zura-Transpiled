const std = @import("std");

const expr = @import("expr.zig");

pub const Stmt = union(enum) {
    Block: struct {
        stmts: []*Stmt,
    },
    exprStmt: struct {
        expr: *expr.Expr,
    },
    VarDecl: struct {
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
        switch (self.*) {}
        alloc.destroy(self);
    }
};
