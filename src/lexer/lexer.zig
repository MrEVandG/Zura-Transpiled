const print = @import("std").debug.print;
const std = @import("std");

pub const TokenType = @import("tokens.zig").TokenType;
const lError = @import("../helper/error.zig").lError;

const isDigit = std.ascii.isDigit;
const isAlpha = std.ascii.isAlphabetic;

pub const Token = struct {
    type: TokenType,
    line: c_int,
    pos: c_int,
};

const Scanner = struct {
    source: []const u8,
    start: []const u8,
    current: []const u8,
    line: c_int,
    pos: c_int,
};

var scanner: Scanner = Scanner{ .source = "", .start = "", .current = "", .line = 1, .pos = 0 };

fn advance() ?u8 {
    if (isAtEnd()) {
        return null;
    }

    const result = scanner.current[0];
    scanner.current = scanner.current[1..];
    scanner.pos += 1;

    return result;
}

fn peek() ?u8 {
    if (isAtEnd()) {
        return null;
    }
    return scanner.current[0];
}

fn peekNext() ?u8 {
    if (scanner.current.len > 1) {
        return scanner.current[1];
    }
    return null;
}

pub fn initScanner(source: []const u8) void {
    scanner.source = source;
    scanner.start = source;
    scanner.current = source;
    scanner.line = 1;
    scanner.pos = 0;
}

pub fn lineStart(line: c_int) []const u8 {
    var start = scanner.source;
    var currentLine: c_int = 1;
    while (currentLine != line) {
        if (start[0] == '\n') {
            currentLine += 1;
        }
        start = start[1..];
    }
    return start;
}

fn isAtEnd() bool {
    return scanner.current.len == 0;
}

fn makeToken(kind: TokenType) Token {
    return Token{ .type = kind, .line = scanner.line, .pos = scanner.pos };
}

fn errorToken(message: []const u8) Token {
    lError(scanner.line, scanner.pos, message);
    return makeToken(TokenType.Error);
}

fn num() Token {
    while (isDigit(peek() orelse '*')) {
        _ = advance();
    }
    return makeToken(TokenType.Number);
}

fn string() Token {
    while (peek() != '"' and !isAtEnd()) {
        if (peek() == '\n') {
            scanner.line += 1;
        }
        _ = advance();
    }
    if (isAtEnd()) {
        return errorToken("Unterminated string.");
    }
    _ = advance();
    return makeToken(TokenType.String);
}

fn getTokenKind(identifier: []const u8) TokenType {
    const keywords = std.ComptimeStringMap(TokenType, .{
        .{ "have", TokenType.Var },
        .{ "fn", TokenType.Fn },
        .{ "if", TokenType.If },
        .{ "else", TokenType.Else },
        .{ "int", TokenType.Int },
        .{ "float", TokenType.Float },
        .{ "str", TokenType.String },
        .{ "bool", TokenType.Bool },
        .{ "null", TokenType.NUll },
    });
    return keywords.get(identifier) orelse TokenType.Identifier;
}

fn identType() TokenType {
    const keyword = scanner.start[0 .. scanner.start.len - scanner.current.len];
    return getTokenKind(keyword);
}

fn ident() Token {
    while (true) {
        if (peek()) |c| {
            if (isAlpha(c) or isDigit(c)) {
                _ = advance();
            } else break;
        } else break;
    }
    return makeToken(identType());
}

fn skipWhitespace() void {
    while (true) {
        if (peek()) |c| {
            switch (c) {
                ' ', '\r', '\t' => {
                    _ = advance();
                },
                '\n' => {
                    scanner.line += 1;
                    scanner.pos = 0;
                    _ = advance();
                },
                '/' => {
                    if (peekNext() == '/') {
                        while (peek() != '\n' and !isAtEnd())
                            _ = advance();
                    } else return;
                },
                else => return,
            }
        } else return;
    }
}

fn dLookUp(_string: [2]u8) ?TokenType {
    const doubleCharLookup = std.ComptimeStringMap(TokenType, .{
        .{ "==", TokenType.equalEqual },
        .{ "<=", TokenType.lessEqual },
        .{ ">=", TokenType.greaterEqual },
        .{ ":=", TokenType.Walrus },
    });
    return doubleCharLookup.get(&_string);
}

pub fn scanToken() Token {
    skipWhitespace();

    scanner.start = scanner.current;

    if (advance()) |c| {
        if (isAlpha(c))
            return ident();

        if (isDigit(c))
            return num();

        if (peek()) |c2| {
            var dCharLookUp = [2]u8{ c, c2 };
            if (dLookUp(dCharLookUp)) |it| {
                _ = advance();
                return makeToken(it);
            }
        }

        return switch (c) {
            ')' => makeToken(TokenType.rParen),
            '(' => makeToken(TokenType.lParen),
            '}' => makeToken(TokenType.rCurly),
            '{' => makeToken(TokenType.lCurly),
            ']' => makeToken(TokenType.rBrace),
            '[' => makeToken(TokenType.lBrace),
            ';' => makeToken(TokenType.semicolon),
            ',' => makeToken(TokenType.comma),
            '.' => makeToken(TokenType.dot),
            '+' => makeToken(TokenType.plus),
            '*' => makeToken(TokenType.star),
            '/' => makeToken(TokenType.slash),
            '^' => makeToken(TokenType.carrot),
            '%' => makeToken(TokenType.mod),
            '-' => makeToken(TokenType.minus),
            '!' => makeToken(TokenType.not),
            '=' => makeToken(TokenType.equal),
            '<' => makeToken(TokenType.less),
            '>' => makeToken(TokenType.greater),
            ':' => makeToken(TokenType.Colon),
            '"' => string(),
            else => return errorToken("Unexpected character."),
        };
    }
    return makeToken(TokenType.Eof);
}
