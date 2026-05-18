# lexbor: Build and Installation

To build and install the `lexbor` library from source code, use [CMake] (open-source, cross-platform build system).

## GNU Make (module static archives)

The repository now includes a top-level `Makefile` for GNU Make that builds each
Lexbor module into its own static archive (`.a`).

In the project root:
```bash
make -j16
```

Useful overrides:

```bash
make TOPSRC=/path/to/lexbor CC=gcc AR=ar RANLIB=ranlib \
     CFLAGS="-O2" CPPFLAGS="-D_FORTIFY_SOURCE=2" LDFLAGS=""
```

Default target:

* `all` — builds all module archives.

Install:

```bash
make PREFIX=/usr/local DESTDIR=/tmp/pkg install
```

This installs headers into `DESTDIR/PREFIX/include` and archives into
`DESTDIR/PREFIX/lib` (or `DESTDIR/LIBDIR` when `LIBDIR` is overridden).

Optional non-default targets:

* `tests` (or `test`) — configures and builds tests with CMake
* `examples` — configures and builds examples with CMake
* `benchmarks` — configures and builds benchmarks with CMake
* `project-utils` — configures and builds helper utilities with CMake

Clean generated objects and archives:

```bash
make clean
```

## CMake (Linux, *BSD, Mac OS X)

In root directory of project (`/`):
```bash
cmake .
make
sudo make install
```

Flags that can be passed to cmake:

| Flags | Default | Description |
|---|:---:|---|
|`LEXBOR_OPTIMIZATION_LEVEL`| -O2 |   |
|`LEXBOR_C_FLAGS`|  | Default compilation flags to be used when compiling `C` files.<br>See `port.cmake` files in [ports](https://github.com/lexborisov/lexbor/tree/master/source/lexbor/ports) directory.|
|`LEXBOR_WITHOUT_THREADS`| ON | Not used now, for the future |
|`LEXBOR_BUILD_SHARED`| ON | Create shaded library |
|`LEXBOR_BUILD_STATIC`| ON | Create static library |
|`LEXBOR_INSTALL_HEADERS`| ON | The header files will be installed if set to ON |
|`LEXBOR_BUILD_TESTS`| OFF | Build tests |
|`LEXBOR_BUILD_EXAMPLES`| OFF | Build examples |

## Windows

Use the [CMake] GUI.

For Windows with MSYS: 
```bash
cmake . -G "Unix Makefiles"
make
make install
```

## Examples

All examples work from created `build` directory in the root directory of project:
```bash
mkdir build
cd build
```

I recommend creating a separate directory to build the project. It can be easily removed together with all garbage.

Build together with tests:

```bash
cmake .. -DLEXBOR_BUILD_TESTS=ON
make
make test
sudo make install
```

Set the installation location (prefix):

```bash
cmake .. -DCMAKE_INSTALL_PREFIX=/my/path/usr
make
make install
```

Installation only shared library (without headers):

```bash
cmake .. -DLEXBOR_BUILD_STATIC=OFF -DLEXBOR_INSTALL_HEADERS=OFF 
make
sudo make install
```


[CMake]: https://cmake.org/
