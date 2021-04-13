trigger ADUserChangeEventTrigger on AD_User__ChangeEvent (after insert) {
    System.debug('ADUserChangeEventTrigger...running...');
    Boolean DisableTriggersFlagPermission = FeatureManagement.checkPermission('DisableTriggersFlag');    
    ADUserChangeEventTriggerHandler cceth = new ADUserChangeEventTriggerHandler();
    if ( !DisableTriggersFlagPermission ) {
	    new ADUserChangeEventTriggerHandler().run();
    }

}