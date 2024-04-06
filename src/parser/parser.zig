const std = @import("std");

const token = @import("../lexer/tokens.zig");
const scan = @import("../lexer/lexer.zig").scanToken;
const pError = @import("../helper/error.zig");
const helper = @import("helper.zig");
const prec = @import("prec.zig");

pub const Parser = struct {
    allocator: std.mem.Allocator,
    tks: std.ArrayList(token.Token),
    index: usize,
};

fn init_parser(allocator: std.mem.Allocator) Parser {
    return Parser{
        .allocator = allocator,
        .tks = std.ArrayList(token.Token).init(allocator),
        .index = 0,
    };
}

fn storeToken(parser: *Parser, tk: token.Token) !void {
    _ = try scan(); // get ride if the start token
    while (token.token.type != token.TokenType.Eof) {
        try parser.tks.append(tk);
        _ = try scan();
    }
}

fn current(parser: *Parser) token.Token {
    return parser.tks.items[parser.index];
}

fn next(parser: *Parser) token.Token {
    parser.index += 1;
    return parser.tks.items[parser.index];
}

pub fn parse(allocator: std.mem.Allocator) !void {
    var parser = init_parser(allocator);

    try storeToken(&parser, token.token);

    while (parser.index < parser.tks.items.len) {
        std.debug.print("{s}", .{current(&parser).value});
        if (parser.index + 1 < parser.tks.items.len) {
            _ = next(&parser);
        } else {
            break;
        }
    }
}
