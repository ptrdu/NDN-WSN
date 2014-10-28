#include "config.h"
configuration strategyP{
	provides{
		interface net;
		interface content;
		}
}
implementation{
	components netC;
	components strategyC;
	components CollectionC as Collector;
	components new TimerMilliC() as BroTimer;
	components new AMReceiverC(MSGLINE) as MsgRec;
	components new AMSenderC(MSGLINE) as MsgSend;
	components new AMReceiverC(AM_FIB) as ParentRec;
	components new AMSenderC(AM_FIB) as BroSend;
	
	net = netC;
	content = strategyC;
	netC.BroTimer -> BroTimer;
	strategyC.BroTimer -> BroTimer;
	netC.RootControl -> Collector;
	netC.RoutControl -> Collector;
	strategyC.CtpInfo -> Collector;
	strategyC.MsgRec -> MsgRec;
	strategyC.MsgSend -> MsgSend;
	strategyC.ParentRec -> ParentRec;
	strategyC.BroSend -> BroSend;
	strategyC.BroAM -> ParentRec;
	strategyC.BroPacket -> BroSend;
	strategyC.MsgAM -> MsgRec;
	strategyC.MsgPacket -> MsgSend;
}