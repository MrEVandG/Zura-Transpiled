const lexer = @import("lexer/lexer.zig");
const std = @import("std");

pub fn main() !void {
    // Allocate
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Parse args into string array (error union needs 'try')
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // NOTE: add in flags for compiler options

    // Opening, reading, and lexing the file
    var file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var bufferReader = std.io.bufferedReader(file.reader());
    var inStream = bufferReader.reader();

    var buffer: [1024]u8 = undefined;
    while (try inStream.readUntilDelimiterOrEof(&buffer, '\n')) |read| {
        const input = buffer[0..read.len];
        lexer.initScanner(input);

        while (true) {
            const token = lexer.scanToken();
            //NOTE: Line is not being indexed correctly
            std.debug.print("Token: {} Pos: {} Line: {}\n", .{ token.type, token.pos, token.line });
            if (token.type == lexer.TokenType.Eof) {
                break;
            }
        }
    }
}
