const lexer = @import("lexer/lexer.zig");
const parser = @import("parser/parser.zig");
const std = @import("std");

fn run(cmd: [][]u8) !void {
    // Opening, reading, and lexing the file
    var file = try std.fs.cwd().openFile(cmd[2], .{});
    defer file.close();

    var bufferReader = std.io.bufferedReader(file.reader());
    var inStream = bufferReader.reader();

    var buffer: [1024]u8 = undefined;
    while (try inStream.readUntilDelimiterOrEof(&buffer, '\n')) |read| {
        const input = buffer[0..read.len];

        lexer.initScanner(input);

        var result = parser.parse();

        std.debug.print("result: {any}\n", .{result});
    }

    std.os.exit(0);
}

fn checkForCompilerCmd(args: [][]u8) !usize {
    for (args, 0..) |arg, index| {
        if (std.mem.eql(u8, "build", arg) or std.mem.eql(u8, "run", arg)) {
            try run(args);
            return index;
        }
    }
    return 1;
}

pub fn main() !void {
    // Allocate
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Parse args into string array (error union needs 'try')
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Check for compiler command
    const compilerCmdIndex = try checkForCompilerCmd(args);
    if (compilerCmdIndex == 1) {
        std.debug.print("No compiler command found\n", .{});
        return;
    }
}
