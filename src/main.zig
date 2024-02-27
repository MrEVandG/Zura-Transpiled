const lexer = @import("lexer/lexer.zig");
const std = @import("std");

pub fn main() !void {
    const source: []const u8 = "//Hello World";
    lexer.initScanner(source);

    while (true) {
        const token = lexer.scanToken();
        std.debug.print("Token: {} Pos: {} Line: {}\n", .{ token.type, token.pos, token.line });
        if (token.type == lexer.TokenType.Eof) {
            break;
        }
    }
}

test "LexerTestVars" {
    {
        const input: []const u8 = "have x: int := 10;";
        const expected = [_]lexer.Token{
            .{ .type = lexer.TokenType.Var, .pos = 4, .line = 1 },
            .{ .type = lexer.TokenType.Identifier, .pos = 6, .line = 1 },
            .{ .type = lexer.TokenType.Colon, .pos = 7, .line = 1 },
            .{ .type = lexer.TokenType.Int, .pos = 11, .line = 1 },
            .{ .type = lexer.TokenType.Walrus, .pos = 14, .line = 1 },
            .{ .type = lexer.TokenType.Number, .pos = 17, .line = 1 },
            .{ .type = lexer.TokenType.semicolon, .pos = 18, .line = 1 },
            .{ .type = lexer.TokenType.Eof, .pos = 18, .line = 1 },
        };

        lexer.initScanner(input);

        for (expected) |capturedToken| {
            try std.testing.expectEqual(capturedToken, lexer.scanToken());
        }
    }
    {
        const input: []const u8 = "have x: str := \"Hello World\";";
        const expected = [_]lexer.Token{
            .{ .type = lexer.TokenType.Var, .pos = 4, .line = 1 },
            .{ .type = lexer.TokenType.Identifier, .pos = 6, .line = 1 },
            .{ .type = lexer.TokenType.Colon, .pos = 7, .line = 1 },
            .{ .type = lexer.TokenType.String, .pos = 11, .line = 1 },
            .{ .type = lexer.TokenType.Walrus, .pos = 14, .line = 1 },
            .{ .type = lexer.TokenType.String, .pos = 28, .line = 1 },
            .{ .type = lexer.TokenType.semicolon, .pos = 29, .line = 1 },
            .{ .type = lexer.TokenType.Eof, .pos = 29, .line = 1 },
        };

        lexer.initScanner(input);

        for (expected) |capturedToken| {
            try std.testing.expectEqual(capturedToken, lexer.scanToken());
        }
    }
}
