//
//  WalleetRepository.m
//  wallet
//
//  Created by Future Simple on 9/20/12.
//  Copyright (c) 2012 Natalia Terlecka. All rights reserved.
//

#import "WalleetRepository.h"

#import "WalleetUserData.h"
#import "WalleetGroup.h"

#define WALEETT_DOMAIN @"http://sandbox.walleet.com/api/v1/"

@implementation WalleetRepository

- (void)createUserWithEmail:(NSString *)email andPassword:(NSString *)password;
{
    NSURL *url = [NSURL URLWithString:@"http://sandbox.walleet.com/api/v1/person.json"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"" parameters:nil];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // prepare request body
    NSMutableDictionary *personDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
    [personDictionary setValue:email forKey:@"email"];
    [personDictionary setValue:password forKey:@"password"];
    NSMutableDictionary *requestBodyDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    [requestBodyDictionary setValue:personDictionary forKey:@"person"];
    
    // "email\":\"aaa@example.com\", \"password\":\"test123\"}}";
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:requestBody];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *dictionary = (NSDictionary *)responseObject;
         NSString *token = [dictionary objectForKey:@"api_token"];
         
         // save user credentials
         [WalleetUserData sharedInstance].userEmail = email;
         [WalleetUserData sharedInstance].userPassword = password;
         [WalleetUserData sharedInstance].userToken = token;
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
     }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
}

- (void)getUserForEmail:(NSString *)email andPassword:(NSString *)password successBlock:(void(^)(void))successBlock
{
    NSURL *url = [NSURL URLWithString:@"http://sandbox.walleet.com/api/v1/person/sign_in.json"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"" parameters:nil];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // prepare request body
    NSMutableDictionary *personDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
    [personDictionary setValue:email forKey:@"email"];
    [personDictionary setValue:password forKey:@"password"];
    NSMutableDictionary *requestBodyDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    [requestBodyDictionary setValue:personDictionary forKey:@"person"];
    
    // "email\":\"aaa@example.com\", \"password\":\"test123\"}}";
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:requestBody];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        NSString *token = [dictionary objectForKey:@"api_token"];
    
        // save user credentials
        [WalleetUserData sharedInstance].userEmail = email;
        [WalleetUserData sharedInstance].userPassword = password;
        [WalleetUserData sharedInstance].userToken = token;
        
        successBlock();
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
    }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
}

- (void)getUserAccount
{
    NSURL *url = [NSURL URLWithString:@"http://sandbox.walleet.com/api/v1/person.json"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:@"" parameters:nil];
    [request addValue:[WalleetUserData sharedInstance].userToken forHTTPHeaderField:@"X-Api-Token"];
    [request addValue:@"iOS" forHTTPHeaderField:@"X-Api-Client"];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         // Nothing to do
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
}


- (void)getGroupsWithSuccessBlock:(GroupsSuccessBlock)successBlock
{
    NSURL *url = [NSURL URLWithString:@"http://sandbox.walleet.com/api/v1/groups.json"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:@"" parameters:nil];
    [request addValue:[WalleetUserData sharedInstance].userToken forHTTPHeaderField:@"X-Api-Token"];
    [request addValue:@"iOS" forHTTPHeaderField:@"X-Api-Client"];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
    {
        NSMutableArray *groupArray = [[NSMutableArray alloc] initWithCapacity:[responseObject count]];
        
        NSArray *itemArray = [responseObject objectForKey:@"items"];
        
        [itemArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             NSDictionary *walleetGroupDictionary = [obj valueForKey:@"group"];
             WalleetGroup *group = [[WalleetGroup alloc] init];
             group.name = [walleetGroupDictionary objectForKey:@"name"];
             group.serverID = [[walleetGroupDictionary objectForKey:@"id"] integerValue];
             [groupArray addObject:group];
         }];
        
        NSLog(@"%@", groupArray);
        successBlock(groupArray);
     }
      failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
    
    [httpClient enqueueHTTPRequestOperation:operation];   
}

- (void)translateToGroupsFromResponse:(NSDictionary *)responseDictionary
{

}

@end
