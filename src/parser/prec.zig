const std = @import("std");

const token = @import("../lexer/tokens.zig");
const err = @import("../helper/error.zig");
const ast = @import("../ast/ast.zig");
const psr = @import("./helper.zig");
const expr = @import("expr.zig");

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
    power = 10, // **
    prefix = 11, // ++ -- + - ! ~
    postfix = 12, // ++ -- + - ! ~
    call = 13, // () [] .
    field = 14, // . ->
    err = 15,
};

pub fn get_binding_power(parser: *psr.Parser, tk: token.TokenType) binding_power {
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
    var current = psr.current(parser);
    if (bp_table.get(current.type) == null) {
        parser.errors.append(
            psr.Parser.Error{ ._tks = current, .msg = "TokenType not found in binding power table!" },
        ) catch std.os.exit(10);
        return binding_power.err;
    }
    return bp_table.get(tk).?;
}

pub fn nud_handler(parser: *psr.Parser, tk: token.TokenType) ast.Expr {
    var nud_lookup = blk: {
        var map = std.EnumMap(
            token.TokenType,
            *const fn (*psr.Parser) ast.Expr,
        ){};

        // Literals
        map.put(token.TokenType.Num, expr.parse_num);
        map.put(token.TokenType.String, expr.parse_string);
        map.put(token.TokenType.Ident, expr.parse_ident);

        // Unary
        map.put(token.TokenType.not, expr.parse_unary);
        map.put(token.TokenType.minus, expr.parse_unary);

        break :blk map;
    };
    var current = psr.current(parser);
    if (nud_lookup.get(tk) == null) {
        parser.errors.append(
            psr.Parser.Error{ ._tks = current, .msg = "TokenType not found in nud table!" },
        ) catch std.os.exit(10);
        return ast.Expr{ .Err = ast.ExprKind.Err };
    }
    return nud_lookup.get(tk).?(parser);
}

pub fn led_handler(parser: *psr.Parser, left: *ast.Expr) ast.Expr {
    var led_lookup = blk: {
        var map = std.EnumMap(token.TokenType, *const fn (
            *psr.Parser,
            *ast.Expr,
            []const u8,
            *binding_power,
        ) ast.Expr){};

        // Binary
        map.put(token.TokenType.plus, expr.parse_binary);
        map.put(token.TokenType.minus, expr.parse_binary);
        map.put(token.TokenType.star, expr.parse_binary);
        map.put(token.TokenType.slash, expr.parse_binary);
        map.put(token.TokenType.mod, expr.parse_binary);

        break :blk map;
    };

    var op = psr.current(parser);
    var value = get_binding_power(parser, psr.current(parser).type);

    if (led_lookup.get(op.type) == null) {
        parser.errors.append(
            psr.Parser.Error{ ._tks = op, .msg = "TokenType not found in led table!" },
        ) catch std.os.exit(10);
        return ast.Expr{ .Err = ast.ExprKind.Err };
    }

    if (parser.index + 1 < parser.tks.items.len)
        _ = psr.next(parser);

    return led_lookup.get(op.type).?(parser, &left.*, op.value, &value);
}
