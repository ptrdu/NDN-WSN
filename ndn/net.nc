interface net{
	/**
	 * 启动底层的ctp协议
	 */
	command error_t start();
	/**
	 * 设置根节点
	 */
	command void setRoot(uint16_t rootId);
	/**
	 * 开始Fib广播
	 */
	command void fibStart();
}