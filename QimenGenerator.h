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

/// String ������������������������ͷ���̾֡�Ѯ�ס�ֵ����ֵʹ, ��Ӣ��'&'�ָ�
- (NSMutableString*)toString;	

//���ؾŹ���ֵ  n = [1-9].
- (NSMutableArray*)getNthPalace:(int)n;     

//�õ�����
- (NSMutableArray*)getEmptyDeath;

//�õ�����
- (int)getHorseStar;

//�õ���N���İ���
- (NSString*)getNthHiddenStem: (int)n;

/*
�޹غ���
*/
- (int)print;
- (int)generate;
@end
#endif /* __QimenGenerator_h_GNUSTEP_BASE_INCLUDE */