//
//  AppDelegate.h
//  Object Manager
//
//  Created by tropic on 03/11/13.
//  Copyright (c) 2013 Wauw. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <mach/mach.h>
#include <Security/Authorization.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    int _selectedPID;
    kern_return_t kern_return;
    mach_port_t task;
    mach_vm_size_t outsize;

    IBOutlet NSTextField *wauwPID;
    IBOutlet NSTextField *wauwOffset;
    IBOutlet NSTextField *statusMessage;
    IBOutlet NSArrayController *objectArrayWindowController;
    
    IBOutlet NSButton *filterNPCs;
    IBOutlet NSButton *filterPlayers;
    IBOutlet NSButton *filterNodes;
}

- (IBAction)attachMemory:(id)sender;
- (IBAction)refreshData:(id)sender;




@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
@end
