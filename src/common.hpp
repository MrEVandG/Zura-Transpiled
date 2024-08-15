#pragma once
#include "helper/flags.hpp"
#include <stdlib.h>
#include <unordered_map>
#include <string>

inline std::string ZuraVersion = "";
inline std::string get_version(const char *path);

class FlagConfig {
public:
  static void print(int argc, char **argv);
  static void runBuild(int argc, char **argv);
};

enum ExitValue {
  BUILT = 0,
  INVALID_FILE_EXTENSION = 1,
  INVALID_FILE = 2,
  LEXER_ERROR = 3,
  PARSER_ERROR = 4,
  _ERROR = 5,
  GENERATOR_ERROR = 6,
  UPDATED = 7,
  INVALID_TYPE = 8,
  TYPE_ERROR = 9,
  BUILD_ERROR = 10,
  FLAGS_PRINTED = 11,
};

inline void Exit(ExitValue exitValue) { exit(ExitValue(exitValue)); }
inline FlagConfig flagConfig;