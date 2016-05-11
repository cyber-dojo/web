//- Copyright (c) 2008-2014 James Grenning --- All rights reserved
//- For exclusive use by participants in Wingman Software training courses.
//- Cannot be used by attendees to train others without written permission.
//- www.wingman-sw.com james@wingman-sw.com



#ifndef LIGHT_CONTROLLER_INCLUDED
#define LIGHT_CONTROLLER_INCLUDED

enum { MAX_LIGHTS = 32 };

void LightController_Create(void);
void LightController_Destroy(void);
void LightController_On(int id);
void LightController_Off(int id);

#endif
