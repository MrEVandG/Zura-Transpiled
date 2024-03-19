const std = @import("std");

const tokens = @import("tokens.zig");
const lError = @import("../helper/error.zig");
const helper = @import("lexerHelper.zig");

const keywordHash = @import("lexerMaps.zig").keywordHash;
const dCharLookUp = @import("lexerMaps.zig").dCharLookUp;
const sCharLookUp = @import("lexerMaps.zig").sCharLookUp;

const isDigit = std.ascii.isDigit;
const isAplha = std.ascii.isAlphabetic;
const Token = tokens.Token;
const peek = helper.peek;
const advance = helper.advance;
const makeToken = helper.makeToken;
const errorToken = helper.errorToken;
const isEof = helper.isEof;

fn num() Token {
    while (isDigit(peek(0) orelse 0)) _ = advance();
    if (peek(0) == '.' and isDigit(peek(1) orelse 0)) {
        _ = advance();
        while (isDigit(peek(0) orelse 0))
            _ = advance();
    }
    return makeToken(.Num);
}

fn string() !Token {
    while (peek(0) != '"' and !isEof()) {
        if (peek(0) == '\n') {
            tokens.scanner.line += 1;
            tokens.scanner.pos = 0;
        }
        _ = advance();
    }
    if (isEof()) return try errorToken("Unterminated string.");
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
    while (peek(0)) |c| {
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
    }
}

pub fn scanToken() !Token {
    skipWhiteSpace();

    tokens.scanner.start = tokens.scanner.current;

    if (advance()) |c| {
        if (isAplha(c)) return ident();
        if (isDigit(c)) return num();
        if (c == '"') return string();

        if (peek(0)) |c2| {
            var dChar = [2]u8{ c, c2 };
            if (dCharLookUp(dChar)) |it| {
                _ = advance();
                return makeToken(it);
            }
        }

        if (sCharLookUp(c)) |it| {
            return makeToken(it);
        }

        return try errorToken("Unexpected character.");
    }
    return makeToken(.Eof);
}
