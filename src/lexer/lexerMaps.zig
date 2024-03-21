const std = @import("std");

const tokens = @import("tokens.zig");

pub const keywordHash = std.ComptimeStringMap(tokens.TokenType, .{
    .{ "fn", tokens.TokenType.Func },
    .{ "ret", tokens.TokenType.Return },
    .{ "info", tokens.TokenType.Info },
    .{ "have", tokens.TokenType.Have },
    .{ "const", tokens.TokenType.Const },
    .{ "auto", tokens.TokenType.Auto },
    .{ "if", tokens.TokenType.If },
    .{ "else", tokens.TokenType.Else },

    // Data Types
    .{ "int", tokens.TokenType.INT },
    .{ "i8", tokens.TokenType.I8 },
    .{ "i16", tokens.TokenType.I16 },
    .{ "i32", tokens.TokenType.I32 },
    .{ "i64", tokens.TokenType.I64 },
    .{ "u8", tokens.TokenType.U8 },
    .{ "u16", tokens.TokenType.U16 },
    .{ "u32", tokens.TokenType.U32 },
    .{ "u64", tokens.TokenType.U64 },
    .{ "f32", tokens.TokenType.FL32 },
    .{ "f64", tokens.TokenType.FL64 },
    .{ "bool", tokens.TokenType.BL },
    .{ "char", tokens.TokenType.CHAR },
    .{ "str", tokens.TokenType.STR },
    .{ "void", tokens.TokenType.VOID },
    .{ "null", tokens.TokenType.NULL },
});

pub fn sCharLookUp(schar: u8) ?tokens.TokenType {
    const hash = std.ComptimeStringMap(tokens.TokenType, .{
        .{ "(", tokens.TokenType.lParen },
        .{ ")", tokens.TokenType.rParen },
        .{ "{", tokens.TokenType.lBrace },
        .{ "}", tokens.TokenType.rBrace },
        .{ "[", tokens.TokenType.lBrac },
        .{ "]", tokens.TokenType.rBrac },
        .{ ",", tokens.TokenType.comma },
        .{ "-", tokens.TokenType.minus },
        .{ "+", tokens.TokenType.plus },
        .{ "/", tokens.TokenType.slash },
        .{ "*", tokens.TokenType.star },
        .{ "%", tokens.TokenType.mod },
        .{ "^", tokens.TokenType.caret },
        .{ "!", tokens.TokenType.not },
        .{ ";", tokens.TokenType.semicolon },
        .{ ":", tokens.TokenType.colon },
        .{ "=", tokens.TokenType.equal },
        .{ ".", tokens.TokenType.dot },
    });
    // Casting the u8 to a string of 1 to use it as a key
    return hash.get(&[1]u8{schar});
}

pub fn dCharLookUp(dchar: [2]u8) ?tokens.TokenType {
    const hash = std.ComptimeStringMap(tokens.TokenType, .{
        .{ "==", tokens.TokenType.eEqual },
        .{ "!=", tokens.TokenType.nEqual },
        .{ "<=", tokens.TokenType.ltEqual },
        .{ ">=", tokens.TokenType.gtEqual },
        .{ ":=", tokens.TokenType.Walrus },
        .{ "->", tokens.TokenType.lArrow },
        .{ "<-", tokens.TokenType.rArrow },
    });
    return hash.get(&dchar);
}
