#include "config.h"
/**
 * content接口
 * 主要功能是获取整个网络结构中的信息.
 */
interface content{
	/**
	 * 获取FIB表地址
	 */
	command fibIt* get_fib();
	/**
	 * 获取PIT表地址
	 */
	command pitIt* get_pit();
	/**
	 * 获取CS表地址
	 */
	command csIt* get_cs();
	/**
	 * 获取node信息
	 */
	command ndnnode* get_node();
	/**
	 * 获取cs条目的数量
	 */
	command uint8_t* cs_num();
	/**
	 * 获取fib条目数量
	 */
	command uint8_t* fib_num();
	/**
	 * 获取pit条目数量
	 */
	command uint8_t* pit_num(); 
}