const std = @import("std");

const token = @import("../lexer/tokens.zig");
const pError = @import("../helper/error.zig");

pub const Prec = struct {
    level: u8,
    associativity: enum { lft, rgt },
};

const precMap = blk: {
    var map = std.enums.EnumMap(token.TokenType, Prec){};

    // EOF
    map.put(token.TokenType.Eof, Prec{ .level = 0, .associativity = .lft });

    // Delimiters
    map.put(token.TokenType.lParen, Prec{ .level = 0, .associativity = .lft });
    map.put(token.TokenType.rParen, Prec{ .level = 0, .associativity = .lft });
    map.put(token.TokenType.semicolon, Prec{ .level = 0, .associativity = .lft });

    // Binary -- NOTE: Add in mod '%' and carot '^'
    map.put(token.TokenType.plus, Prec{ .level = 1, .associativity = .lft });
    map.put(token.TokenType.minus, Prec{ .level = 1, .associativity = .lft });
    map.put(token.TokenType.star, Prec{ .level = 2, .associativity = .lft });
    map.put(token.TokenType.slash, Prec{ .level = 2, .associativity = .lft });

    // Unary
    map.put(token.TokenType.minus, Prec{ .level = 3, .associativity = .rgt });
    map.put(token.TokenType.not, Prec{ .level = 3, .associativity = .rgt });

    break :blk map;
};

pub fn getPrec() Prec {
    if (precMap.get(token.token.type) == null) {
        std.debug.print("Error: No precedence found for token: {any}\n", .{token.token.type});
        std.os.exit(0);
    }
    return precMap.get(token.token.type).?;
}
