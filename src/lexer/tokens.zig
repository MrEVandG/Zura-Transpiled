pub const TokenType = enum {
    Start,
    // Single Characters
    lParen,
    rParen,
    lBrace,
    rBrace,
    lBrac,
    rBrac,
    comma,
    semicolon,
    colon,
    equal,
    dot,

    // Double Characters
    Walrus,
    lArrow,
    rArrow,
    eEqual,
    ltEqual,
    gtEqual,
    nEqual,

    // Unary
    minus,
    not,

    // Binary
    plus,
    star,
    slash,
    caret,
    mod,

    // Literals
    Ident,
    Num,
    Float,
    String,

    // Keywords
    Func,
    Return,
    Info,
    Have,
    Const,
    Auto,
    If,
    Else,

    // Data Types
    I8,
    I16,
    I32,
    I64,
    INT,
    U8,
    U16,
    U32,
    U64,
    UINT,
    FL32,
    FL64,
    CHAR,
    STR,
    BL,
    VOID,
    NULL,

    Error,
    Eof,
};

pub const Token = struct {
    type: TokenType,
    lexem: []const u8,
    line: usize,
    pos: usize,
};

const Scanner = struct {
    source: []const u8,
    start: []const u8,
    current: []const u8,
    line: usize,
    pos: usize,
};

pub var scanner: Scanner = Scanner{
    .source = "",
    .start = "",
    .current = "",
    .line = 1,
    .pos = 0,
};

pub var token: Token = Token{
    .type = TokenType.Start,
    .lexem = "",
    .line = 1,
    .pos = 0,
};
