//
//  CalendarEventParser.m
//  iOSCalendarEventParser
//
//  Created by Rajeev Kumar Kallempudi on 2/3/16.
//  Copyright © 2016 rajeevprasanna. All rights reserved.
//

#import "CalendarEventParser.h"
#import "CalendarEventParserConstants.h"
#import "CalendarEventTimeZones.h"

@implementation CalendarEventParser

+(void)parseCalendar:(NSString *)icalEventString :(void (^)(CalendarEvent *))successBlock withErrorBlock:(void (^)(NSDictionary*))errorBlock
{
    if(icalEventString){
        CalendarEvent *event =  [self getCalendarEventComponents:icalEventString];
        if(event) {
            successBlock(event);
        }else {
            errorBlock(nil);
        };
    }else{
        errorBlock(nil);
    }
}

+(CalendarEvent *)getCalendarEventComponents:(NSString *)icsString
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\n +" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *icsStringWithoutNewlines = [regex stringByReplacingMatchesInString:icsString options:0 range:NSMakeRange(0, [icsString length]) withTemplate:@""];
    // Pull out each line from the calendar file
    NSMutableArray *eventsArray = [NSMutableArray arrayWithArray:[icsStringWithoutNewlines componentsSeparatedByString:@"BEGIN:VEVENT"]];
    
    NSString *calendarString;
    // Remove the first item (that's just all the stuff before the first VEVENT)
    if ([eventsArray count] > 0) {
        NSScanner *scanner = [NSScanner scannerWithString:[eventsArray objectAtIndex:0]];
        [scanner scanUpToString:@"TZID:" intoString:nil];
        
        [scanner scanUpToString:@"\n" intoString:&calendarString];
        
        calendarString = [[[calendarString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"TZID:" withString:@""];
        
        [eventsArray removeObjectAtIndex:0];
    }
    
    NSScanner *eventScanner;
    NSString *eventUniqueIDString;
    NSString* summaryString;
    NSString* descriptionString;
    NSString *timezoneIDString;
    NSString *createdDateTimeString;
    NSString *startDateTimeString;
    NSString *endDateTimeString;
    NSString *lastModifiedDateTimeString;
    NSString *locationString;
    
    for (NSString *event in eventsArray) {
        
        // Extract the created datetime
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"CREATED:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&createdDateTimeString];
        createdDateTimeString = [[createdDateTimeString stringByReplacingOccurrencesOfString:@"CREATED:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        
        // Extract event time zone ID
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"DTSTART;TZID=" intoString:nil];
        [eventScanner scanUpToString:@":" intoString:&timezoneIDString];
        timezoneIDString = [[timezoneIDString stringByReplacingOccurrencesOfString:@"DTSTART;TZID=" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        if (!timezoneIDString) {
            // Extract event time zone ID
            eventScanner = [NSScanner scannerWithString:event];
            [eventScanner scanUpToString:@"TZID:" intoString:nil];
            [eventScanner scanUpToString:@"\n" intoString:&timezoneIDString];
            timezoneIDString = [[timezoneIDString stringByReplacingOccurrencesOfString:@"TZID:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        
        // Extract start time
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:[NSString stringWithFormat:@"DTSTART;TZID=%@:", timezoneIDString] intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&startDateTimeString];
        startDateTimeString = [[startDateTimeString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"DTSTART;TZID=%@:", timezoneIDString] withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        if (!startDateTimeString) {
            eventScanner = [NSScanner scannerWithString:event];
            [eventScanner scanUpToString:@"DTSTART:" intoString:nil];
            [eventScanner scanUpToString:@"\n" intoString:&startDateTimeString];
            startDateTimeString = [[startDateTimeString stringByReplacingOccurrencesOfString:@"DTSTART:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            
            if (!startDateTimeString) {
                eventScanner = [NSScanner scannerWithString:event];
                [eventScanner scanUpToString:@"DTSTART;VALUE=DATE:" intoString:nil];
                [eventScanner scanUpToString:@"\n" intoString:&startDateTimeString];
                startDateTimeString = [[startDateTimeString stringByReplacingOccurrencesOfString:@"DTSTART;VALUE=DATE:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            }
        }
        
        // Extract end time
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:[NSString stringWithFormat:@"DTEND;TZID=%@:", timezoneIDString] intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&endDateTimeString];
        endDateTimeString = [[endDateTimeString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"DTEND;TZID=%@:", timezoneIDString] withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        if (!endDateTimeString) {
            eventScanner = [NSScanner scannerWithString:event];
            [eventScanner scanUpToString:@"DTEND:" intoString:nil];
            [eventScanner scanUpToString:@"\n" intoString:&endDateTimeString];
            endDateTimeString = [[endDateTimeString stringByReplacingOccurrencesOfString:@"DTEND:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            
            if (!endDateTimeString) {
                eventScanner = [NSScanner scannerWithString:event];
                [eventScanner scanUpToString:@"DTEND;VALUE=DATE:" intoString:nil];
                [eventScanner scanUpToString:@"\n" intoString:&endDateTimeString];
                endDateTimeString = [[endDateTimeString stringByReplacingOccurrencesOfString:@"DTEND;VALUE=DATE:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            }
        }
        
        // Extract last modified datetime
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"LAST-MODIFIED:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&lastModifiedDateTimeString];
        lastModifiedDateTimeString = [[[lastModifiedDateTimeString stringByReplacingOccurrencesOfString:@"LAST-MODIFIED:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];

        
        // Extract the event summary
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"SUMMARY" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&summaryString];
        NSArray *summaryComponenets = [summaryString componentsSeparatedByString:@":"];
        if(summaryComponenets.count > 2){
            NSMutableArray *temp = [summaryComponenets mutableCopy];
            [temp removeObjectAtIndex:0];
            summaryString = [temp componentsJoinedByString:@":"];
        }else if(summaryComponenets.count == 2){
            summaryString = summaryComponenets[1];
        }else if(summaryComponenets.count == 1){
            summaryString = summaryComponenets[0];
        }
        summaryString = [[[summaryString stringByReplacingOccurrencesOfString:@"SUMMARY:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        
        // Extract event description
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"DESCRIPTION" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&descriptionString];
        
        NSArray *descriptionComponenets = [descriptionString componentsSeparatedByString:@":"];
        if(descriptionComponenets.count > 2){
            NSMutableArray *temp = [descriptionComponenets mutableCopy];
            [temp removeObjectAtIndex:0];
            descriptionString = [temp componentsJoinedByString:@":"];
        }else if(descriptionComponenets.count == 2){
            descriptionString = descriptionComponenets[1];
        }else if(descriptionComponenets.count == 1){
            descriptionString = descriptionComponenets[0];
        }
        descriptionString = [[[[[[descriptionString stringByReplacingOccurrencesOfString:@"DESCRIPTION:" withString:@""] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] stringByReplacingOccurrencesOfString:@"\\," withString:@","];
        
        
        // Extract the unique ID
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"UID:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&eventUniqueIDString];
        eventUniqueIDString = [[eventUniqueIDString stringByReplacingOccurrencesOfString:@"UID:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract the event location
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"LOCATION:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&locationString];
        locationString = [[[locationString stringByReplacingOccurrencesOfString:@"LOCATION:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    }
    
    
    NSArray *lines = [icsString componentsSeparatedByString:@"\r\n"];
    NSString *organiserLine = nil;
    NSString *ctzoneLine = nil;
    NSString *timeZoneLine = nil;
    NSString *methodLine = nil;
    NSString *actionTakenLine = nil;
    NSString *eventCancelledLine = nil;

    for(NSString *l in lines){
        if(organiserLine.length == 0 && ([l rangeOfString:@"ORGANIZER;"].location != NSNotFound || [l rangeOfString:@"ORGANIZER:MAILTO:"].location != NSNotFound))
        {
            organiserLine = l;
        }else if(!timezoneIDString && !timeZoneLine && ([l rangeOfString:@"TZID:"].location != NSNotFound || [l rangeOfString:@"TZID="].location != NSNotFound)){
            timeZoneLine = l;
        }else if(!timezoneIDString && !ctzoneLine && [l rangeOfString:@"&ctz="].location != NSNotFound){
            ctzoneLine = l;
        }else if(methodLine.length == 0 && [l rangeOfString:@"METHOD:"].location != NSNotFound){
            methodLine = l;
        }else if(actionTakenLine.length == 0 && [l rangeOfString:@"ATTENDEE;"].location != NSNotFound){
            actionTakenLine = l;
        }else if(eventCancelledLine.length == 0 && [l rangeOfString:@"STATUS:CANCELLED"].location != NSNotFound){
            eventCancelledLine = l;
        }
    }

    NSString *organiserEmailId = nil;
    if(organiserLine.length > 0){
        NSArray *components = [organiserLine componentsSeparatedByString:@":"];
        for(NSString *c in components){
            if([c rangeOfString:@"@"].location != NSNotFound && [c rangeOfString:@"."].location != NSNotFound )
            {
                organiserEmailId = c;
            }
        }
    }
    
    if(!timezoneIDString && timeZoneLine.length > 0){
        NSArray *components = [timeZoneLine componentsSeparatedByString:@":"];
        if (components.count == 2) {
            timezoneIDString = components[1];
        }

        if([timeZoneLine rangeOfString:@"="].location != NSNotFound){
            NSArray *tempComponents = [timeZoneLine componentsSeparatedByString:@"TZID="];
            if (tempComponents.count >= 2) {
                NSString *line = tempComponents[1];
                NSArray *tempComponents1 = [line componentsSeparatedByString:@":"];
                if(tempComponents1.count == 2){
                    timezoneIDString = tempComponents1[0];
                }
            }
        }

    } else if(!timezoneIDString && ctzoneLine.length > 0){
        NSArray *components = [ctzoneLine componentsSeparatedByString:@"&"];
        for(NSString *c in components){
            if([c rangeOfString:@"ctz="].location != NSNotFound)
            {
                NSArray *components2 = [c componentsSeparatedByString:@"="];
                if(components2.count == 2){
                    timezoneIDString = components2[1];
                }
            }
        }
    }
    
    
    NSString *methodName = nil;
    if(methodLine.length > 0){
        NSArray *components = [methodLine componentsSeparatedByString:@":"];
        if (components.count == 2) {
            methodName = components[1];
        }
    }
    
    NSTimeZone *sourceTimeZone = [CalendarEventTimeZones getTimezoneById:timezoneIDString];
    NSTimeInterval creationTimeMillis = 0;
    NSTimeInterval startDateMillis = 0;
    NSTimeInterval endDateMillis = 0;
    NSTimeInterval lastModifiedTimeMillis = 0;
    if(sourceTimeZone){
        NSDateFormatter *dateFormatter = [self getCalDateFormatter];
        [dateFormatter setTimeZone:sourceTimeZone];

        NSDate *creationDate = [dateFormatter dateFromString:createdDateTimeString];
        NSDate *calStartDate = [dateFormatter dateFromString:startDateTimeString];
        NSDate *calEndDate = [dateFormatter dateFromString:endDateTimeString];
        NSDate *modifiedDate = [dateFormatter dateFromString:lastModifiedDateTimeString];

        creationTimeMillis = [creationDate timeIntervalSince1970];
        startDateMillis = [calStartDate timeIntervalSince1970];
        endDateMillis = [calEndDate timeIntervalSince1970];
        lastModifiedTimeMillis = [modifiedDate timeIntervalSince1970];
    }
 
    NSInteger action = CALENDAR_EVENT_STATUS_NONE;
    if(actionTakenLine.length > 0){
        if([actionTakenLine rangeOfString:@"PARTSTATCEPTED"].location != NSNotFound || [actionTakenLine rangeOfString:@"ACCEPTED"].location != NSNotFound){
            action = CALENDAR_EVENT_STATUS_CONFIRMED;
        }else if([actionTakenLine rangeOfString:@"TENTATIVE"].location != NSNotFound){
            action = CALENDAR_EVENT_STATUS_TENTATIVE;
        }else if([actionTakenLine rangeOfString:@"PARTSTATCLINED"].location != NSNotFound || [actionTakenLine rangeOfString:@"DECLINED"].location != NSNotFound){
            action = CALENDAR_EVENT_STATUS_DECLINED;
        }
    }
 
    if([methodName isEqualToString:@"REPLY"] && action == 0){
        //In case parsing went wrong and couldn't parse the line properly
        if([icsString rangeOfString:@"PARTSTATCEPTED"].location != NSNotFound || [icsString rangeOfString:@"ACCEPTED"].location != NSNotFound){
            action = CALENDAR_EVENT_STATUS_CONFIRMED;
        }else if([icsString rangeOfString:@"TENTATIVE"].location != NSNotFound){
            action = CALENDAR_EVENT_STATUS_TENTATIVE;
        }else if([icsString rangeOfString:@"PARTSTATCLINED"].location != NSNotFound || [icsString rangeOfString:@"DECLINED"].location != NSNotFound){
            action = CALENDAR_EVENT_STATUS_DECLINED;
        }
    }

    if(eventCancelledLine.length > 0){
        action = CALENDAR_EVENT_STATUS_CANCELLED;
    }
    
    CalendarEvent *calendarEvent = [CalendarEvent new];
    calendarEvent.uid = eventUniqueIDString;
    calendarEvent.organiserMailId = organiserEmailId;
    calendarEvent.location = locationString;
    calendarEvent.subject = summaryString;
    calendarEvent.eventDescription = descriptionString;
    calendarEvent.timezoneId = timezoneIDString;
    calendarEvent.startTime = startDateMillis;
    calendarEvent.endTime = endDateMillis;
    calendarEvent.lastModifiedTime = lastModifiedTimeMillis;
    calendarEvent.creationTime = creationTimeMillis;
    calendarEvent.method = methodName;
    calendarEvent.userAction = action;
    calendarEvent.icalString = icsString;
    
    return calendarEvent;
}

static NSDateFormatter *icalDateFormatter;
+(NSDateFormatter *)getCalDateFormatter
{
    if(!icalDateFormatter){
        icalDateFormatter = [[NSDateFormatter alloc] init];
        [icalDateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss"];
    }
    return icalDateFormatter;
}

@end
