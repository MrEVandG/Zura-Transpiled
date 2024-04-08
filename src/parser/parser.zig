const std = @import("std");

const token = @import("../lexer/tokens.zig");
const lexer = @import("../lexer/lexer.zig");
const ast = @import("../ast/ast.zig");
const prec = @import("prec.zig");
const h = @import("helper.zig");

pub fn storeToken(parser: *h.Parser, tk: token.Token) !void {
    _ = try lexer.scanToken(); // get ride if the start token
    while (token.token.type != token.TokenType.Eof) {
        try parser.tks.append(tk);
        _ = try lexer.scanToken();
    }
}

pub fn parse(allocator: std.mem.Allocator) !void {
    var parser = h.Parser.init(allocator);
    defer parser.deinit();

    try storeToken(&parser, token.token);

    var res = h.parse_expr(&parser, prec.binding_power.default);
    _ = res;
}
