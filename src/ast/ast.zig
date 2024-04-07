const std = @import("std");

const exprType = enum {
    Number,
    String,
    Ident,
    Binary,
};

pub const Expr = union(exprType) {
    Number: []const u8,
    String: []const u8,
    Ident: []const u8,
    Binary: BinaryExpr,
};

pub const BinaryExpr = struct {
    op: []const u8,
    left: *Expr,
    right: *Expr,
};

fn print(e: []const u8) void {
    std.debug.print("{s}", .{e});
}

pub fn printExpr(e: Expr) void {
    switch (e) {
        .Number => print(e.Number),
        .String => print(e.String),
        .Ident => print(e.Ident),
        .Binary => {
            printExpr(e.Binary.left.*);
            print(e.Binary.op);
            printExpr(e.Binary.right.*);
        },
    }
}

pub var expr: Expr = undefined;
