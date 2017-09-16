#import "HttpClient.h"
@interface HttpClient () <NSURLSessionDelegate>

@end

@implementation HttpClient

static HttpClient *instance = nil;

- (NSMutableURLRequest *) getRequest: (NSString *)strUrl
{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    [request setValue:APPLICATION_JSON forHTTPHeaderField:CONTENT_TYPE];
    [request setValue:APPLICATION_JSON forHTTPHeaderField:ACCEPT];
//    [request setValue:[Api webViewUA] forHTTPHeaderField:@"User-Agent"];
    return request;
}

- (void) asynGet: (NSString *)strUrl success:(Success) success error:(Error) error
{
    [self asyn:[self getRequest:strUrl] success:success error:error];
}

- (id) synGet: (NSString *)strUrl
{
    return [self syn: [self getRequest:strUrl]];
}

- (id) syn: (NSMutableURLRequest *)request
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSError *connectionError;
    __block NSURLResponse *response;
    __block NSData *data;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *taskResponse, NSError *taskConnectionError)
    {
        connectionError = taskConnectionError;
        response = taskResponse;
        data = taskData;
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return [self process:response connectionError:connectionError data:data];
}

-(void) asyn: (NSMutableURLRequest *)request success:(Success) success error:(Error) error
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError)
    {
        id result = [self process:response connectionError:connectionError data:data];
        if (result)
        {
            success(result);
        }
        else
        {
            if (error)
            {
                error();
            }
        }
    }];
    
    [dataTask resume];
}

- (void) asynPost: (NSString *)strUrl data:(NSDictionary *)data success:(Success) success error:(Error) error
{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [request setHTTPMethod:@"POST"];
//    [request setValue:[Api webViewUA] forHTTPHeaderField:@"User-Agent"];
    [request setValue:APPLICATION_JSON forHTTPHeaderField:CONTENT_TYPE];
    [request setValue:APPLICATION_JSON forHTTPHeaderField:ACCEPT];
    
    [self asynP:request data:data success:success error:error];
}

- (void) asynP: (NSMutableURLRequest *)request data:(NSDictionary *)data success:(Success) success error:(ErrorWithResponse) error
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    
    [self asynPWithData:request data:jsonData success:success error:error];
}

- (void) asynPWithData: (NSMutableURLRequest *)request data:(NSData *)data success:(Success) success error:(ErrorWithResponse) error
{
    request.HTTPBody = data;
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError)
                                      {
                                          id result = [self process:response connectionError:connectionError data:data];
                                          if (result)
                                          {
                                              success(result);
                                          }
                                          else
                                          {
                                              if (error)
                                              {
                                                  error(response, connectionError);
                                              }
                                          }
                                      }];
    [dataTask resume];
}


- (id) process: (NSURLResponse*)response connectionError:(NSError*)connectionError data:(NSData*)data
{
    id result = nil;
    NSInteger statusCode = 0;
    if (!connectionError)
    {
        statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode >= 200 && statusCode < 400)
        {
            NSError * error;
            id resultData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (!error && resultData)
            {
                result = resultData;
            }
        }
    }
    return result;
}

+ (instancetype) sharedInstance
{
    @synchronized (self)
    {
        if (!instance)
        {
            instance = [[HttpClient alloc] init];
        }
    }
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (!instance)
        {
            instance = [super allocWithZone:zone];
        }
    }
    return instance;
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return instance;
}

@end
