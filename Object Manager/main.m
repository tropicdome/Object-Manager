//
//  main.m
//  Object Manager
//
//  Created by tropic on 03/11/13.
//  Copyright (c) 2013 Wauw. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/foundation.h>
#import <SecurityFoundation/SFAuthorization.h>
#import <Security/AuthorizationTags.h>

bool amIWorthy(void);
void authMe(char * FullPathToMe);

int main(int argc, char *argv[])
{
	int uid = getuid();
	
	if (amIWorthy() || uid == 0)
	{
		NSLog(@"Don't forget to flush! ;-) "); // signal back to close caller
		fflush(stdout);
		
		return NSApplicationMain(argc,  (const char **) argv);
	}
	else
	{
		authMe(argv[0]);
		return 0;
	}
}

bool amIWorthy(void)
{
	// running as root?
	AuthorizationRef myAuthRef;
	OSStatus stat = AuthorizationCopyPrivilegedReference(&myAuthRef,kAuthorizationFlagDefaults);
    
	return stat == errAuthorizationSuccess;
}

void authMe(char * FullPathToMe)
{
	// get authorization as root
    
	OSStatus myStatus;
	
	// set up Authorization Item
	AuthorizationItem myItems[1];
	myItems[0].name = kAuthorizationRightExecute;
	myItems[0].valueLength = 0;
	myItems[0].value = NULL;
	myItems[0].flags = 0;
	
	// Set up Authorization Rights
	AuthorizationRights myRights;
	myRights.count = sizeof (myItems) / sizeof (myItems[0]);
	myRights.items = myItems;
	
	// set up Authorization Flags
	AuthorizationFlags myFlags;
	myFlags =
    kAuthorizationFlagDefaults |
    kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagExtendRights;
	
	// Create an Authorization Ref using Objects above. NOTE: Login bod comes up with this call.
	AuthorizationRef myAuthorizationRef;
	myStatus = AuthorizationCreate (&myRights, kAuthorizationEmptyEnvironment, myFlags, &myAuthorizationRef);
	
	if (myStatus == errAuthorizationSuccess)
	{
		// prepare communication path - used to signal that process is loaded
		FILE *myCommunicationsPipe = NULL;
		char myReadBuffer[] = " ";
        
		// run this app in GOD mode by passing authorization ref and comm pipe (asynchoronous call to external application)
		myStatus = AuthorizationExecuteWithPrivileges(myAuthorizationRef,FullPathToMe,kAuthorizationFlagDefaults,nil,&myCommunicationsPipe);
        
		// external app is running asynchronously - it will send to stdout when loaded
		if (myStatus == errAuthorizationSuccess)
		{
			read (fileno (myCommunicationsPipe), myReadBuffer, sizeof (myReadBuffer));
			fclose(myCommunicationsPipe);
		}
		
		// release authorization reference
		myStatus = AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDestroyRights);
	}
}
