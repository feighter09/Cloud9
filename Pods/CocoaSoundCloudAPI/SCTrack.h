//
//  SCTrack.h
//  Pods
//
//  Created by Austin Feight on 7/11/15.
//
//

#import <Foundation/Foundation.h>

@interface SCTrack : NSObject

@property (strong, readonly, nonatomic) NSString *title;
@property (strong, readonly, nonatomic) NSString *artist;
@property (strong, readonly, nonatomic) NSURL *artwork_url;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
