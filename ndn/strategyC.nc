#include "config.h";
/**
 * 网络主要的策略模块，实现了整个ndn流程，包括了FIB表的建立
 * Interest包和Data包的收发处理。
 */
module strategyC @safe(){
	provides{
		interface content;
	}
	uses{
		interface AMPacket as BroAM;
		interface Packet as BroPacket;
		interface AMPacket as MsgAM;
		interface Packet as MsgPacket;
		interface AMSend as BroSend;
		interface AMSend as MsgSend;
		interface Receive as MsgRec;
		interface Receive as ParentRec;
		interface Timer<TMilli> as BroTimer;
		interface CtpInfo;
	};
}
implementation{
	message_t packet;
	message_t broPacket;
	am_addr_t addr; 
	
	BroMsg* broSend;
	BroMsg* broRec;
	
	Msg* send;
	Msg* receive;
	
	bool sendBusy = FALSE;	
	am_addr_t parent = 0;//节点的父亲节点信息
	
	uint8_t fibNum = 0;
	uint8_t fibFlag;
	uint8_t fibMin = 3;
	
	uint8_t csNum = 0;
	uint8_t csFlag;
	uint8_t csMin = 3;
	
	uint8_t pitNum = 0;
	uint8_t pitFlag;
	uint8_t pitMin = 3;
	
	fibIt fibTable[FIBMAX];
	csIt csTable[CSMAX];
	pitIt pitTable[PITMAX];
	
	uint8_t i,j;
	
	Type type0,type1;	
	ndnnode thisNode;
	
	#ifndef SIM
	location SIM;
	point SIM_a;
	point SIM_b;
	#endif
	
	bool fib_update(am_addr_t Addr,location ability);
	bool cs_query_In(Msg* Rec,message_t* rec);
	bool pit_query_In(Msg* Rec,message_t* rec);
	bool fib_query_In(Msg* Rec,message_t* rec);
	bool cs_query_Data(Msg* Rec,message_t* rec);
	bool pit_query_Data(Msg* Rec,message_t* rec);
	
		
	event void BroSend.sendDone(message_t *msg, error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			sendBusy = FALSE;
		}
	}
	
	event void MsgSend.sendDone(message_t *msg, error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			sendBusy = FALSE;
		}
	}
	event message_t * MsgRec.receive(message_t *msg, void *payload, uint8_t len){
		// TODO Auto-generated method stub
		receive = (Msg*)(payload);
		if(len == sizeof(Msg)){
			if(receive->msgType == IN){
				if(cs_query_In(receive,msg)){
					return msg;
					}
				else if(pit_query_In(receive,msg)){
					return msg;
					}
				else if(fib_query_In(receive,msg)){
					return msg;
					}
			}
			if(receive->msgType == DATA){
				if(cs_query_Data(receive,msg)){
					return msg;
					}
				else if(pit_query_Data(receive,msg)){
					return msg;
					}
				}
		}
		return msg;
	}

	event void BroTimer.fired(){
		// TODO Auto-generated method stub
		broSend = (BroMsg*)(call BroPacket.getPayload(&broPacket, sizeof(BroMsg)));
		broSend->msgType = BRO;
		memcpy(&(broSend->nodeAbility),&(thisNode.nodeAbility),sizeof(location));
		call CtpInfo.getParent(&parent);
		thisNode.parent = parent;
		if(!sendBusy){
			if((call BroSend.send(thisNode.parent, &broPacket, sizeof(BroMsg))) == SUCCESS){
				sendBusy = TRUE;
				}
			}		
	}

	event message_t * ParentRec.receive(message_t *msg, void *payload, uint8_t len){
		// TODO Auto-generated method stub
		broRec = (BroMsg*)payload;
		addr = call BroAM.source(msg);
		if(len == sizeof(BroMsg)){
			if(broRec->msgType == BRO){
				location_merge(thisNode.nodeAbility,broRec->nodeAbility,&(thisNode.nodeAbility));
				fib_update(addr,broRec->nodeAbility);
				}
			}			
		return msg;
	}
	
	/**
	 * 添加条目到fib表中，fib初始化函数。
	 * return： FALSE或TRUE
	 * FALSE：如果fib表中已经有这条条目
	 * TRUE：fib表中没有该fib条目，将该消息加入到fib表中
	 */
	bool fib_update(am_addr_t Addr,location ability){
		for(i=0;i<fibNum;i++){
			if(ability_equal(fibTable[i].fibAbility,ability)) {
				return TRUE;
				}
			}
		if(fibNum<FIBMAX){
			memset(&fibTable[fibNum],0,sizeof(fibIt));
			memcpy(&(fibTable[fibNum].fibAbility),&ability,sizeof(location));
			fibTable[fibNum].goId = Addr;
			fibTable[fibNum].weight = 3;
			#ifndef SIM
			SIM = fibTable[fibNum].fibAbility;
			SIM_a = SIM.leftUp;
			SIM_b = SIM.rightDown;
			#endif
			fibNum++;
			dbg("FIB","add a FIB item:/(%d,%d)/(%d,%d),the fibNum:%d\n",
			SIM_a.x,SIM_a.y,
			SIM_b.x,SIM_b.y,
			fibNum
			);
			}
		else if(fibNum >= FIBMAX){
			for(i=0;i<fibNum;i++){
				//如果fib表已经满了，删除权值最小的一条条目。
				if(fibTable[i].weight == 0){
					memset(&fibTable[i],0,sizeof(fibIt));
					memcpy(&(fibTable[i].fibAbility),&ability,sizeof(location));
		        	fibTable[i].goId = Addr;
		        	fibTable[i].weight = 3;
		        	#ifndef SIM
					SIM = fibTable[i].fibAbility;
					SIM_a = SIM.leftUp;
					SIM_b = SIM.rightDown;
					#endif
					dbg("FIB","change a FIB item:/(%d,%d)/(%d,%d),the fibNum:%d\n",
					SIM_a.x,SIM_a.y,
					SIM_b.x,SIM_b.y,
					fibNum
					);
					return FALSE;
					}
				if(fibTable[i].weight < fibMin){
					fibFlag = i;
					fibMin = fibTable[i].weight;
					}
				}
				memset(&fibTable[fibFlag],0,sizeof(fibIt));
		    	memcpy(&(fibTable[fibFlag].fibAbility),&ability,sizeof(location));
		    	fibTable[fibFlag].goId = Addr;
		    	fibTable[fibFlag].weight = 3;
		    	#ifndef SIM
				SIM = fibTable[i].fibAbility;
				SIM_a = SIM.leftUp;
				SIM_b = SIM.rightDown;
				#endif
				dbg("FIB","change a FIB item:/(%d,%d)/(%d,%d),the fibNum:%d\n",
				SIM_a.x,SIM_a.y,
				SIM_b.x,SIM_b.y,
				fibNum
				);
		}
		fibMin = 3;
		return FALSE;
	}
	/**
	 * 节点收到Interest包，查询cs表的函数。
	 * return：TRUE或FALSE
	 * TRUE：当找到相匹配的cs条目，构造data包返回
	 * FALSE：没有相匹配的条目
	 */
	bool cs_query_In(Msg* Rec,message_t* rec){
	addr = call MsgAM.source(rec);
	for(i=0;i<csNum;i++){
		if(csTable[i].weight !=0){
			csTable[i].weight--;
		}
	}
	dbg("CS","Query the CS table when get an Interest packet!\n");
	for(i=0;i<csNum;i++){
		if(ability_equal((Rec->msgName).ability,(csTable[i].csName).ability)){
			type0 = (Rec->msgName).dataType;
			type1 = csTable[i].csName.dataType;
			if(type1 == type0){
 				send = (Msg*)(call MsgPacket.getPayload(&packet, sizeof(Msg)));
				memset(send,0,sizeof(Msg));
				send->msgType = DATA;
				memcpy(&(send->msgName),&(Rec->msgName),sizeof(name));
				send->data = csTable[i].data;
				csTable[i].weight++;
				if(!sendBusy){
					if(call MsgSend.send(addr, &packet, sizeof(Msg)) == SUCCESS){
						sendBusy = TRUE;
						}
					}
				#ifndef SIM
				SIM = (send->msgName).ability;
				SIM_a = SIM.leftUp;
				SIM_b = SIM.rightDown;
				dbg("CS","find the matched item in the cs table:\n/(%d,%d)/(%d,%d)/%d/%d/\ncreate a data packet and tranismit to:%d\n",
				SIM_a.x,SIM_a.y,
				SIM_b.x,SIM_b.y,
				type0,send->data,
				addr
				);
				#endif
					return TRUE;
				}
			}
		}
		return FALSE;
	}
	/**
	 * 节点收到Interest数据包时，查询pit表的函数
	 * return： TRUE或FALSE
	 * TRUE:pit表中已经有相应的条目，丢弃这个interest包
	 * FALSE：pit表中没有这个条目，将这个条目添加到pit表中
	 */
	bool pit_query_In(Msg* Rec,message_t* rec){
	addr = call MsgAM.source(rec);
	for(i=0;i<pitNum;i++){
		if(pitTable[i].weight !=0){
			pitTable[i].weight--;
		}
	}
	dbg("PIT","Query the PIT table when get a Interest packet!\n");
	for(i=0;i<pitNum;i++){
		if(ability_equal((Rec->msgName).ability,(pitTable[i].pitName).ability)){
			type0 = (Rec->msgName).dataType;
			type1 = pitTable[i].pitName.dataType;
			if(type0 == type1){
				pitTable[i].weight++;
				dbg("PIT","find the matched pit item,discard the Interest packet!\n");
				return TRUE;
				}
			}
		}
	if(pitNum < PITMAX){
		memset(&(pitTable[pitNum]),0,sizeof(pitIt));
		memcpy(&(pitTable[pitNum].pitName),&(Rec->msgName),sizeof(name));
		pitTable[pitNum].comeId = addr;
		pitTable[pitNum].weight = 3;
		#ifndef SIM
		SIM = (pitTable[pitNum].pitName).ability;
		SIM_a = SIM.leftUp;
		SIM_b = SIM.rightDown;
		#endif
		pitNum++;
		dbg("PIT","add a PIT item:/(%d,%d)/(%d,%d)/IN from %d,the fibNum:%d\n",
			SIM_a.x,SIM_a.y,
			SIM_b.x,SIM_b.y,
			addr,pitNum
			);
		}
	if(pitNum >= PITMAX){
		for(i=0;i<pitNum;i++){
			if(pitTable[i].weight == 0){
				memset(&pitTable[i],0,sizeof(pitIt));
				memcpy(&(pitTable[i].pitName),&(Rec->msgName),sizeof(name));
				pitTable[i].comeId = addr;
		        pitTable[i].weight = 3;
		        #ifndef SIM
				SIM = (pitTable[i].pitName).ability;
				SIM_a = SIM.leftUp;
				SIM_b = SIM.rightDown;
				#endif
				dbg("PIT","change a PIT item:/(%d,%d)/(%d,%d)/IN from %d,the fibNum:%d\n",
				SIM_a.x,SIM_a.y,
				SIM_b.x,SIM_b.y,
				addr,pitNum
				);
		        return FALSE;
				}
			if(pitTable[i].weight < pitMin){
				pitFlag = i;
				pitMin = pitTable[i].weight;
				}
			}
			memset(&pitTable[pitFlag],0,sizeof(pitIt));
			memcpy(&(pitTable[pitFlag].pitName),&(Rec->msgName),sizeof(name));
			pitTable[pitFlag].comeId = addr;
		    pitTable[pitFlag].weight = 3;
		    pitMin = 3;
		    #ifndef SIM
			SIM = (pitTable[pitFlag].pitName).ability;
			SIM_a = SIM.leftUp;
			SIM_b = SIM.rightDown;
			#endif
			dbg("PIT","change a PIT item:/(%d,%d)/(%d,%d)/IN from %d,the fibNum:%d\n",
			SIM_a.x,SIM_a.y,
			SIM_b.x,SIM_b.y,
			addr,pitNum
			);
		}
		return FALSE;
	}
	/**
	 * 当节点收到一个interest包查询fib表的函数
	 * return：TRUE或FALSE
	 * TRUE：fib表中有相匹配的项目，根据fib条目消息继续转发interest包
	 * FALSE：没有想匹配的项目
	 */
	bool fib_query_In(Msg* Rec,message_t* rec){
	for(i=0;i<fibNum;i++){
		if(fibTable[i].weight !=0){
			fibTable[i].weight--;
			}
		}
	dbg("FIBI","Query the FIB table when get an Interest packet!\n");
	for(i=0;i<fibNum;i++){
		if(location_belong((Rec->msgName).ability,fibTable[i].fibAbility)){
			send = (Msg*)(call MsgPacket.getPayload(&packet, sizeof(Msg)));
			memset(send,0,sizeof(Msg));
			memcpy(&(send->msgName),&(Rec->msgName),sizeof(name));
			send->msgType = IN; 
			fibTable[i].weight++;
			if(!sendBusy){
				if((call MsgSend.send(fibTable[i].goId, &packet, sizeof(Msg))) == SUCCESS){
					#ifndef SIM
					SIM = fibTable[i].fibAbility;
					SIM_a = SIM.leftUp;
					SIM_b = SIM.rightDown;
					#endif
					dbg("FIBI","find the matched item in the FIB table:\n/(%d,%d)/(%d,%d)/\ntransmit the packet to the:%d\n",
					SIM_a.x,SIM_a.y,
					SIM_b.x,SIM_b.y,
					fibTable[i].goId
					);
					sendBusy = TRUE;
					}	
				}
			}
		}
		return TRUE;
	}
	/**
	 * 当节点收一条data消息后，查询cs表的函数
	 * return：TRUE或FALSE
	 * TRUE：cs表中已经有相同的条目了，丢弃这条cs消息
	 * FALSE：cs表种没有相应的条目，将该CS保存到cs表中
	 */
	bool cs_query_Data(Msg* ndwRec,message_t* rec){
	dbg("CSD","Query the CS table when get a Data packet!\n");
	for(i=0;i<csNum;i++){
		if(ability_equal((ndwRec->msgName).ability,(csTable[i].csName).ability)){
			type0 = (ndwRec->msgName).dataType;
			type1 = pitTable[i].pitName.dataType;
			if(type0 == type1){
				dbg("CSD","Find the matched in the CS table,discard the Data packet!\n");
				return TRUE;
				}
			}
		}
	if(csNum < CSMAX){
		memset(&(csTable[csNum]),0,sizeof(csIt));
		memcpy(&(csTable[csNum].csName),&(ndwRec->msgName),sizeof(name));
		csTable[csNum].weight = 3;
		csTable[csNum].data = ndwRec->data;
		#ifndef SIM
		SIM = (csTable[csNum].csName).ability;
		SIM_a = SIM.leftUp;
		SIM_b = SIM.rightDown;
		#endif
		csNum++;
		dbg("CSD","add a cs item:/(%d,%d)/(%d,%d)/%d/%d/\nthe csNum:%d\n",
		SIM_a.x,SIM_a.y,
		SIM_b.x,SIM_b.y,
		(ndwRec->msgName).dataType,
		ndwRec->data,
		csNum
		);
		}
	if(csNum >= CSMAX){
		for(i=0;i<csNum;i++){
			if(csTable[i].weight == 0){
				memset(&csTable[i],0,sizeof(csIt));
				memcpy(&(csTable[i].csName),&(ndwRec->msgName),sizeof(name));
				csTable[i].data = ndwRec->data;
		        csTable[i].weight = 3;
		        #ifndef SIM
		        SIM = (csTable[i].csName).ability;
		        SIM_a = SIM.leftUp;
		        SIM_b = SIM.rightDown;
		        dbg("CSD","change a cs item:/(%d,%d)/(%d,%d)/%d/%d/\nthe csNum:%d",
				SIM_a.x,SIM_a.y,
				SIM_b.x,SIM_b.y,
				(csTable[i].csName).dataType,
				csTable[i].data,csNum
				);
		        #endif
		        return FALSE;
				}
			if(csTable[i].weight < csMin){
				csFlag = i;
				csMin = csTable[i].weight;
				}
			}
			memset(&csTable[csFlag],0,sizeof(csIt));
			memcpy(&(csTable[csFlag].csName),&(ndwRec->msgName),sizeof(name));
			csTable[csFlag].data = ndwRec->data;
		    csTable[csFlag].weight = 3;
		    csMin = 3;
		    #ifndef SIM
		    SIM = (csTable[csFlag].csName).ability;
		    SIM_a = SIM.leftUp;
		    SIM_b = SIM.rightDown;
		    dbg("CSD","change a cs item:/(%d,%d)/(%d,%d)/%d/%d/\nthe csNum:%d",
				SIM_a.x,SIM_a.y,
				SIM_b.x,SIM_b.y,
				(csTable[csFlag].csName).dataType,
				csTable[csFlag].data,csNum
				);
		        #endif
		}
		return FALSE;
	}
	/**
	 * 当节点收到一个data包，查询pit表的函数
	 * return：TRUE或FALSE
	 * TRUE：pit表中有匹配的条目，构造一个data包根据pit表中的条目返回数据
	 * FALSE：没有匹配条目
	 */
	bool pit_query_Data(Msg* ndwRec,message_t* rec){
	dbg("PITD","Query the PIT table when get a Data packet!\n");
	for(i=0;i<pitNum;i++){
		if(ability_equal((ndwRec->msgName).ability,(pitTable[i].pitName).ability)){
			type0 = (ndwRec->msgName).dataType;
			type1 = pitTable[i].pitName.dataType;
			if(type0 == type1){
				send = (Msg*)(call MsgPacket.getPayload(&packet, sizeof(Msg)));
				memset(send,0,sizeof(Msg));
				send->data = ndwRec->data;
				send->msgType = DATA;
				memcpy(&(send->msgName),&(ndwRec->msgName),sizeof(name));
				#ifndef SIM
				SIM = (send->msgName).ability;
				SIM_a = SIM.leftUp;
				SIM_b = SIM.rightDown;
				dbg("PITD","find the matched pit item:/(%d,%d)/(%d,%d)/%d \ntransmit the data packet:\n /(%d,%d)/(%d,%d)/%d/%d \nto the:%d!\n",
				SIM_a.x,SIM_a.y,
				SIM_b.x,SIM_b.y,
				(send->msgName).dataType,
				SIM_a.x,SIM_a.y,
				SIM_b.x,SIM_b.y,
				(send->msgName).dataType,
				send->data,
				pitTable[i].comeId
				);
				#endif
				if(!sendBusy){
					if((call MsgSend.send(pitTable[i].comeId, &packet, sizeof(Msg))) == SUCCESS){
						sendBusy = TRUE;
						}	
					}
					j = i;
					for(j=i;j<pitNum-1;j++){
						pitTable[j] = pitTable[j+1];
						}
						memset(&pitTable[pitNum-1],0,sizeof(pitIt));
						pitNum--;
						dbg("PITD","Delete the PIT item,the pitNum:%d\n",pitNum);
					return TRUE;
				}
			}
		}
		dbg("PITD","cannot find the matched item,discard the Data packet!\n");
		return FALSE;
	}	

	command fibIt * content.get_fib(){
		// TODO Auto-generated method stub
		return fibTable;
	}

	command pitIt * content.get_pit(){
		// TODO Auto-generated method stub
		return pitTable;
	}

	command csIt * content.get_cs(){
		// TODO Auto-generated method stub
		return csTable;
	}

	command ndnnode* content.get_node(){
		// TODO Auto-generated method stub
		return &thisNode;
	}

	command uint8_t* content.cs_num(){
		// TODO Auto-generated method stub
		return &csNum;
	}

	command uint8_t * content.pit_num(){
		// TODO Auto-generated method stub
		return &pitNum;
	}

	command uint8_t * content.fib_num(){
		// TODO Auto-generated method stub
		return &fibNum;
	}

}