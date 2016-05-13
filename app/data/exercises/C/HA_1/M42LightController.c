//- Copyright (c) 2008-2014 James Grenning --- All rights reserved
//- For exclusive use by participants in Wingman Software training courses.
//- Cannot be used by attendees to train others without written permission.
//- www.wingman-sw.com james@wingman-sw.com



#include "M42LightController.h"

static uint32_t* lightControlAddress = 0;
static uint32_t lightControlState = 0;


void M42LightController_Create(uint32_t * address, uint32_t initialState)
{
    lightControlAddress = address;
    lightControlState = initialState;
}

void LightController_Destroy(void)
{
}

void LightController_On(int id)
{
    lightControlState |= ( 1 << (id-1));
    *lightControlAddress = lightControlState;
}

void LightController_Off(int id)
{
    lightControlState &=  ((1 << (id-1)) ^ 0xffffffff);
    *lightControlAddress = lightControlState;
}
