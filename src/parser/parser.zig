const std = @import("std");

const token = @import("../lexer/tokens.zig");
const lexer = @import("../lexer/lexer.zig");
const ast = @import("../ast/ast.zig");
const prec = @import("prec.zig");
const h = @import("helper.zig");

fn storeToken(parser: *h.Parser, tk: token.Token) !void {
    _ = try lexer.scanToken();
    while (token.token.type != token.TokenType.Eof) {
        try parser.tks.append(tk);
        _ = try lexer.scanToken();
    }
}

pub fn parse(alloc: std.mem.Allocator) !void {
    var parser = h.Parser.init(alloc);
    defer parser.deinit();

    try storeToken(&parser, token.token);

    var res = try h.parseExpr(alloc, &parser, prec.bindingPower.default);
    std.debug.print("Result: {}\n", .{res});
    res.deinit(alloc);
}
