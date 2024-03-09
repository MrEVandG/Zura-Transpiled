const AstNode = struct {
    name: []const u8,
    children: []AstNode,
};

// STMTS
const StmtKind = enum {
    VarDeclStmt,
    ErrorStmt,
};

const Stmt = struct {
    node: AstNode,
    kind: StmtKind,
};

const VarDeclStmt = struct {
    node: AstNode,
    kind: StmtKind,
    name: []const u8,
    type: []const u8,
};

const ErrorStmt = struct {
    node: AstNode,
    kind: StmtKind,
    message: []const u8,
};

// EXPRS
const ExprKind = enum {
    NumberExpr,
    StringExpr,
    IdentExpr,
};

const Expr = struct {
    node: AstNode,
    kind: ExprKind,
};

const NumberExpr = struct {
    node: AstNode,
    kind: ExprKind,
    value: i64,
};

const StringExpr = struct {
    node: AstNode,
    kind: ExprKind,
    value: []const u8,
};

const IdentExpr = struct {
    node: AstNode,
    kind: ExprKind,
    name: []const u8,
};

// TYPES
const TypeKind = enum {
    IntType,
    FloatType,
    StringType,
};

const Type = struct {
    node: AstNode,
    kind: TypeKind,
};

const IntType = struct {
    node: AstNode,
    kind: TypeKind,
};

const FloatType = struct {
    node: AstNode,
    kind: TypeKind,
};

const StringType = struct {
    node: AstNode,
    kind: TypeKind,
};

// initializers
pub fn initVarDeclStmt(node: AstNode, kind: StmtKind, name: []const u8, _type: []const u8) VarDeclStmt {
    return VarDeclStmt{ node, kind, name, _type };
}

pub fn initErrorStmt(node: AstNode, kind: StmtKind, message: []const u8) ErrorStmt {
    return ErrorStmt{ node, kind, message };
}

pub fn initNumberExpr(node: AstNode, kind: ExprKind, value: i64) NumberExpr {
    return NumberExpr{ node, kind, value };
}

pub fn initStringExpr(node: AstNode, kind: ExprKind, value: []const u8) StringExpr {
    return StringExpr{ node, kind, value };
}

pub fn initIdentExpr(node: AstNode, kind: ExprKind, name: []const u8) IdentExpr {
    return IdentExpr{ node, kind, name };
}

pub fn initIntType(node: AstNode, kind: TypeKind) IntType {
    return IntType{ node, kind };
}

pub fn initFloatType(node: AstNode, kind: TypeKind) FloatType {
    return FloatType{ node, kind };
}

pub fn initStringType(node: AstNode, kind: TypeKind) StringType {
    return StringType{ node, kind };
}
