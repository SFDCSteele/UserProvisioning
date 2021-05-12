trigger AUPDestinationUserEventTrigger on AUP_Destination_User_Event__e (after insert) {
    System.debug('AUPDestinationUserEventTrigger...running...'+FeatureManagement.checkPermission('DisableTriggersFlag'));
    Boolean DisableTriggersFlagPermission = FeatureManagement.checkPermission('DisableTriggersFlag');    
    //ADGroupUpdateEventTriggerHandler cceth = new ADGroupUpdateEventTriggerHandler();
    if ( !DisableTriggersFlagPermission ) {
	    new AUPDestinationUserEventTriggerHandler().run();
    }

}