const std = @import("std");
const token = @import("../lexer/tokens.zig");
const err = @import("../helper/error.zig");
const ast = @import("../ast/expr.zig");
const stmt = @import("../ast/stmt.zig");
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

pub fn createError(psr: *Parser, alloc: std.mem.Allocator, msg: []const u8) !*ast.Expr {
    const expr = try alloc.create(ast.Expr);
    expr.* = .{ .Error = msg };
    pushError(psr, msg);
    return expr;
}

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
                "PARSER ERROR",
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
    if (psr.idx + 1 < psr.tks.items.len) {
        psr.idx += 1;
        return current(psr);
    }
    return current(psr);
}

pub fn expect(psr: *Parser, comptime tk: token.TokenType) token.Token {
    var msg = "Expected token of type " ++ @tagName(tk);
    if (current(psr).type != tk) pushError(psr, msg);
    if (advance(psr).value.len == 0) return current(psr);
    return advance(psr);
}

pub fn parseExpr(
    alloc: std.mem.Allocator,
    parser: *Parser,
    bp: prec.bindingPower,
) !*ast.Expr {
    var left = try prec.nudHandler(alloc, parser, current(parser));

    while (@intFromEnum(prec.getBP(parser, current(parser))) > @intFromEnum(bp)) {
        left = try prec.ledHandler(alloc, parser, left);
        _ = advance(parser);
    }

    std.debug.print("Expression parsed\n", .{});
    return left;
}

pub fn parseStmt(
    alloc: std.mem.Allocator,
    parser: *Parser,
) !*stmt.Stmt {
    std.debug.print("Parsing statement\n", .{});
    var _stmt = try prec.stmtHandler(alloc, parser);
    std.debug.print("Statement parsed\n", .{});
    std.debug.print("Statement: {s}\n", .{_stmt});
    return _stmt;
}
