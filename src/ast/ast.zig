const std = @import("std");

pub const ExprKind = enum {
    String,
    Ident,
    Number,
    Float,
    Binary,
};

pub const Expr = union(ExprKind) {
    Number: []const u8,
    Float: []const u8,
    String: []const u8,
    Ident: []const u8,
    Binary: struct {
        op: []const u8,
        left: *Expr,
        right: *Expr,
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
            .Number, .Float, .String, .Ident => |value| {
                try writer.print("{s}", .{value});
            },
            .Binary => |value| {
                if (value.left == value.left.Binary.left) std.debug.panic("value.left == value! YOU FUCKED UP!", .{});
                try writer.print("({} {s} {})", .{ value.left.*, value.op, value.right.* });
            },
        }
    }

    pub fn deinit(self: *const Expr, alloc: std.mem.Allocator) void {
        switch (self.*) {
            .Number, .Float, .String, .Ident => {},
            .Binary => |value| {
                value.left.deinit(alloc);
                value.right.deinit(alloc);
            },
        }
        alloc.destroy(self);
    }
};
