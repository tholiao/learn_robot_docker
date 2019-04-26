# location of boost headers:
    BOOST_INCLUDEPATH = "/boost_1_67_0"    # (e.g. MacOS)

# location of lua headers:
    LUA_INCLUDEPATH = "/lua/include"    # (e.g. Ubuntu)

# lua libraries to link:
    LUA_LIBS = -L"/lua" -llua5.1    # (e.g. Ubuntu)

# qscintilla location:
    QSCINTILLA_DIR = "/QScintilla-gpl-2.7.2"    # (e.g. Ubuntu)

# qscintilla headers:
    QSCINTILLA_INCLUDEPATH = "$${QSCINTILLA_DIR}/include" "$${QSCINTILLA_DIR}/Qt4Qt5"

# qscintilla libraries to link:
    QSCINTILLA_LIBS = "$${QSCINTILLA_DIR}/release/release/qscintilla2.lib"    # (e.g. Windows)
    #QSCINTILLA_LIBS = "$${QSCINTILLA_DIR}/release/release/libqscintilla2.dll.a"    # (e.g. Windows-MSYS2)
    #QSCINTILLA_LIBS = "$${QSCINTILLA_DIR}/release/libqscintilla2.so"    # (e.g. Ubuntu)
    #QSCINTILLA_LIBS = "$${QSCINTILLA_DIR}/release/libqscintilla2.9.0.2.dylib"    # (e.g. MacOS)

# Make sure if a config.pri is found one level above, that it will be used instead of this one:
    exists(../config.pri) { include(../config.pri) }
