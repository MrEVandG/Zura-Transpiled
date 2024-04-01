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

pub fn Error(
    line: usize,
    pos: usize,
    msg: []const u8,
    comptime typeOfError: []const u8,
    filename: []u8,
) !void {
    comptime var cham = Chameleon.init(.Auto);
    print("[{}::{}] ({s}) \n ↳ ", .{ line, pos, filename });
    print(cham.red().fmt(typeOfError), .{});
    print(" {s}\n", .{msg});

    // Print our the line
    var start = try lineStart(line, token.scanner.source);
    var end = start;

    while (end.len > 0 and end[0] != '\n' and end[0] != 0)
        end = end[1..];
    const lineLength = @intFromPtr(end.ptr) - @intFromPtr(start.ptr);
    print("{s}\n", .{start[0..lineLength]});

    // show where the error is!
    var i: usize = 0;
    while (i < (pos)) : (i += 1)
        printCharOrPlace(start[i]);
    print(cham.red().fmt("^\n"), .{});
}
