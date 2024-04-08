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

pub fn errorCheck(parser: *Parser, msg: []const u8) void {
    parser.errors.append(
        Parser.Error{ .msg = msg, ._tks = current(parser) },
    ) catch |_err| {
        std.debug.print("Error: {}\n", .{_err});
    };
}

fn reportError(parser: *Parser, bp: prec.binding_power) void {
    if (parser.errors.items.len > 0 or bp == prec.binding_power.err) {
        for (parser.errors.items) |_err| {
            var msg = _err.msg;
            err.Error(
                _err._tks.line,
                _err._tks.pos - 1,
                msg,
                "PARSER LOOKUP ERROR",
                token.scanner.filename,
            ) catch unreachable;
        }
    }
    if (parser.errors.items.len >= 5) {
        std.debug.print("Too many errors, exiting...\n", .{});
        std.os.exit(1);
    }
}

pub fn parse_expr(parser: *Parser, bp: prec.binding_power) ast.Expr {
    var c_tok = current(parser);
    var left = prec.nud_handler(parser, c_tok.type);

    // Check for error in the nud_handler
    reportError(parser, bp);

    if (parser.index + 1 < parser.tks.items.len) {
        c_tok = next(parser);
    } else {
        return left;
    }

    var new_bp = @intFromEnum(prec.get_binding_power(parser, c_tok.type));
    while (new_bp > @intFromEnum(bp)) {
        left = prec.led_handler(parser, &left);
        reportError(parser, @enumFromInt(new_bp)); // Check for error in the led_handler
        c_tok = current(parser);
        new_bp = @intFromEnum(prec.get_binding_power(parser, c_tok.type));
    }

    return left;
}
