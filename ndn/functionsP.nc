/**
 * 配置文件，提供两个接口
 * interface:refresh
 * 用来定时刷新网络中的cs表，pit表以及fib表
 * interface: readData
 * 读取数据的接口，控制节点上的传感器定时的读取数据
 */
configuration functionsP{
	provides{
		interface refresh;
		interface readData;
		}
}
implementation{
	components readDataC;
	components refreshC;
	components strategyP;
	components new TimerMilliC() as FibTimer;
	components new TimerMilliC() as CsTimer;
	components new TimerMilliC() as ReadTimer;
	/**the module used for simulate**/
	components new DemoSensorC();
	/**the two module used for telosb mote**/
	//components new SensirionSht11C();
	//components new HamamatsuS1087ParC();
		
	refresh = refreshC;
	readData = readDataC;
	refreshC.content -> strategyP;
	refreshC.CsRefresh->CsTimer;
	refreshC.FibRefresh->FibTimer;
	
	readDataC.content -> strategyP;
	/**for simulate**/
	readDataC.HumidityRead -> DemoSensorC;
	readDataC.LightRead -> DemoSensorC;
	readDataC.TempRead -> DemoSensorC;
	/**for telosb**/
	//readDataC.HumidityRead -> SensirionSht11C.Humidity;
	//readDataC.TempRead -> SensirionSht11C.Temperature;
	//readDataC.LightRead -> HamamatsuS1087ParC;
	readDataC.ReadTimer	-> ReadTimer;
}