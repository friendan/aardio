#ifndef _STDBOOL_H
#define _STDBOOL_H

/* believe it or not but the Single Unix Specification actually
* specifies this header, see
* http://www.opengroup.org/onlinepubs/007904975/basedefs/stdbool.h.html */

#ifndef __cplusplus

#define __bool_true_false_are_defined 1

#define true 1
#define false 0

#define bool _Bool

#if defined(_MSC_VER) && (_MSC_VER < 1900)
typedef int  _Bool;
#endif

#endif

#endif