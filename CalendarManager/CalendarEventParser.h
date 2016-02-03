//
//  CalendarEventParser.h
//  iOSCalendarEventParser
//
//  Created by Rajeev Kumar Kallempudi on 2/3/16.
//  Copyright © 2016 rajeevprasanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarEvent.h"

@interface CalendarEventParser : NSObject

+(void)parseCalendar:(NSString *)icalEventString :(void (^)(CalendarEvent *))successBlock withErrorBlock:(void (^)(NSDictionary*))errorBlock;

@end
