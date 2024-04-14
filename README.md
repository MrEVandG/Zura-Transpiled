This is the compiled low-level version of Zura.

## Introduction
Zura is a statically typed, compiled, low-level programming language. It is designed to be simple and easy to use. It is inspired by C and Go. It is currently in development and is not ready for production use.

tabe of contents:
- [Installation](#installation)
- [Usage](#usage)
- [Examples of Zura code](sample/SAMPLE.MD)


## Installation
To start make sure you have the following installed:
- [zig](https://ziglang.org/download/)

For Nixos-Configuration:
```bash
environment.systemPackages = [
    pkgs.zig
  ];
```

For Nixos-Shell:
```bash
nix-shell -p zig
```

Run the following commands:
```bash
zig build-exe src/main.zig --name zura
```

Or you can run the following command:
This will creat obj files and then link them to create the zura executable.
All of the obj files will be stored in the `obj` directory.
```bash
chmod a+x build.sh 
./build.sh linux
```

This will create a `zura` executable in the `src` directory.

Or you can download the latest release from [here](https://github.com/TheDevConnor/Zura-Transpiled/releases/tag/pre-release) and add either the `zura.exe` (For Windows) or `zura` (For Linux) executable to your path.
Eventually, I will add a script to automate this process.

## Usage
```bash
zura [build || run] <filename.zu>
```

Change the output name of the exacutable:
```bash
zura [build || run] <filename.zu> -name <output name>
```

Save the exacutable to a given path:
```bash
zura [build || run] <filename.zu> -s <path>
```

if you wish to save the asm code to a file, use the `-sAll` flag:
```bash
zura [build || run] <filename.zu> -s
```

if you want to clean up the build directory, use the `-c` flag:
```bash
zura -c <exactable name>
```

Then run the output file with:
```bash
./<output name>
```

## Example of syntax and errors
not yet down

## Command that you can run
```bash 
zura -v
```
This command will show you all of the commands that you can run in the zura compiler.
