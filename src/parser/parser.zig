const tokens = @import("../lexer/lexer.zig");
const perror = @import("../helper/error.zig").pError;
const TokenType = @import("../lexer/tokens.zig").TokenType;
const AstNode = @import("../ast/ast.zig");
const std = @import("std");

pub const Precedence = struct {
    level: u8,
    associativity: enum { Left, Right },
};

pub const precedenceMap = blk: {
    var precMap = std.enums.EnumMap(TokenType, Precedence){};

    // Delimiters
    precMap.put(TokenType.lParen, Precedence{ .level = 0, .associativity = .Left });
    precMap.put(TokenType.rParen, Precedence{ .level = 0, .associativity = .Left });
    precMap.put(TokenType.Eof, Precedence{ .level = 0, .associativity = .Left });

    // Comparison operators
    precMap.put(TokenType.equalEqual, Precedence{ .level = 1, .associativity = .Left });
    precMap.put(TokenType.less, Precedence{ .level = 1, .associativity = .Left });
    precMap.put(TokenType.greater, Precedence{ .level = 1, .associativity = .Left });
    precMap.put(TokenType.lessEqual, Precedence{ .level = 1, .associativity = .Left });
    precMap.put(TokenType.greaterEqual, Precedence{ .level = 1, .associativity = .Left });

    // Binary operators
    precMap.put(TokenType.plus, Precedence{ .level = 1, .associativity = .Left });
    precMap.put(TokenType.minus, Precedence{ .level = 1, .associativity = .Left });
    precMap.put(TokenType.star, Precedence{ .level = 2, .associativity = .Left });
    precMap.put(TokenType.slash, Precedence{ .level = 2, .associativity = .Left });
    precMap.put(TokenType.mod, Precedence{ .level = 2, .associativity = .Left });
    precMap.put(TokenType.caret, Precedence{ .level = 3, .associativity = .Right });

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
    var left = TokenType.Start;
    // NUD: try parsing primary expressions
    if (tokens.token.type == TokenType.Number or tokens.token.type == TokenType.lParen or
        tokens.token.type == TokenType.minus or tokens.token.type == TokenType.not)
    {
        left = prefix().?;
    } else {
        perror(tokens.token.line, tokens.token.pos, "Expected an expression!");
        std.process.exit(1);
    }

    // LED: try parsing the infix by the precedence level
    while (prec.level < getPrecedence().level) {
        left = infix(left).?;
    }
}

fn prefix() ?TokenType {
    switch (tokens.token.type) {
        TokenType.Number => number(),
        TokenType.lParen => grouping(),
        TokenType.minus, TokenType.not => unary(),
        else => {
            perror(tokens.token.line, tokens.token.pos, "Token not recognized!");
            std.process.exit(1);
        },
    }

    return tokens.token.type;
}

fn infix(left: ?TokenType) ?TokenType {
    var operator = tokens.token.type;
    var prec = getPrecedence();
    _ = tokens.scanTokens();

    // Ensure the next token is the right operand
    if (tokens.token.type != TokenType.Number and tokens.token.type != TokenType.lParen) {
        perror(tokens.token.line, tokens.token.pos, "Expected an operand!");
        std.process.exit(1);
    }

    expression(prec);

    var right = tokens.token.type;

    switch (operator) {
        TokenType.plus => plus(left.?, right, operator),
        TokenType.minus => minus(left.?, right, operator),
        TokenType.star => star(left.?, right, operator),
        TokenType.slash => slash(left.?, right, operator),
        TokenType.caret => caret(left.?, right, operator),
        else => {
            perror(tokens.token.line, tokens.token.pos, "Token not recognized!");
            std.process.exit(1);
        },
    }

    return tokens.token.type;
}

fn plus(left: TokenType, right: TokenType, operator: TokenType) void {
    _ = operator;
    std.debug.print("Plus: {any} + {any}\n", .{ left, right });
}

fn minus(left: TokenType, right: TokenType, operator: TokenType) void {
    _ = operator;
    std.debug.print("Minus: {any} - {any}\n", .{ left, right });
}

fn star(left: TokenType, right: TokenType, operator: TokenType) void {
    _ = operator;
    std.debug.print("Star: {} * {}\n", .{ left, right });
}

fn slash(left: TokenType, right: TokenType, operator: TokenType) void {
    _ = operator;
    std.debug.print("Slash: {} / {}\n", .{ left, right });
}

fn caret(left: TokenType, right: TokenType, operator: TokenType) void {
    _ = operator;
    std.debug.print("Caret: {} ^ {}\n", .{ left, right });
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
        perror(tokens.token.line, tokens.token.pos, "Expected ')' after expression!");
        std.process.exit(1);
    }

    _ = tokens.scanTokens();
    std.debug.print("Grouping\n", .{});
}

fn getPrecedence() Precedence {
    if (precedenceMap.get(tokens.token.type) == null) {
        perror(tokens.token.line, tokens.token.pos, "Token not recognized!");
        std.process.exit(1);
    }

    return precedenceMap.get(tokens.token.type).?;
}
