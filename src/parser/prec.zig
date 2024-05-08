const std = @import("std");

const token = @import("../lexer/tokens.zig");
const err = @import("../helper/error.zig");
const lu = @import("lookupTable.zig");

const expr = @import("../ast/expr.zig");
const stmt = @import("../ast/stmt.zig");

const psr = @import("helper.zig");

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
pub fn nudHandler(alloc: std.mem.Allocator, parser: *psr.Parser, tk: token.Token) !*expr.Expr {
    if (lu.nud_table.get(tk.type) == null)
        return psr.createError(parser, alloc, "Current Token not find in nud table!");
    return lu.nud_table.get(tk.type).?(parser, alloc);
}

/// When writing a Pratt parser you will run into this term called "led" which stands for
/// "left denotation". This is the function that is called when the token is not the first token
/// in the expression. This function is responsible for parsing the token and returning an
/// expression. If the token is not found in the lookup table, it will return an error.
/// An example of this is when you have a binary operator like "+" in the expression "1 + 1".
pub fn ledHandler(alloc: std.mem.Allocator, parser: *psr.Parser, left: *expr.Expr) !*expr.Expr {
    const op = psr.current(parser);

    if (lu.led_table.get(op.type) == null)
        return psr.createError(parser, alloc, "Current Token not find in led table!");

    const bp = getBP(parser, op);

    _ = psr.advance(parser);

    return lu.led_table.get(op.type).?(parser, left, op.value, bp, alloc);
}

/// This is the handler for the "stmt" lookup table.
pub fn stmtHandler(alloc: std.mem.Allocator, parser: *psr.Parser) !*stmt.Stmt {
    if (lu.stmt_table.get(psr.current(parser).type) == null) {
        std.debug.panic("Current token not found in STMT lookup!", .{});
        std.process.exit(1);
    }

    return lu.stmt_table.get(psr.current(parser).type).?(parser, alloc);
}
