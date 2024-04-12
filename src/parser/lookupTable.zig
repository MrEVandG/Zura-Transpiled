const std = @import("std");

const token = @import("../lexer/tokens.zig");
const ast = @import("../ast/ast.zig");
const psr = @import("helper.zig");
const prec = @import("prec.zig");
const expr = @import("expr.zig");

/// The bp_table is a table of binding powers for each token type.
/// This is used in parse expr to determine the precedence of the current token.
pub var bp_table = blk: {
    var map = std.EnumMap(token.TokenType, prec.bindingPower){};

    // Literals
    map.put(token.TokenType.Num, .default);
    map.put(token.TokenType.Float, .default);
    map.put(token.TokenType.String, .default);
    map.put(token.TokenType.Ident, .default);

    // Parentheses
    map.put(token.TokenType.lParen, .call);

    // Operators
    map.put(token.TokenType.plus, .additive);
    map.put(token.TokenType.minus, .additive);
    map.put(token.TokenType.star, .multiplicative);
    map.put(token.TokenType.slash, .multiplicative);
    map.put(token.TokenType.caret, .power);

    // Comparison
    map.put(token.TokenType.lt, .comparison);
    map.put(token.TokenType.gt, .comparison);
    map.put(token.TokenType.eEqual, .comparison);
    map.put(token.TokenType.nEqual, .comparison);
    map.put(token.TokenType.ltEqual, .comparison);
    map.put(token.TokenType.gtEqual, .comparison);

    // Unary
    map.put(token.TokenType.not, .prefix);

    break :blk map;
};

/// The prefix_table is a table of prefix operators. Example "!" or "-".
pub var prefix_table = blk: {
    var map = std.EnumMap(token.TokenType, prec.bindingPower){};

    // Prefix operators
    map.put(token.TokenType.not, .prefix);
    map.put(token.TokenType.minus, .prefix);

    break :blk map;
};

/// The nud table is called at the start of parsing when we just have
/// a token that has no left hand side. This is used to parse literals
/// and prefix operators. This map specifically maps token types to
/// there respective functions so we have a nice clean way to parse them.
pub var nud_table = blk: {
    var map = std.EnumMap(
        token.TokenType,
        *const fn (*psr.Parser, std.mem.Allocator) error{OutOfMemory}!*ast.Expr,
    ){};

    // Literals
    map.put(token.TokenType.Num, expr.num);
    map.put(token.TokenType.Float, expr.float);
    map.put(token.TokenType.String, expr.string);
    map.put(token.TokenType.Ident, expr.ident);

    // Parentheses
    map.put(token.TokenType.lParen, expr.group);

    // Prefix operators
    map.put(token.TokenType.minus, expr.unary);
    map.put(token.TokenType.not, expr.unary);

    break :blk map;
};

/// The led table is called when we have a token that has a left hand side.
/// This is used to parse binary operators and other infix operators.
/// This map specifically maps token types to a function that takes in the bp of the
/// current token and the left hand side of the token. This is used to parse the right
/// and return to an ast node.
pub var led_table = blk: {
    var map = std.EnumMap(
        token.TokenType,
        *const fn (*psr.Parser, *ast.Expr, []const u8, prec.bindingPower, std.mem.Allocator) error{OutOfMemory}!*ast.Expr,
    ){};

    // Binary operators
    map.put(token.TokenType.plus, expr.binary);
    map.put(token.TokenType.minus, expr.binary);
    map.put(token.TokenType.star, expr.binary);
    map.put(token.TokenType.slash, expr.binary);
    map.put(token.TokenType.caret, expr.binary);

    // Comparison
    map.put(token.TokenType.lt, expr.binary);
    map.put(token.TokenType.gt, expr.binary);
    map.put(token.TokenType.eEqual, expr.binary);
    map.put(token.TokenType.nEqual, expr.binary);
    map.put(token.TokenType.ltEqual, expr.binary);
    map.put(token.TokenType.gtEqual, expr.binary);

    break :blk map;
};
