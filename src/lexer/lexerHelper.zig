const std = @import("std");
const tokens = @import("tokens.zig");
const lError = @import("../helper/error.zig");

const Token = tokens.Token;

pub fn initScanner(source: []const u8) void {
    tokens.scanner.current = source;
    tokens.scanner.source = source;
    tokens.scanner.start = source;
    tokens.scanner.line = 1;
    tokens.scanner.pos = 0;
}

pub fn lineStart(line: usize, source: []const u8) ![]const u8 {
    if (line == 0) return error.LineStartZero;
    if (source.len == 0) return error.LineStartEmpty;

    var cLine: usize = 1;
    var start = source;

    while (cLine < line) {
        if (start.len == 0) return error.LineStartNotFound;
        if (start[0] == '\n') cLine += 1;
        start = start[1..];
    }

    return start;
}

fn getValue(start: []const u8, end: []const u8) ![]const u8 {
    if (start.len == 0 and end.len == 0)
        return "EOF";

    var length = @intFromPtr(end.ptr) - @intFromPtr(start.ptr);

    if (start[0] == '\n')
        return start[1..length];

    return start[0..length];
}

pub fn makeToken(kind: tokens.TokenType) !Token {
    tokens.token.line = tokens.scanner.line;
    tokens.token.pos = tokens.scanner.pos;
    tokens.token.value = try getValue(
        tokens.scanner.start,
        tokens.scanner.current,
    );
    tokens.token.type = kind;
    return tokens.token;
}

pub fn errorToken(message: []const u8) !Token {
    try lError.Error(
        tokens.scanner.line,
        tokens.scanner.pos - 1,
        message,
        "LEXER ERROR",
        tokens.scanner.filename,
    );
    return makeToken(tokens.TokenType.Error);
}

pub fn isEof() bool {
    return tokens.scanner.current.len == 0;
}

pub fn advance() ?u8 {
    if (isEof()) return null;
    const result = tokens.scanner.current[0];
    tokens.scanner.current = tokens.scanner.current[1..];
    tokens.scanner.pos += 1;
    return result;
}

pub fn peek(index: usize) ?u8 {
    if (index >= tokens.scanner.current.len) return null;
    return tokens.scanner.current[index];
}
