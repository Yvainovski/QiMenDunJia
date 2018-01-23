#import "QimenGenerator.h"

static NSArray *STEMS;
static NSArray *BRANCHES;
static NSArray *STARS;
static NSArray *DOORS;
static NSArray *GODS;
static NSArray *JIEQI;
static NSArray *curSBNum;	//干支数
static NSArray *futou;//符头数
static int yuanNum; //三元数
static int curJieqiNum;	//节气数
static int juNum; //局数
static NSArray *xunshou; //时旬首
static int yinyangNum; //阴阳遁？ 0阴 1阳
static int dungan; //甲遁干
static int zhifu;	//值符
static int zhishi;	//值使
static int tianyiPalace; //天乙落宫
static int horseStar; //驿马
static NSMutableArray* emptyDeath; //空亡
static NSMutableArray* hiddenStem;
static NSArray *curSBString; 

static NSMutableArray* _1stPalace;	
static NSMutableArray* _2ndPalace;
static NSMutableArray* _3rdPalace;
static NSMutableArray* _4thPalace;
static NSMutableArray* _5thPalace;
static NSMutableArray* _6thPalace;
static NSMutableArray* _7thPalace;
static NSMutableArray* _8thPalace;
static NSMutableArray* _9thPalace;

static const int JZ_YEAR = 1984; //1984甲子年
static const int BASE_YEAR = 2016; //NOTE!! Need to be change along with FIRSTSB
static int FIRSTSB[2][2] ={  //[0] is for 2016  {S,B}
			{8,6},{4,0}
			};
static int JIEQIDATES[] ={											//2015
			2015020411,2015021907,2015030605,2015032106,2015040510,
			2015042017,2015050603,2015052116,2015060607,2015062200,
			2015070718,2015072311,2015080804,2015082318,2015090807,
			2015092316,2015100822,2015102401,2015110801,2015112223,
			2015120718,2015122212,2016010660,2016012017,		    //2016
			2016020417,2016021913,2016030511,2016032012,2016040416,
			2016041923,2016050509,2016052022,2016060513,2016062106,
			2016070700,2016072217,2016080709,2016082300,2016090712,
			2016092222,2016100804,2016102307,2016110707,2016112205,
			2016120700,2016122118,2017010606,2017012023,			//2017
			2017020323,2017021819,2017030517,2017032018,2017040422,
			2017042005,2017050515,2017052104,2017060519,2017062112,
			2017070705,2017072223,2017080715,2017082306,2017090718,
			2017092304,2017100810,2017102313,2017110713,2017112211,
			2017120706,2017122200,2018010511,2018012005
			};

@implementation QimenGenerator

- (id)initWithParam: (int)year: (int)month: (int)day: (int)hour{
	self = [super init];
	if(self){
		_year = year;
		_month = month;
		_day = day;
		_hour = hour;
		_curDate = _year*1000000 + _month*10000 + _day*100 + _hour;
	}
	[self generate];
	return self;
}

+ (void)initialize {
	STEMS = [NSArray arrayWithObjects: @"甲", @"乙", @"丙",
			 @"丁", @"戊", @"己", @"庚", @"辛", @"壬", @"癸", nil];
	BRANCHES = [NSArray arrayWithObjects: @"子", @"丑", @"寅",@"卯",@"辰",
			 @"巳", @"午", @"未", @"申", @"酉", @"戌", @"亥", nil];
	DOORS = [NSArray arrayWithObjects: @"休门", @"生门", @"伤门",
			 @"杜门", @"景门", @"死门", @"惊门", @"开门", nil];
	STARS = [NSArray arrayWithObjects: @"天蓬", @"天任", @"天冲",
			 @"天辅", @"天英",@"天禽", @"天芮", @"天柱", @"天心", nil];
	GODS = [NSArray arrayWithObjects: @"值符", @"腾蛇", @"太阴",
			 @"六合", @"白虎", @"玄武", @"九地", @"九天", nil];
	JIEQI = [NSArray arrayWithObjects: @"立春", @"雨水", @"惊蛰",
			 @"春分", @"清明", @"谷雨", @"立夏", @"小满", @"芒种",
			 @"夏至", @"小暑", @"大暑", @"立秋", @"处暑", @"白露",
			 @"秋分", @"寒露", @"霜降", @"立冬", @"小雪", @"大雪",
			 @"冬至", @"小寒", @"大寒", nil];
	_1stPalace = [NSMutableArray array];
	_2ndPalace = [NSMutableArray array];
	_3rdPalace = [NSMutableArray array];
	_4thPalace = [NSMutableArray array];
	_5thPalace = [NSMutableArray array];
	_6thPalace = [NSMutableArray array];
	_7thPalace = [NSMutableArray array];
	_8thPalace = [NSMutableArray array];
	_9thPalace = [NSMutableArray array];
	emptyDeath = [NSMutableArray array];
	hiddenStem = [[NSMutableArray array] init];
	int k;
	for( k = 0; k<11;k++){
		[hiddenStem addObject:[NSNull null]];
	}
}

+ (NSString*)numToString: (int)num{
	if(num==1){
		return @"一";
	}
	if(num==2){
		return @"二";
	}
	if(num==3){
		return @"三";
	}
	if(num==4){
		return @"四";
	}
	if(num==5){
		return @"五";
	}
	if(num==6){
		return @"六";
	}
	if(num==7){
		return @"七";
	}
	if(num==8){
		return @"八";
	}
	if(num==9){
		return @"九";
	}
	return @"某";
}

+ (NSString*)numToStem: (int)num{
	return [STEMS objectAtIndex: num % 10];
}
+ (NSString*)numToBranch: (int)num{
	return [BRANCHES objectAtIndex: num % 12];
}
+ (NSString*)numToDoor: (int)num{
	return [DOORS objectAtIndex: num % 8];
}
+ (NSString*)numToStar: (int)num{
	return [STARS objectAtIndex: num  % 9];
}
+ (NSString*)numToGod: (int)num{
	return [GODS objectAtIndex: num % 8];
}
+ (NSString*)numToJieqi: (int)num{
	return [JIEQI objectAtIndex: num % 24];
}
+ (NSString*)numToYuan: (int)yuan{
	if(yuan==1){
		return @"上";
	}else if(yuan==2){
		return @"中";
	}else{
		return @"下";
	}
}

+ (int)getMSFromYS: (int)num{	//五虎遁元决
	if(num==0 || num==5){		//甲己之年丙作首
		return 2;
	}else if(num==1 || num==6){	//乙庚之岁戊为头
		return 4;
	}else if(num==2 || num==7){	//丙辛必定寻庚起
		return 6;
	}else if(num==3 || num==8){	//丁壬壬位顺行流
		return 8;
	}else{						//戊癸何方发甲寅
		return 0; 
	}
}
+ (int)getHSFromDS: (int)num{	//五鼠遁元
	if(num==0 || num==5){		//甲己还加甲
		return 0;
	}else if(num==1 || num==6){	//乙庚丙作初
		return 2;
	}else if(num==2 || num==7){	//丙辛从戊起
		return 4;
	}else if(num==3 || num==8){	//丁壬庚子居
		return 6;
	}else{						//戊癸发壬子
		return 8; 
	}
}
+ (int)getHBFromNum: (int)num{
	if(num%2==0){
		return num/2;
	}else{
		return num/2+1;
	}
}


- (int)isBeforeSpring{		//立春前
	int i;
	for(i=0; i < (sizeof JIEQIDATES) / (sizeof JIEQIDATES[0]);i++){
		if(JIEQIDATES[i]/1000000 == _year && i%24==0){
			if(JIEQIDATES[i] > _curDate){
				return 1;
			}else{
				return -1;
			}
		}
	}
	return -1;
}

- (int)isAfterZi{			//子后？
	if(_hour>22){
		return 1;
	}
	return -1;
}

- (int)isLeapYear{
	if(_year%100==0){
		if(_year%400==0){
			return 1;
		}else{
			return -1;
		}
	}else{
		if(_year%4==0){
			return 1;
		}else{
			return -1;
		}
	}
}

- (int)howManyDaysInMonth: (int)m{
	if(m==2){
		if([self isLeapYear]==1){
			return 29;
		}else{
			return 28;
		}
	}else{
		if(m==1 || m==3 || m==7 || m==5 || m==8 ||m==10||m==12){
			return 31;
		}else{
			return 30;
		}
	}
}

- (int)isYinOrYang{	//阴遁阳遁？  1=阳 0=阴
	int dateOfXiaZhi = 0;
	int dateOfDongzhi = 0;
	int i;
	for(i=0; i < (sizeof JIEQIDATES) / (sizeof JIEQIDATES[0]);i++){
		if(JIEQIDATES[i]/1000000 == _year && i%24==9){
			dateOfXiaZhi = JIEQIDATES[i];
		}
		if(JIEQIDATES[i]/1000000 == _year && i%24==21){
			dateOfDongzhi = JIEQIDATES[i];
			break;
		}
	}
	if(_curDate<dateOfXiaZhi||(_curDate>dateOfDongzhi || _curDate==dateOfDongzhi)){
		return 1;
	}else{
		return 0;
	}
} 

- (NSString*)numToYinYang: (int)num{
	if(num%2==0){
		return @"阴";
	}else{
		return @"阳";
	}
}

- (NSArray*)getCurSBNum{
	int ysNum = 0;
	int ybNum = 0;
	int msNum = 0;
	int mbNum = 2;
	int dsNum = 0;
	int dbNum = 0;
	int hsNum = 0;
	int hbNum = 0;

	//get year's sb---------------------
	int count = _year - JZ_YEAR;
	if(_year - JZ_YEAR < 0){
		count = 60 - count;
	}
	int i;
	for ( i = 0; i < count; i++){
		ysNum++;
		ybNum++;
	}
	if([self isBeforeSpring]== 1){
		ysNum--;
		ybNum--;
	}
	ysNum = ysNum % 10;
	ybNum = ybNum % 12;
	//get year's sb done-----------------
	//get month's sb---------------------
	int curYear = _year;
	if([self isBeforeSpring]==1){
		curYear--;
	}
	msNum = [[self class] getMSFromYS: ysNum];
	for(i=0; i < (sizeof JIEQIDATES) / (sizeof JIEQIDATES[0]);i++){
		if(JIEQIDATES[i]/1000000 == curYear && i%24==0){
			int k = i+1;
			while(k%24 !=0 && (_curDate>JIEQIDATES[k]||_curDate==JIEQIDATES[k])){
				if(k%2 ==0){
					msNum++;
					mbNum++;
				}
				k++;
			}
		break;
		}
	}
	msNum = msNum % 10;
	mbNum = mbNum % 12;
	//get month's sb done-----------------
	//get day's sb---------------------
	dsNum = FIRSTSB[_year - BASE_YEAR][0];
	dbNum = FIRSTSB[_year - BASE_YEAR][1];
	int dDifference = _curDate - _year*1000000;
	int mDifference = _month - 1;
	dDifference = _day - 1;
	for (i = 1; i < mDifference + 1; i++){
		dDifference += [self howManyDaysInMonth:i];
	}
	for (i=0; i<dDifference ; i++){
		dsNum++;
		dbNum++;
	}
	if([self isAfterZi]==1){
		dsNum++;
		dbNum++;		
	}
	dsNum = dsNum % 10;
	dbNum = dbNum % 12;
	//get day's sb done---------------------
	//get hour's sb ---------------------
	hsNum = [[self class] getHSFromDS:dsNum];
	hbNum = [[self class] getHBFromNum:_hour];
	if(_hour<23){
		for ( i = 0; i < hbNum; ++i){
			hsNum++;
		}
	}
	hsNum = hsNum % 10;
	hbNum = hbNum % 12;
	//get hour's sb done---------------------


	NSArray *sb = [NSArray arrayWithObjects:
						[NSNumber numberWithInteger:ysNum],
						[NSNumber numberWithInteger:ybNum],
						[NSNumber numberWithInteger:msNum],
						[NSNumber numberWithInteger:mbNum],
						[NSNumber numberWithInteger:dsNum],
						[NSNumber numberWithInteger:dbNum],
						[NSNumber numberWithInteger:hsNum],
						[NSNumber numberWithInteger:hbNum],
						nil
				  ];
	return sb;
}

- (NSArray*)getCurSB: (NSArray*)sb{
	int ys = [[sb objectAtIndex:0] integerValue];
	int yb = [[sb objectAtIndex:1] integerValue];
	int ms = [[sb objectAtIndex:2] integerValue];
	int mb = [[sb objectAtIndex:3] integerValue];
	int ds = [[sb objectAtIndex:4] integerValue];
	int db = [[sb objectAtIndex:5] integerValue];
	int hs = [[sb objectAtIndex:6] integerValue];
	int hb = [[sb objectAtIndex:7] integerValue];
	NSArray *sbString = [NSArray arrayWithObjects:
						[[self class] numToStem: ys],
						[[self class] numToBranch: yb],
						[[self class] numToStem: ms],
						[[self class] numToBranch: mb],
						[[self class] numToStem: ds],
						[[self class] numToBranch: db],
						[[self class] numToStem: hs],
						[[self class] numToBranch: hb],
						nil];
	return sbString;
}

- (int)getCurJieqiNum{
	int pt = (sizeof JIEQIDATES) / (sizeof JIEQIDATES[0]) - 1;

	while(_curDate<JIEQIDATES[pt] && pt>0){
		pt--;
	}
	return pt;
}

- (NSString*)getCurJieqi: (int)pt{
	return [[self class] numToJieqi: pt];
}

- (NSArray*) getFutouFromSB:(NSArray*)sb{ 			//符头
	int s = [[sb objectAtIndex:0] integerValue];
	int b = [[sb objectAtIndex:1] integerValue];
	while(s != 0 && s != 5){
		s--;
		b--;
		if(b<0){
			b=11;
		}
	}

	return [NSArray arrayWithObjects:
			[NSNumber numberWithInteger:s],
			[NSNumber numberWithInteger:b],nil];
}


- (int) getYuanNum:(NSArray*)futou{					//定三元
	int b = [[futou objectAtIndex:1] integerValue];
	if(b==0 || b==3 || b==6 || b==9){				//子午卯酉是上元
		return 1;
	}else if(b==2 || b==5 || b==8 || b==11){			//寅申巳亥中元
		return 2;
	}else{											//四库下元
		return 3;
	}
}

- (int)getJuNum:(int)jieqi Yuan:(int)yuan {
	if(jieqi%24==0){
		if(yuan==1){							//立春八五二相随
			return 8;
		}else if(yuan==2){
			return 5;
		}else{
			return 2;
		}
	}else if(jieqi%24==1){
		if(yuan==1){							//九六三从雨水期
			return 9;
		}else if(yuan==2){
			return 6;
		}else{
			return 3;
		}
	}else if(jieqi%24==2 || jieqi%24==21){
		if(yuan==1){							//冬至惊蛰一七四
			return 1;
		}else if(yuan==2){
			return 7;
		}else{
			return 4;
		}
	}else if(jieqi%24==3 || jieqi%24==23){
		if(yuan==1){							// 春分大寒三九六
			return 3;
		}else if(yuan==2){
			return 9;
		}else{
			return 6;
		}
	}else if(jieqi%24==4 || jieqi%24==6){
		if(yuan==1){							// 立夏清明四一七
			return 4;
		}else if(yuan==2){
			return 1;
		}else{
			return 7;
		}
	}else if(jieqi%24==5 || jieqi%24==7){
		if(yuan==1){							// 谷雨小满五二八
			return 5;
		}else if(yuan==2){
			return 2;
		}else{
			return 8;
		}
	}else if(jieqi%24==8){
		if(yuan==1){							// 芒种六三九是真
			return 6;
		}else if(yuan==2){
			return 3;
		}else{
			return 9;
		}
	}else if(jieqi%24==22){
		if(yuan==1){							// 小寒二八五同推
			return 2;
		}else if(yuan==2){
			return 8;
		}else{
			return 5;
		}
	}else if(jieqi%24==9 || jieqi%24==14){
		if(yuan==1){							// 夏至白露九三六
			return 9;
		}else if(yuan==2){
			return 3;
		}else{
			return 6;
		}
	}else if(jieqi%24==10){
		if(yuan==1){							// 小暑八二五重逢
			return 8;
		}else if(yuan==2){
			return 2;
		}else{
			return 5;
		}
	}else if(jieqi%24==15 || jieqi%24==11){
		if(yuan==1){							// 秋分大暑七一四
			return 7;
		}else if(yuan==2){
			return 1;
		}else{
			return 4;
		}
	}else if(jieqi%24==12){
		if(yuan==1){							// 立秋二五八流通
			return 2;
		}else if(yuan==2){
			return 5;
		}else{
			return 8;
		}
	}else if(jieqi%24==17 || jieqi%24==19){
		if(yuan==1){							// 霜降小雪五八二
			return 5;
		}else if(yuan==2){
			return 8;
		}else{
			return 2;
		}
	}else if(jieqi%24==20){
		if(yuan==1){							// 大雪四七一相同。
			return 4;
		}else if(yuan==2){
			return 7;
		}else{
			return 1;
		}
	}else if(jieqi%24==13){
		if(yuan==1){							// 处暑排来一四七
			return 1;
		}else if(yuan==2){
			return 4;
		}else{
			return 7;
		}
	}else if(jieqi%24==18 || jieqi%24==16){
		if(yuan==1){							// 立冬寒露六九三
			return 6;
		}else if(yuan==2){
			return 9;
		}else{
			return 3;
		}
	}
}

- (NSArray*) getXunshouFromSB: (NSArray*)sb{		//时旬首
	int s = [[sb objectAtIndex:0] integerValue];
	int b = [[sb objectAtIndex:1] integerValue];
	horseStar = b;
	while(s != 0 ){
		s--;
		b--;
		if(b<0){
			b=11;
		}
	}
	//查找空亡、驿马

	if(horseStar==0 || horseStar==4 || horseStar==8){
		//申子辰马在寅
		horseStar=8;
	}else if(horseStar==1 || horseStar==5 || horseStar==9){
		//巳酉丑马在亥
		horseStar=6;
	}else if(horseStar==2 || horseStar==6 || horseStar==10){
		//寅午戌马在申
		horseStar=2;
	}else if(horseStar==3 || horseStar==7 || horseStar==11){
		//亥卯未马在巳
		horseStar=4;
	}


	if(b==0){						//甲子旬来戌亥空
		[emptyDeath addObject:[NSNumber numberWithInteger:6]];
	}else if(b==2){					//甲寅旬来子丑空
		[emptyDeath addObject:[NSNumber numberWithInteger:1]];
		[emptyDeath addObject:[NSNumber numberWithInteger:8]];
	}else if(b==4){					//甲辰旬来寅卯空
		[emptyDeath addObject:[NSNumber numberWithInteger:3]];
		[emptyDeath addObject:[NSNumber numberWithInteger:8]];
	}else if(b==6){					//甲午旬来辰巳空
		[emptyDeath addObject:[NSNumber numberWithInteger:4]];
	}else if(b==8){					//甲申旬来午未空
		[emptyDeath addObject:[NSNumber numberWithInteger:2]];
		[emptyDeath addObject:[NSNumber numberWithInteger:9]];
	}else if(b==10){				//甲戌旬来申酉空
		[emptyDeath addObject:[NSNumber numberWithInteger:2]];
		[emptyDeath addObject:[NSNumber numberWithInteger:7]];
	}
		
	//空亡、驿马

	return [NSArray arrayWithObjects:
			[NSNumber numberWithInteger:s],
			[NSNumber numberWithInteger:b],nil];
}

- (int)getHorseStar{
	return horseStar;
}

- (NSMutableArray*)getEmptyDeath{
	return emptyDeath;
}


- (int)getDunGanFromSB: (NSArray*)sb{			//遁干
	int b = [[sb objectAtIndex:1] integerValue];
	if(b==0){
		return 4;								//甲子遁戊
	}else if(b==10){
		return 5;								//甲戌己
	}else if(b==8){
		return 6;								//甲申庚
	}else if(b==6){
		return 7;								//甲午辛
	}else if(b==4){								//甲辰壬
		return 8;
	}else if(b==2){								//甲寅癸
		return 9;
	}
}

- (NSMutableArray*)getNthPalace:(int)n{
	if(n==1){
		return _1stPalace;
	}else if(n==2){
		return _2ndPalace;
	}else if(n==3){
		return _3rdPalace;
	}else if(n==4){
		return _4thPalace;
	}else if(n==5){
		return _5thPalace;
	}else if(n==6){
		return _6thPalace;
	}else if(n==7){
		return _7thPalace;
	}else if(n==8){
		return _8thPalace;
	}else{
		return _9thPalace;
	}
}

- (int)setUpEarthlyPlate{
	int n = juNum;
	NSArray *ss = [NSArray arrayWithObjects: @"己", 
		@"庚", @"辛", @"壬", @"癸",@"丁",@"丙",@"乙",@"戊",nil];
	int ssCursor=0;
	NSMutableArray *aPalace = [self getNthPalace:n];
	[aPalace addObject:@"戊"];
	if(yinyangNum==1){		//阳遁顺排
		n++;
			if(n>9){
				n=1;
			}
		while(n != juNum){
			[[self getNthPalace:n] addObject:[ss objectAtIndex:ssCursor]];
			ssCursor++;
			n++;
			if(n>9){
				n=1;
			}
		}
	}else{					//隐遁逆排
		n--;
			if(n<1){
				n=9;
			}
		while(n != juNum){
			[[self getNthPalace:n] addObject:[ss objectAtIndex:ssCursor]];
			ssCursor++;
			n--;
			if(n<1){
				n=9;
			}
		}
	}
	return 0;
}


- (int)findTianyiPalace{
	int i;
	tianyiPalace = 1;
	NSString *hsString =[[self class]numToStem:dungan];
	for (i = 1; i < 10; i++){		//寻找天乙宫
		NSString *s =[[self getNthPalace:i] objectAtIndex:0];
		if([s isEqualToString:hsString]){
			tianyiPalace = i;
			break;
		}
	}
	return 0;
}


- (int)getFushi{		//定值符值使
	/*
	int i;
	for (i = 1; i < 10; i++){
		NSString *s = [[self getNthPalace:i] objectAtIndex:0];
		if([s isEqualToString:[[self class] numToStem:dungan]]){
			zhifu = i - 1;
			if(i==5){
				zhishi = 5;
			}else{
				zhishi = i - 1;
			}
			return 0;
		}
	}
	*/
	if(tianyiPalace==1){
		zhifu = zhishi = 0;
	}else if(tianyiPalace==2){
		zhifu = zhishi = 5;
		zhifu++;
	}else if(tianyiPalace==3){
		zhifu = zhishi = 2;
	}else if(tianyiPalace==4){
		zhifu = zhishi = 3;
	}else if(tianyiPalace==5){
		zhifu = 5;
		zhishi = 5;
	}else if(tianyiPalace==6){
		zhifu = zhishi = 7;
		zhifu++;
	}else if(tianyiPalace==7){
		zhifu = zhishi = 6;
		zhifu++;
	}else if(tianyiPalace==8){
		zhifu = zhishi = 1;
	}else{
		zhifu = zhishi = 4;
	}
	return -1;
}
									//indicator=1 顺转only
- (int)getNextGongByRotation:(int)cur indicator:(int)indicator{
	if(cur==1){
		if(yinyangNum==1 || indicator==1){		//阳顺阴逆
			return 8;
		}else{
			return 6;
		}
	}else if(cur==2 || cur==5){		//五寄二宫
		if(yinyangNum==1 || indicator==1){		//阳顺阴逆
			return 7;
		}else{
			return 9;
		}
	}else if(cur==3){
		if(yinyangNum==1 || indicator==1){		//阳顺阴逆
			return 4;
		}else{
			return 8;
		}
	}else if(cur==4){
		if(yinyangNum==1 || indicator==1){		//阳顺阴逆
			return 9;
		}else{
			return 3;
		}
	}else if(cur==6){
		if(yinyangNum==1 || indicator==1){		//阳顺阴逆
			return 1;
		}else{
			return 7;
		}
	}else if(cur==7){
		if(yinyangNum==1 || indicator==1){		//阳顺阴逆
			return 6;
		}else{
			return 2;
		}
	}else if(cur==8){
		if(yinyangNum==1 || indicator==1){		//阳顺阴逆
			return 3;
		}else{
			return 1;
		}
	}else{
		if(yinyangNum==1 || indicator==1){		//阳顺阴逆
			return 2;
		}else{
			return 4;
		}
	}
}

- (int)setUpGodsAndStarsPlate{
	int i;
	int hsPalace = 1;
	int hs = [[curSBNum objectAtIndex:6] integerValue];
	if(hs==0){
		hs = [self getDunGanFromSB:[curSBNum subarrayWithRange:NSMakeRange(6,2)]];
	}
	NSString *hsString =[[self class] numToStem: hs];
	for (i = 1; i < 10; i++){		//寻找时干宫
		NSString *s =[[self getNthPalace:i] objectAtIndex:0];
		if([s isEqualToString:hsString]){
			hsPalace = i;
		}
	}
	int curPalace= hsPalace;
	if(curPalace==5){
		curPalace=2;
	}
	for ( i = 0; i < 8; i++){		//布神盘
		NSString *god;
		god = [[self class] numToGod:i];
		[[self getNthPalace:curPalace] addObject:god]; 
		curPalace = [self getNextGongByRotation:curPalace indicator:0];
	}

									//布星盘
	int curStar = zhifu;
	curPalace= hsPalace;
	if(curPalace==5){
		curPalace=2;
	}
	if(curStar==5){
		curStar++;
	}
	for ( i = 0; i < 8; i++){		
		NSString *star;
		star = [[self class] numToStar:curStar];
		[[self getNthPalace:curPalace] addObject:star]; 
		if([star isEqualToString:@"天芮"]){
			[[self getNthPalace:curPalace] addObject:@"天禽"]; 
		}
		curPalace = [self getNextGongByRotation:curPalace indicator:1];
		curStar++;
		if(curStar==5){
			curStar++;
		}
		if(curStar>8){
			curStar=0;
		}
	}
	return 0;
}

- (int)setUpDoorsPlate{
	int i;
	int curPalace = tianyiPalace;
	if(zhishi == 5 && zhifu != 5){				//五寄二宫
		curPalace=2;
	}
	int hb = [[curSBNum objectAtIndex:7] integerValue];
	int xunshouB = [[xunshou objectAtIndex:1] integerValue];
	while(hb != xunshouB){
		if (yinyangNum==1){
			curPalace++;
			if(curPalace>9){
				curPalace = 1;
			}
		}else{
			curPalace--;
			if(curPalace<1){
				curPalace = 9;
			}
		}
		xunshouB++;
		if(xunshouB >11){
			xunshouB = 0;
		}
	}
	int curDoor = zhishi;
	if(curPalace==5){
		curPalace=2;
	}
	for ( i = 0; i < 8; i++){		//布门盘
		NSString *door;
		door = [[self class] numToDoor:curDoor++];
		[[self getNthPalace:curPalace] addObject: door]; 
		curPalace = [self getNextGongByRotation:curPalace indicator:1];
	}
	return 0;
}

- (int)setUpHeavenlyPlate{
	int i;

	for (i = 1; i < 10; i++){

		if(i==5){
			continue;
		}
		NSMutableArray *_ithPalace = [self getNthPalace:i];
		NSString *curStar = [_ithPalace objectAtIndex:3];

			
		if([curStar isEqualToString:@"天蓬"]){
			[_ithPalace addObject:[[self getNthPalace:1] objectAtIndex:0]];
		}
		if([curStar isEqualToString:@"天任"]){
			[_ithPalace addObject:[[self getNthPalace:8] objectAtIndex:0]];
		}
		if([curStar isEqualToString:@"天冲"]){
			[_ithPalace addObject:[[self getNthPalace:3] objectAtIndex:0]];
		}
		if([curStar isEqualToString:@"天辅"]){
			[_ithPalace addObject:[[self getNthPalace:4] objectAtIndex:0]];
		}
		if([curStar isEqualToString:@"天英"]){
			[_ithPalace addObject:[[self getNthPalace:9] objectAtIndex:0]];
		}
		if([curStar isEqualToString:@"天芮"]){
			[_ithPalace addObject:[[self getNthPalace:2] objectAtIndex:0]];
			[_ithPalace addObject:[[self getNthPalace:5] objectAtIndex:0]];
		}
		if([curStar isEqualToString:@"天柱"]){
			[_ithPalace addObject:[[self getNthPalace:7] objectAtIndex:0]];
		}
		if([curStar isEqualToString:@"天心"]){
			[_ithPalace addObject:[[self getNthPalace:6] objectAtIndex:0]];
		}
	}
	return 0 ;
}

-(int) rearrangePalaceArrays{	//获得暗干

		

	//如果非星盘伏吟
	NSString *zhishiInChinese =  [[self class] numToDoor:zhishi];
	int palaceToStart =1;
	for ( palaceToStart = 1; palaceToStart < 10; palaceToStart++){
		if(NSNotFound != [[self getNthPalace:palaceToStart] indexOfObject:zhishiInChinese]){
			NSLog(@"where is it????%i",palaceToStart);
			break;
		}
	}
		//如果星盘伏吟
	if(NSNotFound != [[self getNthPalace:1] indexOfObject:@"天蓬"]
		&& NSNotFound != [[self getNthPalace:1] indexOfObject:@"休门"]){
		palaceToStart = 5;
	}
		//阳顺 戊己庚辛壬癸丁丙乙 456789321
	int i=0;
	int stemToStart = [[[self getCurSBNum] objectAtIndex:6] integerValue];
	if(stemToStart==0){
		stemToStart = dungan;
	}
	while(i<9){
		NSString *s = [[self class] numToStem:stemToStart];
		[hiddenStem replaceObjectAtIndex:palaceToStart withObject:s];
		i++;
		if([self isYinOrYang]==1){
			palaceToStart++;
		}else{
			palaceToStart--;
		}
		if(palaceToStart>9){
			palaceToStart = 1;
		}
		if(palaceToStart<1){
			palaceToStart = 9;
		}
		if(stemToStart==3||stemToStart==2){
			stemToStart--;
		}else if(stemToStart==1){
			stemToStart =4;
		}else{
			stemToStart++;
		}
		if(stemToStart>9){
			stemToStart = 3;
		}
	}
	return 0;
}

- (NSString*)getNthHiddenStem: (int)n{
	if(n<1||n>9){
		return @"无";
	}
	return [hiddenStem objectAtIndex:n];
}

- (int)rotatePlate{
	[self setUpEarthlyPlate];	//转地盘干
	[self findTianyiPalace];
	[self getFushi];	//定符使星门
	[self setUpDoorsPlate];	//定门盘
	[self setUpGodsAndStarsPlate];		//转神盘干
	[self setUpHeavenlyPlate];			//排定星带干
	[self rearrangePalaceArrays];
	return 0;
}

- (int)generate{
	curSBNum = [self getCurSBNum];	//定干支数
	futou = [self getFutouFromSB:[curSBNum subarrayWithRange:NSMakeRange(4,2)]];//找符头数
	yuanNum = [self getYuanNum: futou]; //定三元
	curJieqiNum = [self getCurJieqiNum]; //定节气
	yinyangNum = [self isYinOrYang]; //定阴阳遁
	juNum=[self getJuNum:curJieqiNum Yuan:yuanNum];
	xunshou = [self getXunshouFromSB: [curSBNum subarrayWithRange:NSMakeRange(6,2)]];//定旬首
	dungan = [self getDunGanFromSB:xunshou];

	[self rotatePlate]; //转式-转排天地星门神
	curSBString = [self getCurSB:curSBNum]; //干支汉字
	return 0;
}

-(NSMutableString*) toString{
	NSMutableString *ms = [NSMutableString string];
	[ms appendFormat:@"阳历:%i年%i月%i日%i时&%@%@ %@%@ %@%@ %@%@&节气:%@%@元&符头:%@%@&盘局:%@遁%@局&旬首:%@%@%@&值符:%@&值使:%@", 
		_year,_month,_day,_hour, 
		[curSBString objectAtIndex:0],
		[curSBString objectAtIndex:1],
		[curSBString objectAtIndex:2],
		[curSBString objectAtIndex:3],
		[curSBString objectAtIndex:4],
		[curSBString objectAtIndex:5],
		[curSBString objectAtIndex:6],
		[curSBString objectAtIndex:7],
		[self getCurJieqi:curJieqiNum],
		[[self class] numToYuan:yuanNum],
		[[self class] numToStem:[[futou objectAtIndex:0] integerValue]],
		[[self class] numToBranch:[[futou objectAtIndex:1] integerValue]],
		[self numToYinYang: yinyangNum],
		[[self class] numToString: juNum],
		[[self class] numToStem:[[xunshou objectAtIndex:0] integerValue]],
		[[self class] numToBranch:[[xunshou objectAtIndex:1] integerValue]],
		[[self class] numToStem:dungan],
		[[self class] numToStar:zhifu],
		[[self class] numToDoor:zhishi]
		];
	return ms;
}

-(int) print{
	NSLog([self toString]);
	int i;
	NSMutableString *s = [NSMutableString string];
	[s appendString:@"\n\n"];
	for (i = 1; i < 10; ++i){
		[s appendFormat:@"***%@宫: ",[[self class] numToString:i]];
		int k;
		for (k = 0; k<[[self getNthPalace:i] count]; k++)
		{
			[s appendFormat:@"%@ ",[[self getNthPalace:i] objectAtIndex: k]];
		}
		[s appendString:@"\n"];
	}
	NSLog(@"%@",s);

	return 0;
}


@end



