trigger ADGroupUpdateEventTrigger on AD_Group_Update__e (after insert) {
    System.debug('ADGroupUpdateEventTrigger...running...'+FeatureManagement.checkPermission('DisableTriggersFlag'));
    Boolean DisableTriggersFlagPermission = FeatureManagement.checkPermission('DisableTriggersFlag');    
    //ADGroupUpdateEventTriggerHandler cceth = new ADGroupUpdateEventTriggerHandler();
    if ( !DisableTriggersFlagPermission ) {
	    new ADGroupUpdateEventTriggerHandler().run();
    }

}