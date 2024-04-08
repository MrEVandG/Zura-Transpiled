const lexer = @import("lexer/lexer.zig");
const tokens = @import("lexer/tokens.zig");
const initScanner = @import("lexer/lexerHelper.zig").initScanner;
const parser = @import("parser/parser.zig");
const std = @import("std");

fn getFileContents(allocator: std.mem.Allocator, file: std.fs.File) ![]const u8 {
    var buffer: usize = 1024;
    var result = try file.readToEndAlloc(allocator, buffer);
    // TODO: If the buffer is too small, double the size and try again
    return result;
}

fn run(allocator: std.mem.Allocator, cmd: []const []const u8) !void {
    // Opening, reading, and lexing the file
    var file = try std.fs.cwd().openFile(cmd[2], .{});
    defer file.close();
    var input: []const u8 = try getFileContents(allocator, file);
    defer allocator.free(input);

    tokens.scanner.filename = cmd[2];

    initScanner(input);

    // Parsing the file
    try parser.parse(allocator);

    std.debug.print("\n", .{});
}

fn checkForCompilerCmd(allocator: std.mem.Allocator, args: []const []const u8) !i8 {
    for (args) |arg| {
        if (std.mem.eql(u8, "build", arg) or std.mem.eql(u8, "run", arg)) {
            try run(allocator, args);
            return 0;
        }
        if (std.mem.eql(u8, "-v", arg)) {
            std.debug.print("Zura version 0.1.0\n", .{});
            return 0;
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
    const compilerCmdIndex = try checkForCompilerCmd(allocator, args);
    if (compilerCmdIndex == 1) {
        std.debug.print(
            \\No compiler command found 
            \\Usage: zura [build|run] <file.zu> [args...]
            \\Compiler commands:
            \\    build => builds the given file to an exacutable
            \\    run   => builds and runs the given file
            \\Args commands:
            \\    -name => assigns a name to the exacutable
            \\    -save => saves the exacutable to a given path
            \\    -sAll => saves the .o and exacutable file
            \\    -c    => delets the exacutable generated and the .o file
            \\Helpful commands:
            \\    -v    => prints the version of the compiler 
            \\
        , .{});
        return;
    }
}
