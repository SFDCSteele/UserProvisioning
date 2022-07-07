trigger ADUserInactivationEventTrigger on AD_User_Inactivation__e (after insert) {
    System.debug('ADUserInactivationEventTrigger...running...'+FeatureManagement.checkPermission('DisableTriggersFlag'));
    Boolean DisableTriggersFlagPermission = FeatureManagement.checkPermission('DisableTriggersFlag');    
    //ADUserInactivationEventTriggerHandler cceth = new ADUserInactivationEventTriggerHandler();
    if ( !DisableTriggersFlagPermission ) {
	    new ADUserInactivationEventTriggerHandler().run();
    }

}