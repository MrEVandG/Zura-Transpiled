const std = @import("std");
const print = std.debug.print;

const lineStart = @import("../lexer/lexerHelper.zig").lineStart;
const token = @import("../lexer/tokens.zig");
const Chameleon = @import("inc/chameleon.zig").Chameleon;

fn printCharOrPlace(c: u8) void {
    comptime var cham = Chameleon.init(.Auto);
    if (c == '\t') {
        print("\t", .{});
    } else {
        print(cham.dim().fmt("~"), .{});
    }
}

fn printIgnore(line: usize) void {
    if (line < 10) print("   ", .{});
    if (line >= 10 and line < 100) print("   ", .{});
    if (line >= 100) print("    ", .{});
    if (line >= 1000) print("     ", .{});
    if (line >= 10000) print("      ", .{});
    if (line >= 100000) print("       ", .{});
    if (line >= 1000000) print("        ", .{});
}

fn lineNumber(line: usize) []const u8 {
    if (line < 10) {
        return "0";
    }
    return "";
}

fn printLine(start: []const u8, line: usize) void {
    var end = start;
    while (end.len > 0 and end[0] != '\n' and end[0] != 0)
        end = end[1..];
    const lineLength = @intFromPtr(end.ptr) - @intFromPtr(start.ptr);
    print("{s}{}|{s}\n", .{ lineNumber(line), line, start[0..lineLength] });
}

fn lineBefore(line: usize) !void {
    if (line > 0) {
        var start = try lineStart(line, token.scanner.source);
        printLine(start, line);
    }
}

fn currentLine(line: usize, pos: usize) !void {
    comptime var cham = Chameleon.init(.Auto);
    var start = try lineStart(line, token.scanner.source);
    printLine(start, line);

    // show where the error is!
    var i: usize = 0;
    var cPos: usize = pos;
    if (line == 1) cPos += 1;

    printIgnore(line); // ignore the 01|

    while (i < (cPos - 1)) : (i += 1)
        printCharOrPlace(start[i]);
    print(cham.red().fmt("^\n"), .{});
}

fn lineAfter(line: usize) !void {
    var start = try lineStart(line, token.scanner.source);
    printLine(start, line);
}

pub fn Error(
    line: usize,
    pos: usize,
    msg: []const u8,
    comptime typeOfError: []const u8,
    filename: []u8,
) !void {
    comptime var cham = Chameleon.init(.Auto);

    var cPos: usize = pos;
    if (line == 1) cPos += 1;

    print("[{}::{}] ({s}) \n ↳ ", .{ line, cPos, filename });
    print(cham.red().fmt(typeOfError), .{});
    print(" {s}\n", .{msg});

    try lineBefore(line - 1);
    try currentLine(line, pos);
    try lineAfter(line + 1);

    print("\n", .{});
}
