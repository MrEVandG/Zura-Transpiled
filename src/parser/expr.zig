const std = @import("std");

const ast = @import("../ast/ast.zig");
const prec = @import("prec.zig");
const psr = @import("helper.zig");

/// Caller own returns to memory
pub fn num(parser: *psr.Parser, alloc: std.mem.Allocator) error{OutOfMemory}!*ast.Expr {
    const expr = try alloc.create(ast.Expr);
    expr.* = .{ .Number = psr.current(parser).value };
    return expr;
}

pub fn float(parser: *psr.Parser, alloc: std.mem.Allocator) error{OutOfMemory}!*ast.Expr {
    const expr = try alloc.create(ast.Expr);
    expr.* = .{ .Float = psr.current(parser).value };
    return expr;
}

pub fn string(parser: *psr.Parser, alloc: std.mem.Allocator) error{OutOfMemory}!*ast.Expr {
    const expr = try alloc.create(ast.Expr);
    expr.* = .{ .String = psr.current(parser).value };
    return expr;
}

pub fn ident(parser: *psr.Parser, alloc: std.mem.Allocator) error{OutOfMemory}!*ast.Expr {
    const expr = try alloc.create(ast.Expr);
    expr.* = .{ .Ident = psr.current(parser).value };
    return expr;
}

pub fn binary(
    parser: *psr.Parser,
    left: *ast.Expr,
    op: []const u8,
    bp: *prec.bindingPower,
    alloc: std.mem.Allocator,
) error{OutOfMemory}!*ast.Expr {
    var right = try psr.parseExpr(alloc, parser, bp.*);

    std.debug.print("Left: {any}\nRigth: {any}\n Op: {s}\n", .{ left, right, op });

    const expr = try alloc.create(ast.Expr);
    expr.* = .{ .Binary = .{ .op = op, .left = left, .right = right } };
    return expr;
}
