/**
 * ndn接口的具体实现
 * 在ndnstart中，设置了根节点，开启底层的ctp服务以及ndn服务
 * 以及数据读取功能和cs,fib,pit表的刷新功能
 */
module ndnC{
	provides{
		interface ndn;
		}
	uses{
		interface content;
		interface net;
		interface refresh;
		interface readData;
	}
}
implementation{

	command void ndn.ndnstart(uint16_t rootId){
		// TODO Auto-generated method stub
		error_t error = call net.start();
		if(error == SUCCESS){
			call net.setRoot(rootId);
			call net.fibStart();
			call refresh.refreshStart();
			call readData.readStart();
			dbg("boot","ndn network start!\n");
			}
	}

	command ndnnode * ndn.node(){
		// TODO Auto-generated method stub
		return (call content.get_node());
	}
}