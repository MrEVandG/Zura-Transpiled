const std = @import("std");

const token = @import("../lexer/tokens.zig");
const pError = @import("../helper/error.zig");
const parser = @import("helper.zig");
const ast = @import("../ast/ast.zig");

pub const bp = enum {
    defalt,
    comma,
    assignment,
    logical,
    relational,
    additive,
    multiplicative,
    unary,
    call,
    member,
    primary,
};

pub const Prec = struct {
    bp: bp,
    led: *const fn (left: ast.Expr) ast.Expr,
    nud: *const fn () ast.Expr,
};

pub var pr: Prec = undefined;
pub var bP: bp = bp.defalt;

const nud_map = blk: {
    var map = std.enums.EnumMap(token.TokenType, Prec){};

    map.put(token.TokenType.Num, Prec{ .bp = .primary, .nud = parser.parsePrimary, .led = undefined });
    map.put(token.TokenType.Ident, Prec{ .bp = .primary, .nud = parser.parsePrimary, .led = undefined });
    map.put(token.TokenType.String, Prec{ .bp = .primary, .nud = parser.parsePrimary, .led = undefined });

    break :blk map;
};

const led_map = blk: {
    var map = std.enums.EnumMap(token.TokenType, Prec){};

    // additive && multiplicative
    map.put(token.TokenType.plus, Prec{ .bp = .additive, .led = parser.parseBinary, .nud = undefined });
    map.put(token.TokenType.minus, Prec{ .bp = .additive, .led = parser.parseBinary, .nud = undefined });
    map.put(token.TokenType.star, Prec{ .bp = .multiplicative, .led = parser.parseBinary, .nud = undefined });
    map.put(token.TokenType.slash, Prec{ .bp = .multiplicative, .led = parser.parseBinary, .nud = undefined });

    break :blk map;
};

pub fn nud_lookup(tk: token.TokenType) ?Prec {
    const prec = nud_map.get(tk);
    if (prec == null) {
        _ = pError.Error(
            token.token.line,
            token.token.pos,
            "NUD not found!",
            "PRECEDENCE ERROR",
            token.scanner.filename,
        ) orelse std.debug.panic("NUD not found!");
    }
    return prec.?;
}

pub fn led_lookup(tk: token.TokenType, left: ast.Expr) ?Prec {
    _ = left;
    const prec = led_map.get(tk);
    if (prec == null) {
        _ = pError.Error(
            token.token.line,
            token.token.pos,
            "LED not found!",
            "PRECEDENCE ERROR",
            token.scanner.filename,
        ) orelse std.debug.panic("LED not found!");
    }
    return prec.?;
}

pub fn bp_lookup(tk: token.TokenType) ?Prec {
    const nud_prec = nud_map.get(tk);
    if (nud_prec != null) {
        return nud_prec.?;
    }

    const led_prec = led_map.get(tk);
    if (led_prec != null) {
        return led_prec.?;
    }

    _ = pError.Error(
        token.token.line,
        token.token.pos,
        "BP not found!",
        "PRECEDENCE ERROR",
        token.scanner.filename,
    ) orelse std.debug.panic("BP not found!");
}
