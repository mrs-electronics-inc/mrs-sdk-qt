#pragma once

// This class is merely for testing purposes.
// It will be removed once we have real code in the library.

class Application
{
public:
    Application();

#ifdef MRS_SDK_QT_TEST_MACRO
    void announce() const;
#endif
};
