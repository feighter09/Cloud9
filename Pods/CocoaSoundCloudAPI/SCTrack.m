//
//  SCTrack.m
//  Pods
//
//  Created by Austin Feight on 7/11/15.
//
//

#import "SCTrack.h"

@interface SCTrack ()

@property (strong, readonly, nonatomic) NSDictionary *jsonData;

@end

@implementation SCTrack

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
  if ((self = super.init)) {
    _jsonData = dictionary;
  }
  
  return self;
}

#pragma mark - Properties

- (NSString *)title
{
  return _jsonData[@"origin"][@"title"];
}

- (NSURL *)artwork_url
{
  NSString *urlString = _jsonData[@"origin"][@"artwork_url"];
  return [NSURL URLWithString:urlString];
}

@end
