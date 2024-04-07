const std = @import("std");

const prec = @import("prec.zig");
const ast = @import("../ast/ast.zig");
const token = @import("../lexer/tokens.zig");
const lexer = @import("../lexer/lexer.zig");

pub const Parser = struct {
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

pub fn current(parser: *Parser) token.Token {
    return parser.tks.items[parser.index];
}

pub fn next(parser: *Parser) token.Token {
    parser.index += 1;
    return parser.tks.items[parser.index];
}

pub fn prev(parser: *Parser) token.Token {
    parser.index -= 1;
    return parser.tks.items[parser.index];
}

pub fn parse_expr(parser: *Parser, bp: prec.binding_power) ast.Expr {
    var c_tok = current(parser);
    var left = prec.nud_handler(parser, c_tok.type);

    // advance to the next token
    if (parser.index + 1 < parser.tks.items.len) {
        std.debug.print("next token: {any}\n", .{parser.tks.items[parser.index + 1].type});
        _ = next(parser);
    }

    var value = @intFromEnum(prec.get_binding_power(current(parser).type));
    while (value > @intFromEnum(bp)) {
        left = prec.led_handler(parser, &left);
    }

    return left;
}
