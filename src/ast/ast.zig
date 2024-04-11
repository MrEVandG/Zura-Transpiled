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

    pub fn print(self: *Expr) void {
        switch (self.*) {
            .Number => |value| {
                std.debug.print("{s}", .{value});
            },
            .Float => |value| {
                std.debug.print("{s}", .{value});
            },
            .String => |value| {
                std.debug.print("{s}", .{value});
            },
            .Ident => |value| {
                std.debug.print("{s}", .{value});
            },
            .Binary => |value| {
                if (value.left == self) {
                    std.debug.panic("so it was self-referencing!\n", .{});
                }

                std.debug.print("(", .{});
                print(value.left);
                std.debug.print("{s}", .{value.op});
                print(value.right);
                std.debug.print(")", .{});
            },
        }
    }
};
