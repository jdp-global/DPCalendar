//
//  DPCalendarMonthlyCell.m
//  DPCalendar
//
//  Created by Ethan Fang on 19/12/13.
//  Copyright (c) 2013 Ethan Fang. All rights reserved.
//

#import "DPCalendarMonthlySingleMonthCell.h"
#import "DPCalendarEvent.h"
#import "DPCalendarIconEvent.h"
#import "NSDate+DP.h"

@interface DPCalendarMonthlySingleMonthCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *iconEvents;
@end

@implementation DPCalendarMonthlySingleMonthCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 14, 18)];
        self.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        self.titleLabel.textColor = [UIColor colorWithRed:82/255.0f green:82/255.0f blue:82/255.0f alpha:1];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.userInteractionEnabled = NO;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
    }
    return self;
}

-(void)setDate:(NSDate *)date calendar:(NSCalendar *)calendar events:(NSArray *)events iconEvents:(NSArray *)iconEvents {
    self.date = [calendar dateFromComponents:[calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date]];
    self.events = events;
    self.iconEvents = iconEvents;
    self.calendar = calendar;

    [self setNeedsDisplay];
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsDisplay];
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

-(void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self setNeedsDisplay];
}

#define ROW_HEIGHT 20

#define DAY_TEXT_FONT_SIZE 12

#define ICON_SIDE_MAX 14
#define ICON_TEXT_FONT_SIZE 12

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef separatorColor = self.separatorColor.CGColor;
    
    //Draw borders
    CGFloat pixel = 1.f / [UIScreen mainScreen].scale;
    CGSize size = self.bounds.size;
    DPContextDrawLine(context,
                      CGPointMake(size.width - pixel, pixel),
                      CGPointMake(size.width - pixel, size.height),
                      separatorColor,
                      pixel);
    
    
    //Draw background colors
    if (!self.enabled) {
        [self drawCellWithColor:[UIColor colorWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1] InRect:rect context:context];
    } else if (self.isSelected) {
        [self drawCellWithColor:[UIColor colorWithRed:255/255.0f green:222/255.0f blue:0 alpha:0.5] InRect:rect context:context];
    } else {
        [self drawCellWithColor:[UIColor clearColor] InRect:rect context:context];
    }
    
    //Set text style
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentLeft;
    NSStringDrawingContext *stringContext = [[NSStringDrawingContext alloc] init];
    stringContext.minimumScaleFactor = 1;
    
    //Draw Day
    NSDateComponents *components =
    [self.calendar components:NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                fromDate:self.date];
    NSString *dayString = [NSString stringWithFormat:@"%d", components.day];
    float dayWidth = [dayString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, DAY_TEXT_FONT_SIZE)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                         NSFontAttributeName: [UIFont systemFontOfSize:DAY_TEXT_FONT_SIZE]
                                                         } context:stringContext].size.width;
    [dayString drawInRect:CGRectMake(2, (ROW_HEIGHT - DAY_TEXT_FONT_SIZE) / 2, dayWidth, DAY_TEXT_FONT_SIZE) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:DAY_TEXT_FONT_SIZE], NSParagraphStyleAttributeName:textStyle}];
    
    
    int eventsNotShowingCount = 0;

    //Draw Icon events
    float iconX = 2 + dayWidth + 4.0f;
    for (int i = 0; i < self.iconEvents.count; i++) {
        DPCalendarIconEvent *event = [self.iconEvents objectAtIndex:i];
        CGFloat titleWidth = [event.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, ICON_TEXT_FONT_SIZE)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{
                                                           NSFontAttributeName: [UIFont systemFontOfSize:ICON_TEXT_FONT_SIZE]
                                                           } context:stringContext].size.width;
        
        BOOL isWidthLonger = event.icon.size.width > event.icon.size.height;
        float scale = ICON_SIDE_MAX / (isWidthLonger ? event.icon.size.width : event.icon.size.height);
        float iconWidth = isWidthLonger ? ICON_SIDE_MAX : event.icon.size.width * scale;
        float iconHeight = isWidthLonger ? event.icon.size.height * scale : ICON_SIDE_MAX;
        
        if (event.title.length) {
            if (iconX + titleWidth + iconWidth> rect.size.width) {
                //Not enough space
            } else {
                [self drawRoundedRect:CGRectMake(iconX, 0, titleWidth + iconWidth + iconHeight, ROW_HEIGHT) radius:ROW_HEIGHT / 2 withColor:[UIColor colorWithRed:242/255.0f green:224/255.0f blue:1 alpha:1]];
                
                NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
                textStyle.lineBreakMode = NSLineBreakByWordWrapping;
                textStyle.alignment = NSTextAlignmentLeft;
                
                [event.title drawInRect:CGRectMake(iconX + iconHeight / 2, (ROW_HEIGHT - ICON_TEXT_FONT_SIZE) / 2, titleWidth, ICON_TEXT_FONT_SIZE) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:ICON_TEXT_FONT_SIZE], NSParagraphStyleAttributeName:textStyle}];
                
                
                [event.icon drawInRect:CGRectMake(iconHeight / 2 + iconX + titleWidth, (ROW_HEIGHT - iconHeight) / 2, iconWidth, iconHeight)];
                iconX += iconWidth + titleWidth + iconWidth + 2 * iconHeight + 4.0f;
            }
        } else {
            if (iconX + iconWidth > rect.size.width) {
                //Not enough space
            } else {
                
                [event.icon drawInRect:CGRectMake(iconX, (ROW_HEIGHT - iconHeight) / 2, iconWidth, iconHeight)];
                iconX += iconWidth + 4.0f;
            }
        }

        
        
    }
    
    //Draw Events
    for (DPCalendarEvent *event in self.events) {
        
        NSDate *day = self.date;
        
        UIColor *color = [self.eventColors objectAtIndex:event.type % self.eventColors.count];
        
        if (event.rowIndex == 0 || ((event.rowIndex + 1) * ROW_HEIGHT > rect.size.height)) {
            eventsNotShowingCount++;
            continue;
        }
        
        
        NSDate *tomorrow = [self.date dateByAddingYears:0 months:0 days:1];
        BOOL isEventEndedToday = [event.endTime compare:tomorrow] == NSOrderedAscending;
        
        //Draw Underline
        [self drawCellWithColor:color InRect:CGRectMake(0, (event.rowIndex + 1) * ROW_HEIGHT, rect.size.width - (isEventEndedToday ? 4 : 0), 1) context:context];
        
        if (!([event.startTime compare:day] == NSOrderedAscending) || ([event.startTime compare:day] == NSOrderedAscending && [self.date isEqualToDate:self.firstVisiableDateOfMonth])) {
            //Draw Left line
            [self drawCellWithColor:color InRect:CGRectMake(0, event.rowIndex * ROW_HEIGHT + 3, 2, ROW_HEIGHT - 3) context:context];
            
            
            [[UIColor blackColor] set];
            [event.title drawInRect:CGRectMake(5, event.rowIndex * ROW_HEIGHT + 2, rect.size.width - 5, ROW_HEIGHT - 2) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:textStyle}];
        }
        
        
    }
    if (eventsNotShowingCount > 0) {
        //show more
        [[NSString stringWithFormat:@"%d more...", eventsNotShowingCount] drawInRect:CGRectMake(5, (self.events.count - eventsNotShowingCount + 1) * ROW_HEIGHT + 2, rect.size.width - 5, ROW_HEIGHT - 2) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:textStyle}];
    }
    
    
    
}

@end
