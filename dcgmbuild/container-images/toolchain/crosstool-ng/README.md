Starting from the default configuration file, the following settings have been modified:

Paths and misc options:
    Try features marked as EXPERIMENTAL: checked
    Allow building as root user: checked
    Are you sure?: checked
    Local tarballs directory: /tmp/downloads/crosstool-ng
    Strip target toolchain executables: checked
    Forbid downloads: checked
    Progress bar: unchecked

Target options:
    Target Architecture: x86/arm
    Omit vendor part of the target tuple: checked
    Bitness: 64-bit

Toolchain options:
    Add crosstool-NG version to --version output: unchecked
    Enable nls: checked

Operating System:
    Target OS: linux
    Version of linux: 4.20.17

Binary utilities:
    Linkers to enable: ld, gold
    Enable threaded gold: checked
    Enable support for plugins: checked
    Enable -z relro in ELF linker by default: checked (make sure `*` shows)

C-library:
    Version of glibc: 2.27
    Flags (after Enable debug symbols): Remove all warning flags
    Minimum supported kernel version: Let ./configure decide

C compiler:
    Version of gcc: 14.3.0
    gcc extra config: `--with-glibc-version=2.27 --enable-default-ssp --enable-default-pie --with-specs='%{O*:%{!O0:-D_FORTIFY_SOURCE=3}} %{!r:%{!shared:-z relro}}'`
    Use system zlib: checked
    Enable Position Independent Executable as default: checked
    Compile libmudflap: checked
    Compile libgomp: checked
    Compile libquadmath: checked
    Compile libsanitizer: checked (make sure `*` shows)
    Enable build-id: checked
    linker hash style: both
    Additional supported languages: C++: checked

Debug facilities:
    expat: checked
    gdb: checked
        Cross-gdb: unchecked

Companion libraries:
    libelf: checked
