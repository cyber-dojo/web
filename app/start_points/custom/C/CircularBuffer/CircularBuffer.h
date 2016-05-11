//- Copyright (c) 2008-2014 James Grenning --- All rights reserved
//- For exclusive use by participants in Wingman Software training courses.
//- Cannot be used by attendees to train others without written permission.
//- www.wingman-sw.com james@wingman-sw.com

#ifndef CIRCULAR_BUFFER_INCLUDED
#define CIRCULAR_BUFFER_INCLUDED

struct  CircularBuffer;

struct CircularBuffer * CircularBuffer_Create(void);
void CircularBuffer_Destroy(struct CircularBuffer *);

#endif
