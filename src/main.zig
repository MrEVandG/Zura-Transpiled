const lexer = @import("lexer/lexer.zig");
const initScanner = @import("lexer/lexerHelper.zig").initScanner;
const std = @import("std");

fn getFileContents(allocator: std.mem.Allocator, file: std.fs.File) ![]const u8 {
    var buffer: usize = 1024;
    var result = try file.readToEndAlloc(allocator, buffer);

    // TODO: If the buffer is too small, double the size and try again

    return result;
}

fn run(allocator: std.mem.Allocator, cmd: [][]u8) !noreturn {
    // Opening, reading, and lexing the file
    var file = try std.fs.cwd().openFile(cmd[2], .{});
    var input: []const u8 = try getFileContents(allocator, file);

    initScanner(input);

    while (true) {
        const token = try lexer.scanToken();
        std.debug.print("Token: {any}\n", .{(token.type)});
        if (token.type == .Eof) {
            break;
        }
    }

    defer allocator.free(input);

    return std.os.exit(0) orelse unreachable;
}

fn checkForCompilerCmd(allocator: std.mem.Allocator, args: [][]u8) !usize {
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
        std.debug.print("No compiler command found\n", .{});
        std.debug.print("Usage: zura [build|run] <file.zu> [args...]\n", .{});
        std.debug.print("Compiler commands:\n", .{});
        std.debug.print("    build => builds the given file to an exacutable\n", .{});
        std.debug.print("    run   => builds and runs the given file\n", .{});
        std.debug.print("Args commands:\n", .{});
        std.debug.print("    -name => assigns a name to the exacutable\n", .{});
        std.debug.print("    -save => saves the exacutable to a given path\n", .{});
        std.debug.print("    -sAll => saves the .o and exacutable files\n", .{});
        std.debug.print("    -c    => delets the exacutable generated and the .o file\n", .{});
        std.debug.print("Helpful commands:\n", .{});
        std.debug.print("    -v    => prints the version of the compiler\n", .{});
        return;
    }
}
