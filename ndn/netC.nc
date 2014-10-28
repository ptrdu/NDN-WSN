#include "config.h"
module netC{
	provides{
		interface net;
		}
	uses{
		interface StdControl as RoutControl;
		interface RootControl;
		interface Timer<TMilli> as BroTimer;
		}
}
implementation{
	
	command error_t net.start(){
		// TODO Auto-generated method stub
		error_t error = call RoutControl.start();
		return error;
	}

	command void net.setRoot(uint16_t rootId){
		// TODO Auto-generated method stub
		if(TOS_NODE_ID == rootId){
			call RootControl.setRoot();
			}else{
				call RootControl.unsetRoot();
				}
	}

	command void net.fibStart(){
		// TODO Auto-generated method stub
		call BroTimer.startPeriodic(BROTIME);
	}

	event void BroTimer.fired(){
		// TODO Auto-generated method stub
	}
}