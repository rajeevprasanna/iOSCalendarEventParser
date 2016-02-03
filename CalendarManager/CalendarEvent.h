//
//  CalendarEvent.h
//  iOSCalendarEventParser
//
//  Created by Rajeev Kumar Kallempudi on 2/3/16.
//  Copyright © 2016 rajeevprasanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarEvent : NSObject

@property (nonatomic, strong) NSString*  uid;
@property (nonatomic, strong) NSString*  organiserMailId;
@property (nonatomic, strong) NSString*  location;
@property (nonatomic, strong) NSString*  subject;
@property (nonatomic, strong) NSString*  eventDescription;
@property (nonatomic, strong) NSString*  timezoneId;
@property (nonatomic, assign) NSTimeInterval  startTime;
@property (nonatomic, assign) NSTimeInterval  endTime;
@property (nonatomic, assign) NSTimeInterval  lastModifiedTime;
@property (nonatomic, assign) NSTimeInterval creationTime;
@property (nonatomic, strong) NSString*  method;
@property (nonatomic, assign) NSInteger  userAction;
@property  (nonatomic, strong) NSString* icalString;

@end
