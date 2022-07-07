trigger ADApplicationRequestEventTrigger on AD_Application_Request__ChangeEvent (after insert) {
    System.debug('ADApplicationRequestEventTrigger...running...');
    Boolean DisableTriggersFlagPermission = FeatureManagement.checkPermission('DisableTriggersFlag');    
    ADApplicationRequestEventTriggerHandler arceth = new ADApplicationRequestEventTriggerHandler();
    if ( !DisableTriggersFlagPermission ) {
	    new ADApplicationRequestEventTriggerHandler().run();
    }

}