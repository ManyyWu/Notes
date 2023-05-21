# CMake

## vscode clangd支持
    使用idea生成compile_commands.json，复制到项目根目录
    
    CMAKE_EXPORT_COMPILE_COMMANDS选项仅支持ninja生成器和nmake Makefiles生成器，参考：
    https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html
    关于Makefile生成compile_commands.json，参考：
    https://github.com/rizsotto/Bear
