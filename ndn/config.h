#ifndef CONFIG_H
#define CONFIG_H
#define MSGLINE 0x11
#define AM_FIB 0x10
#define FIBMAX 15
#define PITMAX 15
#define CSMAX 15
/**
 * 数据消息的格式
 * BRO:广播消息类型，主要是用来建立FIB表
 * IN:Interest包类型
 * DATA:Data包类型
 */
typedef enum messageType{
	BRO,
	IN,
	DATA,
}messageType;

/**
 * 各个时间信息
 */
enum Time{
	BROTIME = 50001,
	FIBTIME = 9500002,
	READTIME = 10491,
	CSTIME = 9500000,
	
};

/**
 * 读取数据的类型
 */
typedef enum readType{
	lightType,
	tempType,
	humidityType
}readType;

/**
 * 获取数据的类型
 */
typedef enum Type{
 	Light,
 	Temp,
 	Humidity,
 }Type;
 
 /**
 * 经纬度结构
 */
typedef struct point{
	uint16_t x; //经度
	uint16_t y; //维度
}point;

 /**
 * 范围结构，用来当作路由能力，进行前缀匹配
 * 范围用矩形表示
 */
typedef struct location{
	point leftUp; //矩形左上角节点
	point rightDown; //矩形右下角节点
}location;

/**
 * name的结构
 * dataType:
 * Temp,Light,Energy
 */ 
typedef struct name{
	location ability;
	Type dataType;
}name;

/**
 * 节点的结构
 * id：节点的TOS_NODE_ID
 * parent：父亲节点节点号
 * nodeAbility：节点路由能力
 * nodeLocation：节点地理位置
 */
typedef struct ndnnode{
  	uint16_t id;
  	uint16_t parent;
  	location nodeAbility;
  	location nodeLocation;
  }ndnnode; 
  
/**
 * cs条目的结构
 */
typedef struct cs_item{
    name csName;
 	uint8_t weight;
 	uint16_t data;
 }csIt;
 
/**
  * fib条目的结构
  */
typedef struct fib_item{
  	location fibAbility;
  	uint8_t weight;
  	uint16_t goId;
 }fibIt;
 
/**
  * pit条目的结构
  */
typedef struct pit_item{
  	name pitName;
  	uint8_t weight;
  	uint16_t comeId;
  }pitIt;
/**
 * 传感器之间发送和接收的数据
 * msgType:发送数据的类型
 * msgName:消息的命名，包含地理信息
 * data:返回采集数据的载体
 */
typedef struct message{
 	messageType msgType;
 	name msgName;
 	uint16_t data;
 }Msg;
 /**
 * 广播消息格式,每隔周期事件，节点向父亲
 * 节点发送，用来维护FIB表
 */
typedef struct BroMsg{
	messageType msgType;
	location nodeAbility;
}BroMsg;

/**
  * 判断location a是不是等于location b
  */
 bool ability_equal(location a,location b){
 	if((a.leftUp.x == b.leftUp.x) && (a.leftUp.y == b.leftUp.y)){
 		if((a.rightDown.x == b.rightDown.x) && (a.rightDown.y == b.rightDown.y)){
 			return TRUE;
 			}
 		}
 		return FALSE;
 }
 
 /**
  * 判断location a是否属于location b
  * return: TRUE or FALSE
  * TRUE: location a属于location b
  * FALSE：location a不属于location b
  */
 bool location_belong(location a,location b){
 	if((a.leftUp.x >= b.leftUp.x) && (a.leftUp.y <= b.leftUp.y)){
 		if((a.rightDown.x <= b.rightDown.x) && (a.rightDown.y >= b.rightDown.y)){
 			return TRUE;
 			}
 		}
 	return FALSE;
 }
 
 /**
  * 判断是一个点还是一个区域
  */
 bool is_point(location a){
 	 if((a.leftUp.x == a.rightDown.x) && (a.leftUp.y == a.rightDown.y)){
 	 	return TRUE;
 		}
 	return FALSE;
 }
 
 /**
  * 合并区域
  */
 bool location_merge(location a,location b,location * c){
 	if(ability_equal(a,b)) return FALSE;
 	if((is_point(a) && is_point(b)) || (!is_point(a) && !is_point(b))){
 		if(a.leftUp.x<b.leftUp.x) c->leftUp.x = a.leftUp.x;
 		else c->leftUp.x = b.leftUp.x;
 		if(a.leftUp.y<b.leftUp.y) c->leftUp.y = b.leftUp.y;
 		else c->leftUp.y = a.leftUp.y;
 		if(a.rightDown.x < b.rightDown.x) c->rightDown.x = b.rightDown.x;
 		else c->rightDown.x = a.rightDown.x;
 		if(a.rightDown.y < b.rightDown.y) c->rightDown.y = a.rightDown.y;
 		else c->rightDown.y = b.rightDown.y;
 		return TRUE;
 		}
 	if((!is_point(a) && is_point(b)) || (is_point(a) && !is_point(b))){
 		location d = is_point(a)?a:b;
 		location e = !is_point(a)?a:b;
 		if(location_belong(d,e)){
 			*c = e;
 			return TRUE;
 			}
 		else{
 			if(d.leftUp.x<e.leftUp.x) c->leftUp.x = d.leftUp.x;
 			else c->leftUp.x = e.leftUp.x;
 			if(d.leftUp.y<e.leftUp.y) c->leftUp.y = e.leftUp.y;
 			else c->leftUp.y = d.leftUp.y;
 			if(d.rightDown.x < e.rightDown.x) c->rightDown.x = e.rightDown.x;
 			else c->rightDown.x = d.rightDown.x;
 			if(d.rightDown.y < e.rightDown.y) c->rightDown.y = d.rightDown.y;
 			else c->rightDown.y = e.rightDown.y;
 			return TRUE;
 			}
 		}
 	return FALSE;
 }
#endif /* CONFIG_H */
