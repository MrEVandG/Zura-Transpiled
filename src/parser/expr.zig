const std = @import("std");

const ast = @import("../ast/ast.zig");
const prec = @import("prec.zig");
const psr = @import("helper.zig");

pub fn parse_num(parser: *psr.Parser) ast.Expr {
    return ast.Expr{ .Number = psr.current(parser).value };
}

pub fn parse_string(parser: *psr.Parser) ast.Expr {
    return ast.Expr{ .String = psr.current(parser).value };
}

pub fn parse_ident(parser: *psr.Parser) ast.Expr {
    return ast.Expr{ .Ident = psr.current(parser).value };
}

pub fn parse_unary(parser: *psr.Parser) ast.Expr {
    var op = psr.current(parser);
    var right = psr.parse_expr(parser, prec.binding_power.prefix);
    return ast.Expr{ .Unary = ast.UnaryExpr{ .op = op.value, .expr = &right } };
}

pub fn parse_binary(
    parser: *psr.Parser,
    left: *ast.Expr,
    op: []const u8,
    bp: *prec.binding_power,
) ast.Expr {
    var right = psr.parse_expr(parser, bp.*);

    std.debug.print("left: {}, right: {}, op: {s}\n", .{ left.*, right, op });

    return ast.Expr{ .Binary = ast.BinaryExpr{
        .op = op,
        .left = left,
        .right = &right,
    } };
}
