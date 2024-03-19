const std = @import("std");

pub const tokens = @import("tokens.zig");

const Token = @import("tokens.zig").Token;
const lError = @import("../helper/error.zig");

const keywordHash = @import("lexerMaps.zig").keywordHash;
const dCharLookUp = @import("lexerMaps.zig").dCharLookUp;

const isDigit = std.ascii.isDigit;
const isAplha = std.ascii.isAlphabetic;

pub fn initScanner(source: []const u8) void {
    tokens.scanner.current = source;
    tokens.scanner.source = source;
    tokens.scanner.start = source;
    tokens.scanner.line = 1;
    tokens.scanner.pos = 0;
}

pub fn lineStart(line: usize) []const u8 {
    var start = tokens.scanner.source;
    var cLine: usize = 1;

    while (cLine != line) {
        if (start[0] == '\n')
            cLine += 1;
        start = start[1..];
    }
    return start;
}

fn makeToken(kind: tokens.TokenType) Token {
    tokens.token.line = tokens.scanner.line;
    tokens.token.pos = tokens.scanner.pos;
    tokens.token.type = kind;
    return tokens.token;
}

fn errorToken(message: []const u8) Token {
    lError.lError(tokens.scanner.line, tokens.scanner.pos - 1, message);
    return makeToken(tokens.TokenType.Error);
}

fn isEof() bool {
    return tokens.scanner.current.len == 0;
}

fn advance() ?u8 {
    if (isEof()) return null;
    const result = tokens.scanner.current[0];
    tokens.scanner.current = tokens.scanner.current[1..];
    tokens.scanner.pos += 1;
    return result;
}

fn peek(index: usize) ?u8 {
    if (index >= tokens.scanner.current.len) return null;
    return tokens.scanner.current[index];
}

fn num() Token {
    while (isDigit(peek(0) orelse 0)) _ = advance();
    if (peek(0) == '.' and isDigit(peek(1) orelse 0)) {
        _ = advance();
        while (isDigit(peek(0) orelse 0))
            _ = advance();
    }
    return makeToken(.Num);
}

fn string() Token {
    while (peek(0) != '"' and !isEof()) {
        if (peek(0) == '\n') {
            tokens.scanner.line += 1;
            tokens.scanner.pos = 0;
        }
        _ = advance();
    }
    if (isEof()) return errorToken("Unterminated string.");
    _ = advance();
    return makeToken(.String);
}

fn getTokenType(keyword: []const u8) tokens.TokenType {
    return keywordHash.get(keyword) orelse .Ident;
}

fn identType() tokens.TokenType {
    const keyword = tokens.scanner.start[0 .. tokens.scanner.start.len - tokens.scanner.current.len];
    return getTokenType(keyword);
}

fn ident() Token {
    while (isAplha(peek(0) orelse 0) or isDigit(peek(0) orelse 0))
        _ = advance();
    return makeToken(identType());
}

fn skipWhiteSpace() void {
    while (true) {
        if (peek(0)) |c| {
            switch (c) {
                ' ', '\t', '\r' => {
                    _ = advance();
                },
                '\n' => {
                    tokens.scanner.line += 1;
                    tokens.scanner.pos = 0;
                    _ = advance();
                },
                '#' => {
                    while (peek(0) != '\n' and !isEof()) _ = advance();
                },
                else => return,
            }
        } else return;
    }
}

pub fn scanToken() Token {
    skipWhiteSpace();

    tokens.scanner.start = tokens.scanner.current;

    if (advance()) |c| {
        if (isAplha(c)) return ident();
        if (isDigit(c)) return num();

        if (peek(0)) |c2| {
            var dChar = [2]u8{ c, c2 };
            if (dCharLookUp(dChar)) |it| {
                _ = advance();
                return makeToken(it);
            }
        }

        return switch (c) {
            '(' => makeToken(.lParen),
            ')' => makeToken(.rParen),
            '{' => makeToken(.lBrace),
            '}' => makeToken(.rBrace),
            '[' => makeToken(.lBrac),
            ']' => makeToken(.rBrac),
            ',' => makeToken(.comma),
            '-' => makeToken(.minus),
            '+' => makeToken(.plus),
            '/' => makeToken(.slash),
            '*' => makeToken(.star),
            '%' => makeToken(.mod),
            '^' => makeToken(.caret),
            '!' => makeToken(.not),
            ';' => makeToken(.semicolon),
            ':' => makeToken(.colon),
            '=' => makeToken(.equal),
            '.' => makeToken(.dot),
            '"' => string(),
            else => errorToken("Unexpected character."),
        };
    }
    return makeToken(.Eof);
}
