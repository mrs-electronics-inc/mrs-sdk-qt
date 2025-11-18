# The `mrs-sdk-qt` Library

Here are the steps for compiling and installing the library.

NOTE: You will need to have Qt5 installed before you can compile.

1. Open the CMake project in Qt Creator.
2. Compile the project.
3. Install the SDK in the following structure:

```
HOME/
└── MRS-SDK-Qt/
    ├── lib/                    # Compiled static library
    |   └── libmrs-sdk-qt.a     
    ├── include/                # Header files
    |   └── Application.hpp
    └── builder/                # CMake and QMake configurations
        ├── mrs-sdk-qt.cmake
        └── mrs-sdk-qt.pri
```

At some point we will create a better system for auto-install but we don't have one yet.
