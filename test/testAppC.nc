#define MSGLINE 0x11
configuration testAppC{
}
implementation{
	components testC,MainC;
	components ActiveMessageC;
	components ndnWsn;
	components new TimerMilliC() as TestTimer;
	components new AMSenderC(MSGLINE);
	testC.Boot -> MainC;
	testC.AMControl-> ActiveMessageC;
	testC.ndn -> ndnWsn;
	testC.TestTimer->TestTimer;
	testC.Packet->AMSenderC;
	testC.AMSend->AMSenderC;
}