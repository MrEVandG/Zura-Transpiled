const std = @import("std");

const token = @import("../lexer/tokens.zig");
const h = @import("helper.zig");

pub fn parse(allocator: std.mem.Allocator) !void {
    var parser = h.init_parser(allocator);

    try h.storeToken(&parser, token.token);

    while (parser.index < parser.tks.items.len) {
        std.debug.print("{s}", .{h.current(&parser).value});

        if (parser.index + 1 >= parser.tks.items.len) break;
        _ = h.next(&parser);
    }
}
