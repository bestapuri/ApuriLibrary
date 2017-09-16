#import <Foundation/Foundation.h>

typedef void(^Success)(id result);

typedef void(^ErrorWithResponse)(id result, NSError *error);

typedef void(^Error)();

@interface HttpClient : NSObject

+ (instancetype) sharedInstance;

- (id) synGet: (NSString *)strUrl;

- (void) asynGet: (NSString *)strUrl success:(Success) success error:(Error) error;

- (void) asynPost: (NSString *)strUrl data:(NSDictionary *)data success:(Success) success error:(Error) error;

- (void) asynP: (NSMutableURLRequest *)request data:(NSDictionary *)data success:(Success) success error:(ErrorWithResponse) error;

- (void) asynPWithData: (NSMutableURLRequest *)request data:(NSData *)data success:(Success) success error:(ErrorWithResponse) error;

@end

#define APPLICATION_JSON @"application/json"
#define APPLICATION_PNG @"image/png"
#define CONTENT_TYPE @"Content-Type"
#define ACCEPT @"Accept"
