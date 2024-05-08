const std = @import("std");

const token = @import("../lexer/tokens.zig");
const psr = @import("helper.zig");
const stmt = @import("../ast/stmt.zig");
const hp = @import("helper.zig");
const prec = @import("prec.zig");

pub fn var_decl(parser: *psr.Parser, alloc: std.mem.Allocator) !*stmt.Stmt {
    const name = psr.expect(parser, token.TokenType.Ident);
    std.debug.print("{s}\n", .{name.value});

    _ = psr.expect(parser, token.TokenType.colon);
    const _type = psr.expect(parser, token.TokenType.Ident);

    _ = psr.expect(parser, token.TokenType.equal);
    const _expr = try hp.parseExpr(alloc, parser, prec.bindingPower.default);

    _ = psr.expect(parser, token.TokenType.semicolon);

    const new_stmt_ptr = try alloc.create(stmt.Stmt);
    new_stmt_ptr.* = .{ .VarDecl = .{
        .name = name.value,
        .type = _type.value,
        .expr = _expr,
    } };
    return new_stmt_ptr;
}
