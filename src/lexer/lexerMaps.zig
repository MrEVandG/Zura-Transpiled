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
});

pub fn dCharLookUp(dchar: [2]u8) ?tokens.TokenType {
    const hash = std.ComptimeStringMap(tokens.TokenType, .{
        .{ "==", .eEqual },
        .{ "!=", .nEqual },
        .{ "<=", .ltEqual },
        .{ ">=", .gtEqual },
        .{ ":=", .Walrus },
        .{ "->", .lArrow },
        .{ "<-", .rArrow },
    });
    return hash.get(&dchar);
}
