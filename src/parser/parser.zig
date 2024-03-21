const std = @import("std");

const token = @import("../lexer/tokens.zig");
const scan = @import("../lexer/lexer.zig").scanToken;
const pError = @import("../helper/error.zig");
const helper = @import("helper.zig");
const prec = @import("prec.zig");

pub fn parse() !void {
    _ = try scan();
    while (token.token.type != token.TokenType.Eof) {
        helper.expr(prec.Prec{ .level = 0, .associativity = .lft });
    }
}
