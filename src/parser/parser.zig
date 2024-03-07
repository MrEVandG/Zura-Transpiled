const tokens = @import("../lexer/lexer.zig");
const perror = @import("../helper/error.zig").pError;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const std = @import("std");

pub const Precedence = struct {
    level: u8,
    associativity: enum { Left, Right },
};

pub const precedenceMap = blk: {
    var precMap = std.enums.EnumMap(TokenType, Precedence){};
    precMap.put(TokenType.plus, Precedence{ .level = 1, .associativity = .Left });
    precMap.put(TokenType.star, Precedence{ .level = 2, .associativity = .Left });
    precMap.put(TokenType.slash, Precedence{ .level = 2, .associativity = .Left });
    // Unary operators
    precMap.put(TokenType.minus, Precedence{ .level = 3, .associativity = .Right });
    precMap.put(TokenType.not, Precedence{ .level = 3, .associativity = .Right });
    break :blk precMap;
};

pub fn parse() void {
    _ = tokens.scanTokens();
    while (tokens.token.type != TokenType.Eof) {
        expression(Precedence{ .level = 0, .associativity = .Left });
    }
}

fn expression(prec: Precedence) void {
    var _prefix = prefix();
    while (prec.level < getPrecedence().level) {
        infix(_prefix);
    }
}

fn prefix() void {
    switch (tokens.token.type) {
        TokenType.Number => number(),
        TokenType.lParen => grouping(),
        TokenType.minus, TokenType.not => unary(),
        else => {
            perror(tokens.token.line, tokens.token.pos, "Token not recognized!");
            std.process.exit(1);
        },
    }
}

fn infix(left: void) void {
    var operator = tokens.token.type;
    _ = tokens.scanTokens();
    var right = prefix();
    switch (operator) {
        TokenType.plus => plus(left, right, operator),
        TokenType.minus => minus(left, right, operator),
        TokenType.star => star(left, right, operator),
        TokenType.slash => slash(left, right, operator),
        else => {
            perror(tokens.token.line, tokens.token.pos, "Token not recognized!");
            std.process.exit(1);
        },
    }
}

fn plus(left: void, right: void, operator: TokenType) void {
    _ = operator;
    std.debug.print("Plus: {any} + {any}\n", .{ left, right });
}

fn minus(left: void, right: void, operator: TokenType) void {
    _ = operator;
    std.debug.print("Minus: {} - {}\n", .{ left, right });
}

fn star(left: void, right: void, operator: TokenType) void {
    _ = operator;
    std.debug.print("Star: {} * {}\n", .{ left, right });
}

fn slash(left: void, right: void, operator: TokenType) void {
    _ = operator;
    std.debug.print("Slash: {} / {}\n", .{ left, right });
}

fn number() void {
    std.debug.print("Number: {}\n", .{TokenType.Number});
    _ = tokens.scanTokens();
}

fn unary() void {
    var operator = tokens.token.type;
    _ = tokens.scanTokens();
    expression(Precedence{ .level = 3, .associativity = .Right });
    switch (operator) {
        TokenType.minus => std.debug.print("Unary minus\n", .{}),
        TokenType.not => std.debug.print("Unary not\n", .{}),
        else => {
            perror(tokens.token.line, tokens.token.pos, "Token not recognized!");
            std.process.exit(1);
        },
    }
}

fn grouping() void {
    _ = tokens.scanTokens();
    expression(Precedence{ .level = 0, .associativity = .Left });
    if (tokens.token.type != TokenType.rParen) {
        perror(tokens.token.line, tokens.token.pos, "Expected ')'");
        std.process.exit(1);
    }
    _ = tokens.scanTokens();

    std.debug.print("Grouping\n", .{});
}

fn getPrecedence() Precedence {
    if (tokens.token.type == TokenType.Eof)
        return Precedence{ .level = 0, .associativity = .Left };

    return precedenceMap.get(tokens.token.type).?;
}
