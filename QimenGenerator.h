#ifndef __QimenGenerator_h_GNUSTEP_BASE_INCLUDE
#define __QimenGenerator_h_GNUSTEP_BASE_INCLUDE

#import <Foundation/Foundation.h>

@interface QimenGenerator: NSObject
{
	int _year;	
	int _month;
	int _day;
	int _hour;
	int _curDate;	
}
/// object init function
- (id)initWithParam: (int)year: (int)month: (int)day: (int)hour; 

/// String 包含阳历、四柱、节气、符头、盘局、旬首、值符、值使, 以英文'&'分割
- (NSMutableString*)toString;	

//返回九宫内值  n = [1-9].
- (NSMutableArray*)getNthPalace:(int)n;     

//得到空亡
- (NSMutableArray*)getEmptyDeath;

//得到驿马
- (int)getHorseStar;

//得到第N宫的暗干
- (NSString*)getNthHiddenStem: (int)n;

/*
无关函数
*/
- (int)print;
- (int)generate;
@end
#endif /* __QimenGenerator_h_GNUSTEP_BASE_INCLUDE */