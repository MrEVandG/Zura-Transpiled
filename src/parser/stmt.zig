const std = @import("std");

const parser = @import("helper.zig");
const stmt = @import("../ast/stmt.zig");
const prec = @import("prec.zig");

pub fn var_decl(psr: *parser.Parser, alloc: std.mem.Allocator) !*stmt.Stmt {
    _ = alloc;
    _ = psr;
}

pub fn expr_stmt(psr: *parser.Parser, alloc: std.mem.Allocator) !*stmt.Stmt {
    var expr = try parser.parseExpr(alloc, psr, prec.bindingPower.default);

    const res = alloc.create(stmt.Stmt);
    res.* = .{ .exprStmt = .{ .expr = expr } };
    return res;
}
