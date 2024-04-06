const std = @import("std");

const prec = @import("prec.zig");
const token = @import("../lexer/tokens.zig");
const pError = @import("../helper/error.zig");
const lexer = @import("../lexer/lexer.zig");
const ast = @import("../ast/ast.zig");

pub fn parseExpr(bp: prec.bp) ast.Expr {
    var left = prec.nud_lookup(token.token.type);

    // We need to check the current tokens bp and compare it to the left bp
    while (prec.bp_lookup(token.token.type).?.bp > bp) {
        left = prec.led_lookup(token.token.type, left);
    }

    return left;
}

pub fn parsePrimary() ast.Expr {
    const tok = token.token.type;
    switch (tok) {
        .Num => {
            return ast.expr.Number{ .value = token.token.value };
        },
        .String => {
            return ast.expr.String{ .value = token.token.value };
        },
        .Ident => {
            return ast.expr.Ident{ .value = token.token.value };
        },
        else => {
            pError.Error(
                token.token.line,
                token.token.pos,
                "Can not create parser_primary!",
                "PARSER ERROR",
                token.scanner.filename,
            );
        },
    }
}

pub fn parseBinary(left: ast.Expr) ast.Expr {
    var op = token.token.type;
    var right = parseExpr(.defalt);

    return ast.expr.Binary{
        .left = left,
        .op = op,
        .right = right,
    };
}
