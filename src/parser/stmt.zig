const std = @import("std");

const token = @import("../lexer/tokens.zig");
const psr = @import("helper.zig");
const stmt = @import("../ast/stmt.zig");
const prec = @import("prec.zig");

pub fn var_decl(parser: *psr.Parser, alloc: std.mem.Allocator) !*stmt.Stmt {
    _ = parser;

    var new_stmt_ptr = try alloc.create(stmt.Stmt);
    new_stmt_ptr.* = .{ .VarDecl = .{ .name = "", .type = "" } };
    return new_stmt_ptr;
}
