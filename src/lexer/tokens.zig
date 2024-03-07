pub const TokenType = enum {
    // Single-character tokens
    lParen,
    rParen,
    lBrace,
    rBrace,
    lCurly,
    rCurly,
    comma,
    dot,
    equal,
    semicolon,
    Colon,

    // One or two character tokens
    Walrus,

    // Binart operators
    plus,
    star,
    slash,
    caret,
    mod,

    // Unary operators
    minus,
    not,

    // Comparison operators
    less,
    greater,
    lessEqual,
    greaterEqual,
    equalEqual,

    // Literals
    Identifier,
    Number,

    // Keywords
    Var,
    Fn,
    If,
    Else,

    // Types
    Int,
    Float,
    String,
    Bool,
    NUll,

    // Error and end of file
    Error,
    Start,
    Eof,
};
