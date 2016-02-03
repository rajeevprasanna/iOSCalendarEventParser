//
//  CalendarEventTimeZones.h
//  iOSCalendarEventParser
//
//  Created by Rajeev Kumar Kallempudi on 2/3/16.
//  Copyright © 2016 rajeevprasanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarEventTimeZones : NSObject

+(NSTimeZone *)getTimezoneById:(NSString *)timezoneId;

@end
