const std = @import("std");

pub const Expr = union(enum) {
    Error: []const u8,
    Number: []const u8,
    Float: []const u8,
    String: []const u8,
    Ident: []const u8,
    Binary: struct {
        op: []const u8,
        left: *Expr,
        right: *Expr,
    },
    Unary: struct {
        op: []const u8,
        right: *Expr,
    },
    Group: struct {
        body: *Expr,
    },

    pub fn format(
        self: Expr,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        switch (self) {
            .Number, .Float, .String, .Ident, .Error => |value| {
                try writer.print("{s}", .{value});
            },
            .Binary => |value| {
                try writer.print("({} {s} {})", .{ value.left.*, value.op, value.right.* });
            },
            .Unary => |value| {
                try writer.print("({s}{})", .{ value.op, value.right.* });
            },
            .Group => |value| {
                try writer.print("({})", .{value.body.*});
            },
        }
    }

    pub fn deinit(self: *const Expr, alloc: std.mem.Allocator) void {
        switch (self.*) {
            .Number, .Float, .String, .Ident, .Error => {},
            .Binary => |value| {
                value.left.deinit(alloc);
                value.right.deinit(alloc);
            },
            .Unary => |value| {
                value.right.deinit(alloc);
            },
            .Group => |value| {
                value.body.deinit(alloc);
            },
        }
        alloc.destroy(self);
    }
};
