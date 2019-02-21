//
//  Note.m
//  modelbase
//
//  Created by HamGuy on 6/28/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "Note.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

@implementation Note

@dynamic noteinfo;
@dynamic index;
@dynamic ablumid;

+(NSArray *)allNotesIn:(NSString *)ablumId{
    NSArray *array =[Note MR_findByAttribute:@"ablumid" withValue:ablumId];
    if (array == nil) {
        array = @[];
    }
    return array;
}

+(Note *)noteAtIndex:(int)index{
    NSArray *notes = [Note MR_findByAttribute:@"index" withValue:[NSNumber numberWithInt:index]];
    if (notes && notes.count>0) {
        return notes[0];
    }
    return nil;
}

@end
