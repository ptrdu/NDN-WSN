configuration ndnWsn{
	provides{
		interface ndn;
		}
}
implementation{
	components ndnC;
	components strategyP;
	components functionsP;
	ndn = ndnC;
	ndnC.net -> strategyP;
	ndnC.readData -> functionsP;
	ndnC.refresh -> functionsP;
	ndnC.content->strategyP;
}