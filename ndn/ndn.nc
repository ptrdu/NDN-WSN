#include"config.h"
/**
 * 整个网络的对外接口
 */
interface ndn{
	/**
	 * 程序入口,启动ndn网络，设置根节点
	 */
	 command void ndnstart(uint16_t rootId);
	 /**
	  * 获取node信息
	  */
	 command ndnnode* node();
}