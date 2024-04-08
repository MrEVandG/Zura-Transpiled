const std = @import("std");

const prec = @import("prec.zig");
const ast = @import("../ast/ast.zig");
const token = @import("../lexer/tokens.zig");
const lexer = @import("../lexer/lexer.zig");
const err = @import("../helper/error.zig");

pub const Parser = struct {
    tks: std.ArrayList(token.Token),
    index: usize,

    errors: std.ArrayList(Error),
    pub const Error = struct {
        _tks: token.Token,
        msg: []const u8,
    };

    pub fn init(allocator: std.mem.Allocator) Parser {
        return Parser{
            .tks = std.ArrayList(token.Token).init(allocator),
            .errors = std.ArrayList(Error).init(allocator),
            .index = 0,
        };
    }

    pub fn deinit(self: Parser) void {
        self.tks.deinit();
        self.errors.deinit();
    }
};

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

    if (parser.errors.items.len > 0) {
        for (parser.errors.items) |_err| {
            var msg = _err.msg;
            err.Error(
                _err._tks.line,
                _err._tks.pos,
                msg,
                "PARSER LOOKUP ERROR",
                token.scanner.filename,
            ) catch unreachable;
        }
        return left;
    }

    if (parser.index + 1 < parser.tks.items.len) {
        c_tok = next(parser);
    } else {
        return left;
    }

    var value = @intFromEnum(prec.get_binding_power(parser, c_tok.type));
    while (value > @intFromEnum(bp)) {
        left = prec.led_handler(parser, &left);
        c_tok = current(parser);
        value = @intFromEnum(prec.get_binding_power(parser, c_tok.type));
    }

    return left;
}
