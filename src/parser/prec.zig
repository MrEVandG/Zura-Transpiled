const std = @import("std");

const token = @import("../lexer/tokens.zig");
const err = @import("../helper/error.zig");
const lu = @import("lookupTable.zig");
const ast = @import("../ast/ast.zig");
const psr = @import("helper.zig");
const expr = @import("expr.zig");

/// The Zura bp table (binding power table) is based off of C's prec table
/// but in reverse. The higher the number, the higher the precedence.
/// https://en.cppreference.com/w/c/language/operator_precedence
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

//TODO: Have a better way to handle errors in the nud and led functions. Also have a better way to check for null values.

/// The getBp function looks at the bt table map, which is a map of token types and their
/// respective binding powers. If the token type is not found in the map, it will return an error.
/// if we do find the token type, we return the binding power. For the parser to use when parsing.
pub fn getBP(parser: *psr.Parser, tk: token.Token) bindingPower {
    if (lu.bp_table.get(tk.type) == null) {
        psr.pushError(parser, "Current Token not find in bp table!");
        return bindingPower.err;
    }
    return lu.bp_table.get(tk.type).?;
}

/// When writing a Pratt parser you will run into this term called "nud" which stands for
/// "null denotation". This is the function that is called when the token is the first token
/// in the expression. This function is responsible for parsing the token and returning an
/// expression. If the token is not found in the lookup table, it will return an error.
/// An example of this is when you have a unary operator like "-" in the expression "-1".
pub fn nudHandler(alloc: std.mem.Allocator, parser: *psr.Parser, tk: token.Token) !*ast.Expr {
    return lu.nud_table.get(tk.type).?(parser, alloc) catch {
        psr.pushError(parser, "Current Token not find in nud table!");
        const _expr = try alloc.create(ast.Expr);
        _expr.* = .{ .Error = "Current Token not find in nud table!" };
        return _expr;
    };
}

/// When writing a Pratt parser you will run into this term called "led" which stands for
/// "left denotation". This is the function that is called when the token is not the first token
/// in the expression. This function is responsible for parsing the token and returning an
/// expression. If the token is not found in the lookup table, it will return an error.
/// An example of this is when you have a binary operator like "+" in the expression "1 + 1".
pub fn ledHandler(alloc: std.mem.Allocator, parser: *psr.Parser, left: *ast.Expr) !*ast.Expr {
    var op = psr.current(parser);

    var bp = getBP(parser, op);

    _ = psr.advance(parser);

    return lu.led_table.get(op.type).?(parser, left, op.value, bp, alloc) catch {
        psr.pushError(parser, "Current Token not find in led table!");
        const _expr = try alloc.create(ast.Expr);
        _expr.* = .{ .Error = "Current Token not find in led table!" };
        return _expr;
    };
}
