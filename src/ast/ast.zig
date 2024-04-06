pub const Expr = union(enum) {
    Number: struct {
        value: []const u8,
    },
    String: struct {
        value: []const u8,
    },
    Ident: struct {
        value: []const u8,
    },
    Binary: struct {
        left: *Expr,
        op: enum {
            Add,
            Sub,
            Mul,
            Div,
        },
        right: *Expr,
    },
};

pub var expr: Expr = undefined;
