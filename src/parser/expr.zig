const std = @import("std");

const ast = @import("../ast/ast.zig");
const prec = @import("prec.zig");
const psr = @import("helper.zig");

pub fn num(parser: *psr.Parser) ast.Expr {
    return ast.Expr{ .Number = psr.current(parser).value };
}

pub fn string(parser: *psr.Parser) ast.Expr {
    return ast.Expr{ .String = psr.current(parser).value };
}

pub fn ident(parser: *psr.Parser) ast.Expr {
    return ast.Expr{ .Ident = psr.current(parser).value };
}

pub fn binary(
    parser: *psr.Parser,
    left: *ast.Expr,
    op: []const u8,
    bp: *prec.bindingPower,
) ast.Expr {
    var right = psr.parseExpr(parser, bp.*);

    std.debug.print("Left: {any}\n Rigth: {any}\n Op: {s}", .{ left, right, op });

    return ast.Expr{ .Binary = ast.BinaryExpr{
        .op = op,
        .left = left,
        .right = &right,
    } };
}
