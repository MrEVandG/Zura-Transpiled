const std = @import("std");

const exprType = enum {
    Number,
    String,
    Ident,
    Binary,
    Unary,
};

pub const Expr = union(exprType) {
    Number: usize,
    String: []const u8,
    Ident: []const u8,
    Binary: BinaryExpr,
    Unary: UnaryExpr,
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

pub fn printExpr(e: Expr) void {
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
    }
}

pub var expr: Expr = undefined;
