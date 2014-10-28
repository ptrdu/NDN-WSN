/**
 * 测试程序
 */
module testC @safe(){
	uses interface ndn;
	uses interface Boot;	
	uses interface SplitControl as AMControl;
	uses interface Timer<TMilli> as TestTimer;
	uses interface Packet;
	uses interface AMSend;
}
implementation{
	ndnnode* thisNode;
	void node_init();
	message_t packet;
	Msg* send;
	location test;
	bool SendBusy=FALSE;
	event void Boot.booted(){
		// TODO Auto-generated method stub
		dbg("boot","node booted!\n");
		thisNode = (call ndn.node());
		node_init();
		call AMControl.start();
	}

	event void AMControl.stopDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void AMControl.startDone(error_t error){
		// TODO Auto-generated method stub
		if(error != SUCCESS){
			call AMControl.start();
			}else{
				//ndn入口，启动ndn网络策略，同时设置１节点作为根节点
				call ndn.ndnstart(1);
				if(TOS_NODE_ID == 1) call TestTimer.startPeriodic(10000000);
				}
	}
	location create_location(uint16_t id){
		location a;
		point p,q;
		p.x = id;
		p.y = id;
		q.x = id;
		q.y = id;
		a.leftUp = p;
		a.rightDown = q;
		return a;
		}
	/**
	 * 由于目前节点能力无法自动获取自己的地理位置信息，
	 * 所以手动为节点设置地理位置信息进行测试
	 * 
	 */
	void node_init(){
		switch(TOS_NODE_ID){
			case(1):
			(*thisNode).nodeLocation = create_location(1);
			break;
			case(2):
			(*thisNode).nodeLocation = create_location(2);
			break;
			case(3):
			(*thisNode).nodeLocation = create_location(3);
			break;
			case(4):
			(*thisNode).nodeLocation = create_location(4);
			break;
			case(5):
			(*thisNode).nodeLocation = create_location(5);
			break;
			case(6):
			(*thisNode).nodeLocation = create_location(6);
			break;
			case(7):
			(*thisNode).nodeLocation = create_location(7);
			break;
			case(8):
			(*thisNode).nodeLocation = create_location(8);
			break;
			case(9):
			(*thisNode).nodeLocation = create_location(9);
			break;
			case(10):
			(*thisNode).nodeLocation = create_location(10);
			break;
			case(11):
			(*thisNode).nodeLocation = create_location(11);
			break;
			case(12):
			(*thisNode).nodeLocation = create_location(12);
			break;
			case(13):
			(*thisNode).nodeLocation = create_location(13);
			break;
			case(14):
			(*thisNode).nodeLocation = create_location(14);
			break;
			case(15):
			(*thisNode).nodeLocation = create_location(15);
			break;
			case(16):
			(*thisNode).nodeLocation = create_location(16);
			break;
			case(17):
			(*thisNode).nodeLocation = create_location(17);
			break;
			case(18):
			(*thisNode).nodeLocation = create_location(18);
			break;
			case(19):
			(*thisNode).nodeLocation = create_location(19);
			break;
			case(20):
			(*thisNode).nodeLocation = create_location(20);
			break;
			case(21):
			(*thisNode).nodeLocation = create_location(21);
			break;
			case(22):
			(*thisNode).nodeLocation = create_location(22);
			break;
			case(23):
			(*thisNode).nodeLocation = create_location(23);
			break;
			case(24):
			(*thisNode).nodeLocation = create_location(24);
			break;
			case(25):
			(*thisNode).nodeLocation = create_location(25);
			break;
			case(26):
			(*thisNode).nodeLocation = create_location(26);
			break;
			case(27):
			(*thisNode).nodeLocation = create_location(27);
			break;
			case(28):
			(*thisNode).nodeLocation = create_location(28);
			break;
			case(29):
			(*thisNode).nodeLocation = create_location(29);
			break;
			case(30):
			(*thisNode).nodeLocation = create_location(30);
			break;
			}
		}
	
	/**
	 * 测试模块，１节点定时发送interest请求
	 */
	event void TestTimer.fired(){
		// TODO Auto-generated method stub
		send = (Msg*)(call Packet.getPayload(&packet, sizeof(Msg)));
		send->msgType = IN;	
		test.leftUp.x = 8;
		test.leftUp.y = 8;
		test.rightDown.x = 8;
		test.rightDown.y = 8;
		(send->msgName).ability = test;
		(send->msgName).dataType = Temp;
		if(!SendBusy){
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(Msg)) == SUCCESS){
				SendBusy = TRUE;
				}
			}
	}


	event void AMSend.sendDone(message_t *msg, error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			SendBusy = FALSE;
			}
	}
}