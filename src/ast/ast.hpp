#pragma once

#include <iostream>
#include <string>

enum NodeKind {
    // Expressions
    ND_NUMBER,
    ND_IDENT,
    ND_STRING,
    ND_BINARY,
    ND_UNARY,
    ND_GROUP,
    ND_ASSIGN,

    // Statements
    ND_EXPR_STMT,
    ND_VAR_STMT,
    ND_PROGRAM,

    // Types
    ND_SYMBOL_TYPE,
    ND_ARRAY_TYPE,
};

class Node {
public:
    struct Expr {
        NodeKind kind;
        virtual void debug(int ident = 0) const = 0;
        virtual ~Expr() = default; 
    };

    struct Stmt {
        NodeKind kind;
        virtual void debug() const = 0;
        virtual ~Stmt() = default;
    };

    struct Type {
        NodeKind kind;
        virtual void debug() const = 0;
        virtual ~Type() = default;
    };

    static void printIdent(int ident) {
        if (ident == 0) {
            std::cout << "";
        } else {
            for (int i = 0; i < ident; i++) {
                std::cout << "    ";
            }
        }
    }
};
 