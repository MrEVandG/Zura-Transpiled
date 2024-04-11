const std = @import("std");
const token = @import("../lexer/tokens.zig");
const err = @import("../helper/error.zig");
const ast = @import("../ast/ast.zig");
const prec = @import("prec.zig");

pub const Parser = struct {
    tks: std.ArrayList(token.Token),
    idx: usize,

    errors: std.ArrayList(Error),
    pub const Error = struct {
        msg: []const u8,
        tokens: token.Token,
    };

    pub fn init(alloc: std.mem.Allocator) Parser {
        return Parser{
            .tks = std.ArrayList(token.Token).init(alloc),
            .errors = std.ArrayList(Error).init(alloc),
            .idx = 0,
        };
    }

    pub fn deinit(self: Parser) void {
        self.errors.deinit();
        self.tks.deinit();
    }
};

pub fn pushError(psr: *Parser, msg: []const u8) void {
    psr.errors.append(Parser.Error{ .msg = msg, .tokens = current(psr) }) catch {
        std.debug.panic("Failed to push error to the error array", .{});
    };
}

pub fn reportErrors(psr: *Parser, bp: prec.bindingPower) void {
    if (psr.errors.items.len > 0 or bp == prec.bindingPower.err) {
        for (psr.errors.items) |e| {
            err.Error(
                e.tokens.line,
                e.tokens.pos - 1,
                e.msg,
                "PARSER LOOKUP ERROR",
                token.scanner.filename,
            ) catch {
                std.debug.panic("Failed to report error", .{});
            };
        }

        if (psr.errors.items.len >= 5) {
            std.debug.print("Too many errors!\n", .{});
            std.os.exit(1);
        }
    }
}

pub fn current(psr: *Parser) token.Token {
    return psr.tks.items[psr.idx];
}

pub fn advance(psr: *Parser) token.Token {
    psr.idx += 1;
    return current(psr);
}

pub fn expect(psr: *Parser, tk: token.TokenType) token.Token {
    var c_tok = current(psr);
    if (c_tok.type != tk) {
        pushError(psr, "Expected token");
    }

    return advance(psr);
}

pub fn parseExpr(alloc: std.mem.Allocator, parser: *Parser, bp: prec.bindingPower) !*ast.Expr {
    var c_tok = current(parser);
    var left = try prec.nudHandler(alloc, parser, c_tok);

    reportErrors(parser, bp);

    if (parser.idx + 1 < parser.tks.items.len) {
        c_tok = advance(parser);
    } else {
        return left;
    }

    while (@intFromEnum(prec.getBP(parser, c_tok)) > @intFromEnum(bp)) {
        left = try prec.ledHandler(alloc, parser, left);
        reportErrors(parser, bp);
        c_tok = current(parser);
    }

    return left;
}
