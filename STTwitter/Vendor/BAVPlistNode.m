//
//  BAVPlistNode.m
//  Plistorious
//
//  Created by Bavarious on 01/10/2013.
//  Copyright (c) 2013 No Organisation. All rights reserved.
//

#import "BAVPlistNode.h"


static NSString *typeForObject(id object) {
    if ([object isKindOfClass:[NSArray class]])
        return @"Array";
    else if ([object isKindOfClass:[NSDictionary class]])
        return @"Dictionary";
    else if ([object isKindOfClass:[NSString class]])
        return @"String";
    else if ([object isKindOfClass:[NSData class]])
        return @"Data";
    else if ([object isKindOfClass:[NSDate class]])
        return @"Date";
    else if (object == (id)kCFBooleanTrue || object == (id)kCFBooleanFalse)
        return @"Boolean";
    else if ([object isKindOfClass:[NSNumber class]])
        return @"Number";

    return @"Unknown";
}

static NSString *formatItemCount(NSUInteger count) {
    return (count == 1 ? @"1 item" : [NSString stringWithFormat:@"%lu items", count]);
}


@implementation BAVPlistNode

+ (instancetype)plistNodeFromObject:(id)object key:(NSString *)key
{
    BAVPlistNode *newNode = [BAVPlistNode new];
    newNode.key = key;
    newNode.type = typeForObject(object);

    if ([object isKindOfClass:[NSArray class]]) {
        NSArray *array = object;

        NSMutableArray *children = [NSMutableArray new];
        NSUInteger elementIndex = 0;
        for (id element in array) {
            NSString *elementKey = [NSString stringWithFormat:@"Item %lu", elementIndex];
            [children addObject:[self plistNodeFromObject:element key:elementKey]];
            elementIndex++;
        }

        newNode.value = formatItemCount(array.count);
        newNode.children = children;
    }
    else if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = object;
        NSArray *keys = [dictionary.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

        NSMutableArray *children = [NSMutableArray new];
        for (NSString *elementKey in keys)
            [children addObject:[self plistNodeFromObject:dictionary[elementKey] key:elementKey]];

        newNode.value = formatItemCount(keys.count);
        newNode.children = children;
    }
    else {
        newNode.value = [NSString stringWithFormat:@"%@", object];
    }
    
    return newNode;
}

- (bool)isCollection
{
    return [self.type isEqualToString:@"Array"] || [self.type isEqualToString:@"Dictionary"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ node with key %@", self.type, self.key];
}

@end
