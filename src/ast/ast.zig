const std = @import("std");

pub const ExprKind = enum {
    Err,
};

pub const Expr = union(enum) {
    Err: ExprKind,
    Number: []const u8,
    String: []const u8,
    Ident: []const u8,
    Binary: BinaryExpr,
    Unary: UnaryExpr,

    pub fn deinit(self: Expr, allocator: std.mem.Allocator) void {
        switch (self) {
            .Number => {},
            .String => {},
            .Ident => {},
            .Binary => |bin| {
                // Don't do anything with op
                bin.left.deinit(allocator);
                bin.right.deinit(allocator);

                allocator.free(bin.left);
                allocator.free(bin.right);
            },
            .Unary => |un| {
                un.expr.deinit(allocator);
                allocator.free(un.expr);
            },
        }
    }
};

pub const BinaryExpr = struct {
    op: []const u8,
    left: *Expr,
    right: *Expr,
};

pub const UnaryExpr = struct {
    op: []const u8,
    expr: *Expr,
};

fn printBinaryExpr(e: BinaryExpr) void {
    std.debug.print("(", .{});
    printExpr(e.left.*);
    std.debug.print(" {s} ", .{e.op});
    printExpr(e.right.*);
    std.debug.print(")", .{});
}

pub fn printExpr(e: *const Expr) void {
    switch (e) {
        .Number => {
            std.debug.print("{d}", .{e.Number});
        },
        .String => {
            std.debug.print("{s}", .{e.String});
        },
        .Ident => {
            std.debug.print("{s}", .{e.Ident});
        },
        .Binary => {
            printBinaryExpr(e.Binary);
        },
        .Unary => {
            std.debug.print("{s}", .{e.Unary.op});
            printExpr(e.Unary.expr.*);
        },
        else => unreachable,
    }
}

pub var expr: Expr = undefined;
