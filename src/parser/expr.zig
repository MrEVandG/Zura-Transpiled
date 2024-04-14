const std = @import("std");

const ast = @import("../ast/ast.zig");
const prec = @import("prec.zig");
const psr = @import("helper.zig");
const tkn = @import("../lexer/tokens.zig");

/// Caller own returns to memory
/// the way it works is we are creating a new pointer in memory that points to
/// the ast.Expr tagged union.
///     const expr = try alloc.create(ast.Expr);
/// Then we are setting the dereferenced value of the pointer to our value
/// that we want to return. so in this case the value is a Number tagged union
///    expr.* = .{ .Number = psr.current(parser).value };
/// Now since we are returning a * to ast.Expr we can just return expr.
///   return expr;
/// The caller will then take the pointer and do whatever it wants with it.
/// This logic is the same or similar for all of the nud and prefix functions.
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

// TODO: There is a small bug here, if we have any unary expr anything after that will
// not be parsed correctly.
pub fn unary(parser: *psr.Parser, alloc: std.mem.Allocator) error{OutOfMemory}!*ast.Expr {
    var op = psr.current(parser);
    _ = psr.advance(parser);
    var right = try psr.parseExpr(alloc, parser, prec.getBP(parser, op));

    const expr = try alloc.create(ast.Expr);
    expr.* = .{ .Unary = .{ .op = op.value, .right = right } };
    return expr;
}

// TODO: Finish adding in support for Grouping
pub fn group(parser: *psr.Parser, alloc: std.mem.Allocator) error{OutOfMemory}!*ast.Expr {
    _ = parser;
    var body: *ast.Expr = undefined;

    const expr = try alloc.create(ast.Expr);
    expr.* = .{ .Group = .{ .body = body } };
    return expr;
}

/// Caller own returns to memory
/// This function is a bit different from the others. We are passing in the left
/// expression as a parameter. This is because we need to know the left expression
/// to determine the binding power of the current expression. We then parse the right
/// expression and create a new pointer in memory that points to the ast.Expr tagged
/// union. We then set the dereferenced value of the pointer to our value that we want
/// to return. so in this case the value is a Binary tagged union. We then return the pointer.
/// The caller will then take the pointer and do whatever it wants with it.
/// This logic is the same or similar for all of the led and infix functions.
pub fn binary(
    parser: *psr.Parser,
    left: *ast.Expr,
    op: []const u8,
    bp: prec.bindingPower,
    alloc: std.mem.Allocator,
) error{OutOfMemory}!*ast.Expr {
    var right = try psr.parseExpr(alloc, parser, bp);

    std.debug.print("op: {s}\n", .{op});

    const expr = try alloc.create(ast.Expr);
    expr.* = .{ .Binary = .{ .op = op, .left = left, .right = right } };
    return expr;
}
