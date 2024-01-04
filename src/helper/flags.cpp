#include <cstring>
#include <fstream>
#include <iostream>

#include "../parser/parser.hpp"
#include "../type/type.hpp"
#include "../ast/ast.hpp"
#include "../common.hpp"
#include "flags.hpp"

using namespace std;

void Flags::compilerDelete(char **argv) {
  cout << "Deleting the executable file" << endl;
  std::string outName = argv[2];
  char rmCommand[256];

#ifdef _WIN32
  strcat(rmCommand, "del ");
  strcat(rmCommand, outName.c_str());
  strcat(rmCommand, ".exe");
  strcat(rmCommand, " out.o out.asm");
  system(rmCommand);
#else
  strcat(rmCommand, "rm -rf ");
  strcat(rmCommand, outName.c_str());
  strcat(rmCommand, " out.o out.asm");
  system(rmCommand);
#endif
  Exit(ExitValue::FLAGS_PRINTED);
}

void Flags::compileToAsm(std::string name) {
  std::string buildCommand = "nasm -f elf64 -o out.o out.s";
  std::string compileCommand = "gcc -m64 -o " + name + " out.o -no-pie -fno-pie";
  system(buildCommand.c_str());
  system(compileCommand.c_str());
}

char *Flags::readFile(const char *path) {
  ifstream file(path, ios::binary);
  if (!file) {
    cerr << "Error: Could not open file '" << path << "'" << endl;
    Exit(ExitValue::INVALID_FILE);
  }

  file.seekg(0, ios::end);
  size_t size = file.tellg();
  file.seekg(0, ios::beg);

  char *buffer = new char[size + 1];
  file.read(buffer, size);
  file.close();

  buffer[size] = 0;
  return buffer;
}

void Flags::runFile(const char *path, std::string outName, bool save) {
  const char *source = readFile(path);

  Parser parser(source);
  AstNode *expression = parser.parse();

  expression->printAst(expression, 0);

  Type type(expression);
  type.typeCheck(expression);

  AstNode::codeGen(expression);
  compileToAsm(outName);

  if (!save) {
#ifdef _WIN32
    system("del out.s out.o");
#else
    system("rm -rf out.s out.o");
#endif
}

  delete[] source;
  delete expression;
}

void Flags::outputASMFile(const char *path) {
  const char *source = readFile(path);

  std::cout << "Generating the asm file" << std::endl;

  Parser parser(source);
  AstNode *expr = parser.parse();

  Type type(expr);
  type.typeCheck(expr);

  // TODO: Redo generation code
  // Gen gen(expr);

  delete[] source;
  delete expr;
}
