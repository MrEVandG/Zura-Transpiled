const std = @import("std");

const prec = @import("prec.zig");
const token = @import("../lexer/tokens.zig");
const lexer = @import("../lexer/lexer.zig");

const Parser = struct {
    allocator: std.mem.Allocator,
    tks: std.ArrayList(token.Token),
    index: usize,
};

pub fn init_parser(allocator: std.mem.Allocator) Parser {
    return Parser{
        .allocator = allocator,
        .tks = std.ArrayList(token.Token).init(allocator),
        .index = 0,
    };
}

pub fn storeToken(parser: *Parser, tk: token.Token) !void {
    _ = try lexer.scanToken(); // get ride if the start token
    while (token.token.type != token.TokenType.Eof) {
        try parser.tks.append(tk);
        _ = try lexer.scanToken();
    }
}

pub fn current(parser: *Parser) token.Token {
    return parser.tks.items[parser.index];
}

pub fn next(parser: *Parser) token.Token {
    parser.index += 1;
    return parser.tks.items[parser.index];
}
