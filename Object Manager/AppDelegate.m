//
//  AppDelegate.m
//  Object Manager
//
//  Created by tropic on 03/11/13.
//  Copyright (c) 2013 Wauw. All rights reserved.
//

#import "AppDelegate.h"
#import <mach/vm_map.h>
#import <mach/mach_traps.h>
#import <mach/mach.h>
#import <mach/mach_vm.h>
#include <Security/Authorization.h>

// OBJECT MANAGER BASEADDRESS
#define objMgrPointer               0x16D594C
#define firstObject                 0xCC

// GENERAL OFFSETS
#define objectTypeOffset            0xC
#define objecGUIDOffset             0x24
#define previousObjectOffset        0x2C
#define nextObjectOffset            0x30

// WOWObject
#define objectNodePositionXOffset   0xE8
#define objectNodePositionYOffset   objectNodePositionXOffset+4
#define objectNodePositionZOffset   objectNodePositionYOffset+4

// WoWUnit
#define WoWUnitLevelOffset          0x0
#define WoWUnitCurrentHealthOffset  0x0
#define WoWUnitMaxHealthOffset      0x0
#define WoWUnitCurrentManaOffset    0x0
#define WoWUnitMaxManaOffset        0x0

#define objectPositionXOffset       0x828
#define objectPositionYOffset       objectPositionXOffset+4
#define objectPositionZOffset       objectPositionYOffset+4



@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    // ADD DATA TO TABLE VIEW
    [objectArrayWindowController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            @"no data yet", @"guid",
                                            @"no data yet", @"objectType",
                                            @"no data yet", @"distance",
                                            nil]];
}

#pragma mark - Object Manager

- (IBAction)attachMemory:(id)sender {
    // GET PID FROM TEXTFIELD
    _selectedPID = [wauwPID intValue];
    // PRINT TO LOG
    [statusMessage setStringValue:[NSString stringWithFormat:@"Selected PID: %i",_selectedPID]];
    NSLog(@"PID: %i",_selectedPID);
    
    // MEMORY ACCESS
//    kern_return_t kern_return;
//    mach_port_t task;
    kern_return = task_for_pid(mach_task_self(), _selectedPID, &task);

    // FAILED
    if (kern_return!=KERN_SUCCESS)
    {
        [statusMessage setStringValue:@"Permission Failure."];
        NSLog(@"Permission Failure, kern_return: %d",kern_return);
        // RETURN IF FAIL
        return;
    }
    // SUCCESS
    if (kern_return==KERN_SUCCESS) {
        [statusMessage setStringValue:@"Success, we have access."];
        NSLog(@"Success, we have access.");
    }
    
}

- (IBAction)refreshData:(id)sender {
    // GET PID FROM TEXTFIELD
    _selectedPID = [wauwPID intValue];
    // PRINT TO LOG
    [statusMessage setStringValue:[NSString stringWithFormat:@"Selected PID: %i",_selectedPID]];
    NSLog(@"PID: %i",_selectedPID);
    
    // MEMORY ACCESS
    //    kern_return_t kern_return;
    //    mach_port_t task;
    kern_return = task_for_pid(mach_task_self(), _selectedPID, &task);
    
    // FAILED
    if (kern_return!=KERN_SUCCESS)
    {
        [statusMessage setStringValue:@"Permission Failure."];
        NSLog(@"Permission Failure, kern_return: %d",kern_return);
        // RETURN IF FAIL
        return;
    }
    // SUCCESS
    if (kern_return==KERN_SUCCESS) {
        [statusMessage setStringValue:@"Success, we have access."];
        NSLog(@"Success, we have access.");
    }
    
    //////////////////////
    // CHECK MEMORY ACCESS
//    if (kern_return!=KERN_SUCCESS)
//    {
//        // PRINT TO LOG
//        [statusMessage setStringValue:@"Permission Failure."];
//        NSLog(@"Permission Failure, kern_return: %d",kern_return);
//        // RETURN IF FAIL
//        return;
//    }
    
    //////////////
    // FOR TESTING
    // INITIALIZATION
    uint32_t value32 = 0;
    unsigned long long offset;
    // READ HEX ADDRESS FROM TEXTFIELD, CONVERT STRING TO HEX
    NSScanner *scanner = [NSScanner scannerWithString:[wauwOffset stringValue]];
    [scanner scanHexLongLong:&offset];
    // READ THE VALUE AT THE USER-SPECIFIED MEMORY ADDRESS
    kern_return = mach_vm_read_overwrite(task, offset, 4, (mach_vm_address_t)&value32, &outsize);
    // PRINT TO LOG
    NSLog(@"Value at address %@: %i",[wauwOffset stringValue], value32);
    // TESTING ENDS
    
    ///////////////////////////////////////////////////
    // REMOVE ALL DATA IN THE OBJECT MANAGER TABLE VIEW
    [[objectArrayWindowController content] removeAllObjects];
    // 'REARRANGE' TO MAKE THE UI UPDATE IMMEDIATELY
    [objectArrayWindowController rearrangeObjects];

    // GET OBJECT MANAGER BASEADDRESS
    int objMgrBaseAddress;
    mach_vm_read_overwrite(task, objMgrPointer, 4, (mach_vm_address_t)&objMgrBaseAddress, &outsize);
    NSLog(@"Object Manager baseaddress: 0x%x",objMgrBaseAddress);
    
    // GET FIRST OBJECT BASEADDRESS
    int firstObjectPointer = objMgrBaseAddress + firstObject;
    int firstObjectBaseAddress;
    mach_vm_read_overwrite(task, firstObjectPointer, 4, (mach_vm_address_t)&firstObjectBaseAddress, &outsize);
    NSLog(@"First object baseaddress: 0x%x",firstObjectBaseAddress);

    // LOOP THROUGH OBJECTS
    int objectTypeValue;
    long int objectGUIDValue;
    float objectPositionXValue;
    float objectPositionYValue;
    float objectPositionZValue;


    for (int i=1; i < 1000; i++) {
        // READ MEMORY
        mach_vm_read_overwrite(task, firstObjectBaseAddress+objectTypeOffset,      4, (mach_vm_address_t)&objectTypeValue, &outsize);
        mach_vm_read_overwrite(task, firstObjectBaseAddress+objecGUIDOffset,       8, (mach_vm_address_t)&objectGUIDValue, &outsize);
        mach_vm_read_overwrite(task, firstObjectBaseAddress+objectPositionXOffset, 4, (mach_vm_address_t)&objectPositionXValue, &outsize);
        mach_vm_read_overwrite(task, firstObjectBaseAddress+objectPositionYOffset, 4, (mach_vm_address_t)&objectPositionYValue, &outsize);
        mach_vm_read_overwrite(task, firstObjectBaseAddress+objectPositionZOffset, 4, (mach_vm_address_t)&objectPositionZValue, &outsize);
        
        // FILTER RESULTS
//        NSLog(@"-----------------------");
//        NSLog(@"Object type: %i",objectTypeValue);
//        NSLog(@"Object memory address: 0x%x",firstObjectBaseAddress);
//        NSLog(@"Object GUID: 0x%02lx", (long int) objectGUIDValue);
//        NSLog(@"Object position: x:%f, y:%f, z:%f",objectPositionXValue, objectPositionYValue, objectPositionZValue);
        
        // PARSE (3) NPC DATA
        if (objectTypeValue == 3 && [filterNPCs state] == NSOnState) {
            // READ MEMORY
            mach_vm_read_overwrite(task, firstObjectBaseAddress+objectPositionXOffset, 4, (mach_vm_address_t)&objectPositionXValue, &outsize);
            mach_vm_read_overwrite(task, firstObjectBaseAddress+objectPositionYOffset, 4, (mach_vm_address_t)&objectPositionYValue, &outsize);
            mach_vm_read_overwrite(task, firstObjectBaseAddress+objectPositionZOffset, 4, (mach_vm_address_t)&objectPositionZValue, &outsize);
            // ADD OBJECT TO TABLE VIEW
            [objectArrayWindowController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    
                                                    [NSString stringWithFormat:@"0x%02lx", (long int) objectGUIDValue], @"guid",
                                                    [NSString stringWithFormat:@"%i",objectTypeValue],                  @"objectType",
                                                    @"no data yet",                                                     @"distance",
                                                    nil]];
        }
        
        // PARSE (4) PLAYER DATA
        if (objectTypeValue == 4 && [filterPlayers state] == NSOnState) {
            // READ MEMORY
            mach_vm_read_overwrite(task, firstObjectBaseAddress+objectPositionXOffset, 4, (mach_vm_address_t)&objectPositionXValue, &outsize);
            mach_vm_read_overwrite(task, firstObjectBaseAddress+objectPositionYOffset, 4, (mach_vm_address_t)&objectPositionYValue, &outsize);
            mach_vm_read_overwrite(task, firstObjectBaseAddress+objectPositionZOffset, 4, (mach_vm_address_t)&objectPositionZValue, &outsize);
            // ADD OBJECT TO TABLE VIEW
            [objectArrayWindowController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    
                                                    [NSString stringWithFormat:@"0x%02lx", (long int) objectGUIDValue], @"guid",
                                                    [NSString stringWithFormat:@"%i",objectTypeValue],                  @"objectType",
                                                    @"no data yet",                                                     @"distance",
                                                    nil]];
        }

        // PARSE (5) GAMEOBJECT (NODE) DATA
        if (objectTypeValue == 5 && [filterNodes state]   == NSOnState) {
            // READ MEMORY
            mach_vm_read_overwrite(task, firstObjectBaseAddress + objectNodePositionXOffset, 4, (mach_vm_address_t)&objectPositionXValue, &outsize);
            mach_vm_read_overwrite(task, firstObjectBaseAddress + objectNodePositionYOffset, 4, (mach_vm_address_t)&objectPositionYValue, &outsize);
            mach_vm_read_overwrite(task, firstObjectBaseAddress + objectNodePositionZOffset, 4, (mach_vm_address_t)&objectPositionZValue, &outsize);
            // ADD OBJECT TO TABLE VIEW
            [objectArrayWindowController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    
                                                    [NSString stringWithFormat:@"0x%02lx", objectGUIDValue],            @"guid",
                                                    [NSString stringWithFormat:@"%i",objectTypeValue],                  @"objectType",
                                                    @"no data yet",                                                     @"distance",
                                                    nil]];
        }
        
        // GET POINTER FOR NEXT OBJECT
        mach_vm_read_overwrite(task, firstObjectBaseAddress+nextObjectOffset, 4, (mach_vm_address_t)&firstObjectBaseAddress, &outsize);

        // IF POINTER IS = 0, THEN RETURN (MEANS THERE ARE NO MORE OBJECTS IN MEMORY)
        if (firstObjectBaseAddress == 0x0 ) {
            NSLog(@"Return, no more objects");
            NSLog(@"Total objects found: %i", i);
            return;
        }
    }
    
    // build new array with objects
    // remove all objects from array?
    // reload data in tableview
    
    
//    while ((objectListPtr != 0)  && ((objectListPtr & 1) == 0) ) {
//		row++;
//		[memory loadDataForObject: self atAddress: (objectListPtr) Buffer:(Byte*)&cd BufLength: sizeof(cd)];
//        
//        
//        long realCD = cd.cooldown;
//		if (  cd.cooldown2 > cd.cooldown )
//			realCD =  cd.cooldown2;
//		
//		long realStartTime = cd.startTime;
//		if ( cd.startNotUsed > cd.startTime )
//			realStartTime = cd.startNotUsed;
//
//		// Save it!
//		[_playerCooldowns addObject: [NSDictionary dictionaryWithObjectsAndKeys:
//									  [NSNumber numberWithUnsignedLong: row],							@"ID",
//									  [NSNumber numberWithUnsignedLong: cd.spellID],					@"SpellID",
//									  [NSNumber numberWithUnsignedLong: realStartTime],					@"StartTime",
//									  [NSNumber numberWithUnsignedLong: realCD],                        @"Cooldown",
//									  [NSNumber numberWithUnsignedLong: cd.gcd],						@"GCD",
//									  [NSNumber numberWithUnsignedLong: cd.unk],						@"Unk",
//									  [NSNumber numberWithUnsignedLong: cd.unk3],						@"Unk3",
//									  [NSNumber numberWithUnsignedLong: cd.unk4],						@"Unk4",
//									  [NSNumber numberWithUnsignedLong: cd.unk5],						@"Unk5",
//									  [NSNumber numberWithUnsignedLong: cd.startTime],					@"OriginalStartTime",
//									  [NSNumber numberWithUnsignedLong: cd.startNotUsed],				@"StartNotUsed",
//									  [NSNumber numberWithUnsignedLong: cd.cooldown],					@"CD1",
//									  [NSNumber numberWithUnsignedLong: cd.cooldown2],					@"CD2",
//									  [NSNumber numberWithUnsignedLong: cd.enabled],					@"Enabled",
//									  
//									  nil]];
//		if ( reachedEnd )
//			break;
//		
//		objectListPtr = cd.nextObjectAddress;
//        
//		if ( objectListPtr == lastObjectPtr )
//			reachedEnd = YES;
//	}
//	
//	[cooldownPanelTable reloadData];

    
}

- (void)addWoWNPC:(int)objectBaseAddress {
    
}

- (void)addWoWGameObject:(int)objectBaseAddress {
    // INITIALIZATION
    int objectTypeValue;
    long int objectGUIDValue;
    float objectPositionXValue;
    float objectPositionYValue;
    float objectPositionZValue;
    
    // READ MEMORY
    mach_vm_read_overwrite(task, objectBaseAddress + objectTypeOffset,          4, (mach_vm_address_t)&objectTypeValue,      &outsize);
    mach_vm_read_overwrite(task, objectBaseAddress + objecGUIDOffset,           8, (mach_vm_address_t)&objectGUIDValue,      &outsize);
    mach_vm_read_overwrite(task, objectBaseAddress + objectNodePositionXOffset, 4, (mach_vm_address_t)&objectPositionXValue, &outsize);
    mach_vm_read_overwrite(task, objectBaseAddress + objectNodePositionYOffset, 4, (mach_vm_address_t)&objectPositionYValue, &outsize);
    mach_vm_read_overwrite(task, objectBaseAddress + objectNodePositionZOffset, 4, (mach_vm_address_t)&objectPositionZValue, &outsize);
    
    float distance = [self calculateDistance:objectPositionXValue yposition:objectPositionYValue zposition:objectPositionZValue];
    
    // ADD OBJECT TO TABLE VIEW
    [objectArrayWindowController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            
                                            [NSString stringWithFormat:@"0x%02lx", objectGUIDValue], @"guid",
                                            [NSString stringWithFormat:@"%i",objectTypeValue],       @"objectType",
                                            [NSString stringWithFormat:@"%.2f",distance],            @"distance",
                                            nil]];

}

- (float)calculateDistance:(float)XPosition yposition:(float)YPosition zposition:(float)ZPosition {
    // CALCULATE THE DISTANCE BETWEEN THE PLAYER AND A UNIT OR OBJECT
    float distance;
// NOTE! ADD PLAYER POSITION
    distance = sqrt(pow((XPosition - XPosition), 2.0) + pow((YPosition - YPosition), 2.0) + pow((ZPosition - ZPosition), 2.0));
    return distance;
}

#pragma mark - Other Stuff

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.wauw.Object_Manager" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.wauw.Object_Manager"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Object_Manager" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Object_Manager.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
