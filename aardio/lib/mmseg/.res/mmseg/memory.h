#ifndef _MEMORY_H_
#define _MEMORY_H_

#include <cstdlib>

/**
 * Pre-allocate a chunk of memory and allocate them in small pieces.
 * Those memory are never freed after allocation. Used for persist
 * data like dictionary contents that will never be destroyed unless
 * the application exited.
 */

namespace rmmseg
{
    const int REALLOC_SIZE = 2048; /* 2KB */

    extern int   _pool_size;
    extern char *_pool_base;

    inline void *pool_alloc(int len)
    {
        void *mem = _pool_base;
        
        if (len <= _pool_size)
        {
            _pool_size -= len;
            _pool_base += len;
            return mem;
        }
        
        /* NOTE: the remaining memory is simply discard, which WILL
         * cause memory leak. However, this function is not for allocating
         * large object. Larger pre-alloc chunk size will also reduce the
         * impact of this leak. So this is generally not a problem. */
        _pool_base = static_cast<char *>(std::malloc(REALLOC_SIZE));
        if (!_pool_base) {
            // Handle memory allocation failure
            return nullptr;
        }
        mem = _pool_base;
        _pool_base += len;
        _pool_size = REALLOC_SIZE - len;
        return mem;
    }
}

#endif /* _MEMORY_H_ */
