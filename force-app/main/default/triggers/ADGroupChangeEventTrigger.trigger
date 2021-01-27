trigger ADGroupChangeEventTrigger on AD_Group__ChangeEvent (after insert) {
    System.debug('ADGroupChangeEventTrigger...running...');
    Boolean DisableTriggersFlagPermission = FeatureManagement.checkPermission('DisableTriggersFlag');    
    ADGroupChangeEventTriggerHandler cceth = new ADGroupChangeEventTriggerHandler();
    if ( !DisableTriggersFlagPermission ) {
	    new ADGroupChangeEventTriggerHandler().run();
    }

}