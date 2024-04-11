const std = @import("std");

const token = @import("../lexer/tokens.zig");
const err = @import("../helper/error.zig");
const ast = @import("../ast/ast.zig");
const psr = @import("helper.zig");
const expr = @import("expr.zig");

// The Zura bp table (binding power table) is based off of C's prec table
// but in reverse. The higher the number, the higher the precedence.
// https://en.cppreference.com/w/c/language/operator_precedence
pub const bindingPower = enum(usize) {
    default = 0,
    comma = 1,
    assignment = 2,
    ternary = 3,
    logicalOr = 4,
    logicalAnd = 5,
    relational = 6,
    comparison = 7,
    additive = 8,
    multiplicative = 9,
    power = 10,
    prefix = 11,
    postfix = 12,
    call = 13,
    field = 14,
    err = 15,
};

var bp_table = blk: {
    var map = std.EnumMap(token.TokenType, bindingPower){};

    // Literals
    map.put(token.TokenType.Num, bindingPower.default);
    map.put(token.TokenType.Float, bindingPower.default);
    map.put(token.TokenType.String, bindingPower.default);
    map.put(token.TokenType.Ident, bindingPower.default);

    // Operators
    map.put(token.TokenType.plus, bindingPower.additive);
    map.put(token.TokenType.minus, bindingPower.additive);
    map.put(token.TokenType.star, bindingPower.multiplicative);
    map.put(token.TokenType.slash, bindingPower.multiplicative);

    break :blk map;
};

var nud_table = blk: {
    var map = std.EnumMap(token.TokenType, *const fn (*psr.Parser) ast.Expr){};

    // Literals
    map.put(token.TokenType.Num, expr.num);
    map.put(token.TokenType.Float, expr.float);
    map.put(token.TokenType.String, expr.string);
    map.put(token.TokenType.Ident, expr.ident);

    break :blk map;
};

var led_table = blk: {
    var map = std.EnumMap(
        token.TokenType,
        *const fn (*psr.Parser, *ast.Expr, []const u8, *bindingPower) ast.Expr,
    ){};

    map.put(token.TokenType.plus, expr.binary);
    map.put(token.TokenType.minus, expr.binary);
    map.put(token.TokenType.star, expr.binary);
    map.put(token.TokenType.slash, expr.binary);

    break :blk map;
};

pub fn getBP(parser: *psr.Parser, tk: token.Token) bindingPower {
    _ = parser;
    // if (bp_table.get(tk.type) == null) {
    //     psr.pushError(parser, "Current Token not find in bp table!");
    //     return bindingPower.err;
    // }
    return bp_table.get(tk.type).?;
}

pub fn nudHandler(parser: *psr.Parser, tk: token.Token) ast.Expr {
    // if (nud_table.get(tk.type) == null) {
    //     psr.pushError(parser, "Current Token not find in nud table!");
    //     return ast.Expr{ .Err = ast.ExprKind.Err };
    // }
    return nud_table.get(tk.type).?(parser);
}

pub fn ledHandler(parser: *psr.Parser, left: *ast.Expr) ast.Expr {
    var op = psr.current(parser);

    // if (led_table.get(op.type) == null) {
    //     psr.pushError(parser, "Current Token not find in led table!");
    //     return ast.Expr{ .Err = ast.ExprKind.Err };
    // }

    var bp = getBP(parser, op);

    if (parser.idx + 1 < parser.tks.items.len)
        _ = psr.advance(parser);

    return led_table.get(op.type).?(parser, left, op.value, &bp);
}
