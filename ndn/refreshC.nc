#include"config.h"
module refreshC{
	provides{
		interface refresh;
		}
	uses{
		interface Timer<TMilli> as FibRefresh;
		interface Timer<TMilli> as CsRefresh;
 		interface content;
	}
}
implementation{
	uint8_t i;
	csIt* csTable;
	fibIt* fibTable;
	pitIt* pitTable;
	ndnnode* thisNode;
	uint8_t* fibNum;
	uint8_t* csNum;
	uint8_t* pitNum;
	command void refresh.refreshStart(){
		// TODO Auto-generated method stub
		call FibRefresh.startPeriodic(FIBTIME);
		call CsRefresh.startPeriodic(CSTIME);
	}

	event void FibRefresh.fired(){
		// TODO Auto-generated method stub
		fibTable = call content.get_fib();
		thisNode = call content.get_node();
		memset(fibTable,0,sizeof(fibIt)*FIBMAX);
		fibNum = call content.fib_num();
		*fibNum = 0;
		(*thisNode).nodeAbility = (*thisNode).nodeLocation;	
		dbg("refresh","refresh the fib table\n");			
	}

	event void CsRefresh.fired(){
		// TODO Auto-generated method stub
		csTable = call content.get_cs();
		pitTable = call content.get_pit();
		for(i=3;i<CSMAX;i++) memset(&csTable[i],0,sizeof(csIt));
		memset(pitTable,0,sizeof(pitIt)*PITMAX);
		pitNum = call content.pit_num();
		csNum = call content.cs_num();
		*pitNum = 0;
		*csNum = 3;
		dbg("refresh","refresh the cs table and pit table\n");
	}
}