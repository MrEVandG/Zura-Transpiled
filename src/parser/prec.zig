const std = @import("std");

const token = @import("../lexer/tokens.zig");
const ast = @import("../ast/ast.zig");
const psr = @import("./helper.zig");

// based off of c operator precedence map
// http://en.cppreference.com/w/c/language/operator_precedence
pub const binding_power = enum(usize) {
    default = 0,
    comma = 1,
    assignment = 2,
    ternary = 3,
    logical_or = 4,
    logical_and = 5,
    relational = 6, // == !=
    compare = 7, // < > <= >=
    additive = 8, // + -
    multiplicative = 9, // * / %
    prefix = 10, // ++ -- + - ! ~
    postfix = 11, // ++ -- + - ! ~
    call = 12, // () [] .
    field = 13, // . ->
};

pub fn get_binding_power(tk: token.TokenType) binding_power {
    var bp_table = blk: {
        var map = std.EnumMap(token.TokenType, binding_power){};

        // Literals
        map.put(token.TokenType.Num, binding_power.default);
        map.put(token.TokenType.Ident, binding_power.default);
        map.put(token.TokenType.String, binding_power.default);

        // Binary operators
        map.put(token.TokenType.plus, binding_power.additive);
        map.put(token.TokenType.minus, binding_power.additive);
        map.put(token.TokenType.star, binding_power.multiplicative);
        map.put(token.TokenType.slash, binding_power.multiplicative);
        map.put(token.TokenType.mod, binding_power.multiplicative);

        // Unary operators
        map.put(token.TokenType.not, binding_power.prefix);
        map.put(token.TokenType.minus, binding_power.prefix);

        break :blk map;
    };
    return bp_table.get(tk).?;
}

pub fn nud_handler(parser: *psr.Parser, tk: token.TokenType) ast.Expr {
    return switch (tk) {
        .Num => ast.Expr{ .Number = psr.current(parser).value },
        .String => ast.Expr{ .String = psr.current(parser).value },
        .Ident => ast.Expr{ .Ident = psr.current(parser).value },
        else => unreachable, // This should never happen
    };
}

pub fn led_handler(parser: *psr.Parser, left: *ast.Expr) ast.Expr {
    var op = psr.current(parser);
    var value = get_binding_power(psr.current(parser).type);

    if (parser.index + 1 < parser.tks.items.len)
        _ = psr.next(parser);

    switch (op.type) {
        .plus, .minus, .star, .slash, .mod => {
            var right = psr.parse_expr(parser, value);
            return ast.Expr{ .Binary = ast.BinaryExpr{
                .op = op.value,
                .left = left,
                .right = &right,
            } };
        },
        else => unreachable, // This should never happen
    }
}
