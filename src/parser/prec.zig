const std = @import("std");

const token = @import("../lexer/tokens.zig");
const err = @import("../helper/error.zig");
const lu = @import("lookupTable.zig");
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

pub fn getBP(parser: *psr.Parser, tk: token.Token) bindingPower {
    if (lu.bp_table.get(tk.type) == null) {
        psr.pushError(parser, "Current Token not find in bp table!");
        return bindingPower.err;
    }
    return lu.bp_table.get(tk.type).?;
}

pub fn getUnary(parser: *psr.Parser, tk: token.Token) bindingPower {
    if (lu.prefix_table.get(tk.type) == null) {
        psr.pushError(parser, "Current Token not find in unary table!");
        return bindingPower.err;
    }
    return lu.prefix_table.get(tk.type).?;
}

pub fn nudHandler(alloc: std.mem.Allocator, parser: *psr.Parser, tk: token.Token) !*ast.Expr {
    if (lu.nud_table.get(tk.type) == null) {
        psr.pushError(parser, "Current Token not find in nud table!");

        const _expr = try alloc.create(ast.Expr);
        _expr.* = .{ .Error = "Current Token not find in nud table!" };
        return _expr;
    }
    return lu.nud_table.get(tk.type).?(parser, alloc);
}

pub fn ledHandler(alloc: std.mem.Allocator, parser: *psr.Parser, left: *ast.Expr) !*ast.Expr {
    var op = psr.current(parser);

    if (lu.led_table.get(op.type) == null) {
        psr.pushError(parser, "Current Token not find in led table!");

        const _expr = try alloc.create(ast.Expr);
        _expr.* = .{ .Error = "Current Token not find in led table!" };
        return _expr;
    }

    var bp = getBP(parser, op);

    if (parser.idx + 1 < parser.tks.items.len)
        _ = psr.advance(parser);

    return lu.led_table.get(op.type).?(parser, left, op.value, bp, alloc);
}
