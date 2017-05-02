#ifdef DECAF_METAL

#include "metal_unimplemented.h"

#include <string>
#include <vector>

namespace metal
{
    static std::vector<std::string> unimplemented_functions;
    
    void unimplemented(const char *name)
    {
        const std::string name_str(name);
        if (std::find(unimplemented_functions.begin(), unimplemented_functions.end(), name_str) == unimplemented_functions.end())
        {
            unimplemented_functions.push_back(name);
        }
    }
}

#endif // DECAF_METAL
