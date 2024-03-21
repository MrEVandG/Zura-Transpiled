const std = @import("std");

const prec = @import("prec.zig");
const token = @import("../lexer/tokens.zig");
const pError = @import("../helper/error.zig");
const lexer = @import("../lexer/lexer.zig");

pub fn expr(pc: prec.Prec) void {
    var left = prefix().?;

    while (true) {
        var nextPrec = prec.getPrec();
        if (nextPrec.level < pc.level or (nextPrec.level == pc.level and pc.associativity == .lft)) {
            break;
        }
        left = infix(left).?;
    }
}

fn prefix() ?token.TokenType {
    switch (token.token.type) {
        .Num => number(),
        .lParen => group(),
        .minus, .not => unary(),
        else => {
            std.debug.print("Token not found\n", .{});
            std.os.exit(1);
        },
    }
    return token.token.type;
}

fn infix(left: token.TokenType) ?token.TokenType {
    var right = token.TokenType.Start;
    switch (left) {
        .plus, .minus, .star, .slash => {
            binary();
        },
        else => {
            std.debug.print("Token not found\n", .{});
            std.os.exit(1);
        },
    }
    return right;
}

fn binary() void {
    std.debug.print("Binary: {s}\n", .{token.token.lexem});
    _ = lexer.scanToken() catch std.debug.print("Error scanning next token\n", .{});
    expr(prec.Prec{ .level = 2, .associativity = .lft });
}

fn number() void {
    std.debug.print("Number: {s}\n", .{token.token.lexem});
    _ = lexer.scanToken() catch std.debug.print("Error scanning next token\n", .{});
}

fn group() void {
    _ = lexer.scanToken() catch std.debug.print("Error scanning next token\n", .{});
    std.debug.print("Grouping\n", .{});

    expr(prec.Prec{ .level = 1, .associativity = .rgt });

    if (token.token.type != token.TokenType.rParen) {
        std.debug.print("Expected ')' after expression\n", .{});
        std.os.exit(1);
    }

    _ = lexer.scanToken() catch std.debug.print("Error scanning next token\n", .{});
    std.debug.print("Grouping\n", .{});
}

fn unary() void {
    std.debug.print("Unary: {s}\n", .{token.token.lexem});
    _ = lexer.scanToken() catch std.debug.print("Error scanning next token\n", .{});
    expr(prec.Prec{ .level = 3, .associativity = .rgt });

    switch (token.token.type) {
        .minus => std.debug.print("Negation\n", .{}),
        .not => std.debug.print("Not\n", .{}),
        else => {
            std.debug.print("Token not found\n", .{});
            std.os.exit(1);
        },
    }
}
