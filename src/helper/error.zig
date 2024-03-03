const std = @import("std");
const print = std.debug.print;

const lineStart = @import("../lexer/lexer.zig").lineStart;
const Chameleon = @import("inc/chameleon.zig").Chameleon;

fn printCharOrPlaceHolder(c: u8) void {
    comptime var cham = Chameleon.init(.Auto);
    if (c == '\t') {
        print("\t", .{});
    } else {
        print(cham.dim().fmt("~"), .{});
    }
}

pub fn lError(line: c_int, pos: c_int, _msg: []const u8) void {
    comptime var cham = Chameleon.init(.Auto);
    print("[{}::{}] ", .{ line, pos });
    print(cham.red().fmt("error:"), .{});
    print(" {s}\n", .{_msg});

    // print out the line using lineStart
    var start = lineStart(line);
    var end = start;

    while (end.len > 0 and end[0] != '\n' and end[0] != 0)
        end = end[1..];

    const lineLength = @intFromPtr(end.ptr) - @intFromPtr(start.ptr);
    print("{s}\n", .{start[0..lineLength]});

    // print out the pointer to the error
    var i: usize = 0;
    while (i < (pos - 1)) : (i += 1)
        printCharOrPlaceHolder(start[i]);
    print(cham.red().fmt("^\n"), .{});
}
