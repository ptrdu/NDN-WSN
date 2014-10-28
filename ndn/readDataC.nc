#include "config.h"
module readDataC{
	provides{
		interface readData;
	}
	uses{
		interface Read<uint16_t> as LightRead;
		interface Read<uint16_t> as TempRead;
		interface Read<uint16_t> as HumidityRead;
		interface content;
		interface Timer<TMilli> as ReadTimer;		
		}
}
implementation{
		
	uint16_t LightData;
	uint16_t TempData;
	uint16_t HumidityData;
	
	readType currentType = lightType;
	csIt* csTable;
	ndnnode* thisNode;
	uint8_t* csNum;
	event void LightRead.readDone(error_t result, uint16_t val){
		// TODO Auto-generated method stub
		csTable = call content.get_cs();
		thisNode = call content.get_node();
		csNum = call content.cs_num();
		if(result == SUCCESS){
		LightData = val;
		currentType = humidityType;
		csTable[0].csName.ability = (*thisNode).nodeLocation;
		csTable[0].csName.dataType = Light;
		csTable[0].weight = 3;
		csTable[0].data = LightData;
		if((*csNum) == 0){
			(*csNum)++;
			}
		}
		
		
	}

	event void TempRead.readDone(error_t result, uint16_t val){
		// TODO Auto-generated method stub
		csTable = call content.get_cs();
		thisNode = call content.get_node();
		csNum = call content.cs_num();
		if(result == SUCCESS){
		TempData = -39.6+0.01*val;
		currentType = lightType;
		csTable[2].csName.ability = (*thisNode).nodeLocation;
		csTable[2].csName.dataType = Temp;
		csTable[2].weight = 3;
		csTable[2].data = TempData;
		if((*csNum) == 2){
			(*csNum)++;
			}
		}
		
	}

	event void HumidityRead.readDone(error_t result, uint16_t val){
		// TODO Auto-generated method stub
		if(result == SUCCESS){
		csTable = call content.get_cs();
		thisNode = call content.get_node();
		csNum = call content.cs_num();	
		HumidityData = -4+0.0405*val+(-2.8/1000000)*(val*val);
		currentType = tempType;
		csTable[1].csName.ability = (*thisNode).nodeLocation;
		csTable[1].csName.dataType = Humidity;
		csTable[1].weight = 3;
		csTable[1].data = HumidityData;
		if((*csNum) == 1){
			(*csNum)++;
			}
		}
		
	}

	event void ReadTimer.fired(){
		// TODO Auto-generated method stub
		if(currentType == lightType){
			call LightRead.read();
		}
		if(currentType == humidityType){
			call HumidityRead.read();
		}
		if(currentType == tempType){
			call TempRead.read();
		}
		
	}

	command void readData.readStart(){
		// TODO Auto-generated method stub
		call ReadTimer.startPeriodic(READTIME);
	}
}