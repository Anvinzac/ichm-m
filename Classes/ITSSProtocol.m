//
//  ITSSProtocol.m
//  ichm
//
//  Created by Robin Lu on 7/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ITSSProtocol.h"
#import "CHMDocument.h"

@implementation ITSSProtocol

-(id)initWithRequest:(NSURLRequest *)request
      cachedResponse:(NSCachedURLResponse *)cachedResponse
			  client:(id <NSURLProtocolClient>)client
{
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
	BOOL canHandle = [[[request URL] scheme] isEqualToString:@"itss"];
    return canHandle;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

-(void)stopLoading
{
}

-(void)startLoading
{
    NSURL *url = [[self request] URL];
	CHMDocument *doc = [CHMDocument CurrentDocument];
	NSString *encoding = [[self request] encodingName];
	
	if( !doc ) {
		[[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
		return;
    }
	
    NSData *data;
    NSString *path;
    if( [url parameterString] ) {
		path = [NSString stringWithFormat:@"%@;%@", [url path], [url parameterString]];
    }
    else {
		path = [url path];
    }
	
	if (![doc exist:path])
	{
		path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	data = [doc content:path];
    
    if( !data ) {
		[[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
		return;
    }
    
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL: [[self request] URL]
														MIMEType:nil
										   expectedContentLength:[data length]
												textEncodingName:encoding];
    [[self client] URLProtocol:self     
			didReceiveResponse:response 
			cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
	
    [response release];	
}

@end

@implementation NSURLRequest (SpecialProtocol)

- (NSString *)encodingName
{
	return [NSURLProtocol propertyForKey:@"encoding" inRequest:self];
}
@end



@implementation NSMutableURLRequest (SpecialProtocol)

- (void)setEncodingName:(NSString *)name
{
	[NSURLProtocol setProperty:name forKey:@"encoding" inRequest:self];
}
@end