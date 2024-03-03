const std = @import("std");

pub const Colors = enum {
    RED,
    GREEN,
    BLUE,
    YELLOW,
    ORANGE,
    PURPLE,
    PINK,
    BROWN,
    WHITE,
    BLACK,
    RESET,
};

pub fn colorize(color: Colors) !void {
    const stdout = std.io.getStdOut().writer();
    try switch (color) {
        Colors.RED => stdout.print("\x1b[31m", .{}),
        Colors.GREEN => stdout.print("\x1b[32m", .{}),
        Colors.BLUE => stdout.print("\x1b[34m", .{}),
        Colors.YELLOW => stdout.print("\x1b[33m", .{}),
        Colors.ORANGE => stdout.print("\x1b[38;5;208m", .{}),
        Colors.PURPLE => stdout.print("\x1b[35m", .{}),
        Colors.PINK => stdout.print("\x1b[38;5;205m", .{}),
        Colors.BROWN => stdout.print("\x1b[38;5;94m", .{}),
        Colors.WHITE => stdout.print("\x1b[37m", .{}),
        Colors.BLACK => stdout.print("\x1b[30m", .{}),
        Colors.RESET => stdout.print("\x1b[0m", .{}),
    };
}
