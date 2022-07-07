trigger AppAccessChangeEventTrigger on CF_Application_Access__ChangeEvent (after insert) {
    System.debug('ADGroupChangeEventTrigger...running...');
    Boolean DisableTriggersFlagPermission = FeatureManagement.checkPermission('DisableTriggersFlag');    
    AppAccessChangeEventTriggerHandler cceth = new AppAccessChangeEventTriggerHandler();
    if ( !DisableTriggersFlagPermission ) {
	    new AppAccessChangeEventTriggerHandler().run();
    }

}