public class ADGroupUpdateEventTriggerHandler extends PlatformEventTriggerHandler {
    
    
    // Map containing all the different change event types
    private Map<String, List<AD_Group_Update__e>> platformEvents;
    //this is a new method that could parse the events based on changetype, so each changeEvent could be processed differently
    public override void parseEventTypes() {
        System.debug('100.01->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:parseEventTypes:inside....: '+Trigger.new);
        String changeType = 'CREATE';
        List<AD_Group_Update__e> eventArr = new List<AD_Group_Update__e>();
        //private Map<String, Integer> myMap = new Map<String, Integer>{'a' => 1, 'b' => 2, 'c' => 3};
        platformEvents = new Map<String, List<AD_Group_Update__e>>{'TRIGGER' => (List<AD_Group_Update__e>) Trigger.new};
        System.debug('100.03->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:parseEventTypes:initialized platformEvents....: '+platformEvents);
        for(AD_Group_Update__e event : (List<AD_Group_Update__e>) Trigger.new) {
            //EventBus.PlatformEventHeader header = event.PlatformEventHeader;
            System.debug('100.05->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:parseEventTypes:header:  '+changeType+' event: '+event);
            
            System.debug('100.10->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:parseEventTypes:look at platformEvents:  '+platformEvents);
            if (platformEvents == null || platformEvents.get(changeType) == null || platformEvents.isEmpty()  ) {
                eventArr = new List<AD_Group_Update__e>();
                eventArr.add(event);
            	System.debug('100.20->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:parseEventTypes:empty platformEvents:adding:  '+changeType+' event: '+eventArr);
                platformEvents.put(changeType,eventArr); 
            } else {
                eventArr = platformEvents.get(changeType);
            	System.debug('100.30->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:parseEventTypes:retrieve:  '+changeType+' event: '+eventArr);
                eventArr.add(event);
            	System.debug('100.40->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:parseEventTypes:adding back:  '+changeType+' event: '+eventArr);
                platformEvents.put(changeType,eventArr); 
            }
            System.debug('100.50->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:parseEventTypes:bottom of loop:  '+changeType+' event: '+platformEvents);
        }      
        System.debug('100.90->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:parseEventTypes:exiting:  '+changeType+' event: '+platformEvents);
    }
    
    
    public override void processCreate(List<Id> IdsToProcess) {
        System.debug('101.010->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:processCreate:inside....');
        
        
        //processTransactions(IdsToProcess);
    }
    
    public override void processUpdate(List<Id> IdsToProcess) {
        System.debug('101.020->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:processUpdate:inside....');
        
        
        //processTransactions(IdsToProcess);
    }
    
    public override void afterInsert() {
        System.debug('101.020->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:afterInsert:inside....');
        
        System.debug('777.04-##############ADUserInactivationEventTriggerHandler:afterInsert:platformEvents: '+platformEvents);
        
        AUPJSONGenerator sJSonStr = new AUPJSONGenerator();
        String  grpSJONString = '';
        Integer grpCount = 0;
        
        for (AD_Group_Update__e event : platformEvents.get('CREATE') ) {
            if ( (grpCount++) > 0 ) {
                grpSJONString += ',';
            }
	        grpSJONString  += sJSonStr.generateJSONContent('Group', event);  
        System.debug('777.10-##############ADUserInactivationEventTriggerHandler:afterInsert:JSON String: '+grpSJONString);
        }
        System.debug('777.20-##############ADUserInactivationEventTriggerHandler:afterInsert:publishing event: '+grpSJONString);
        ADUpdateGroupService.execute(grpSJONString);
    }
    
    //This method takes all of the events in Trigger.new and maps the record Ids based on change type
    //***this can't be in the Virtual handler as events are typed based on which object it is
    //-----it may be required required to pull in the object based on new critera where the field in question did not actually change
    //--------like the field in question didn't change, but the record type changed which now requires us to look at that field
    //
    /*
    public override Map<String, List<Id>> getChangeEventIds () {
        System.debug('104.01->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:getChangeEventIds:inside....');
        Map<String, List<Id>> recordIds = new Map<String, List<Id>>();
        String changeType = '';
        Id recordId;
        List<Id> recordArr = new List<Id>();
        List<String> changedFields = new List<String>();
        //Set<String> caseIds = new Set<String>();
        
        for(AD_Group_Update__e event : (List<AD_Group_Update__e>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            changedFields = header.getChangedFields();
            System.debug('104.02->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:getChangeEventIds:header: '+header+' changeType: '+header.changetype);
            System.debug('104.02.01->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:getChangeEventIds:changeType: '+header.changetype);
            System.debug('104.02.02->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:getChangeEventIds:changedFields: '+changedFields);
            
            if (recordIds.isEmpty() || recordIds.get(header.changetype) == null ) {
                // Get all Record Ids for this change and add to the set
                //List<String> recordIds = change.ChangeEventHeader.getRecordIds();
                //caseIds.addAll(recordIds);
                recordArr = new List<Id>();
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                if ( changedFields.contains('Status__c') ) {
                    System.debug('104.02.03->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:getChangeEventIds:STATUS has changed: '+changedFields);
                    recordIds.put(header.changetype,recordArr); 
                }
            } else {
                recordArr = recordIds.get(header.changetype);
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                if ( changedFields.contains('Status__c') ) {
                    System.debug('104.02.04->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:getChangeEventIds:STATUS has changed: '+changedFields);
                    recordIds.put(header.changetype,recordArr); 
                }
            }
            //now put them in an 'ALL' type
            if (recordIds.isEmpty() || recordIds.get('ALL') == null ) {
                recordArr = new List<Id>();
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                recordIds.put('ALL',recordArr); 
            } else {
                recordArr = recordIds.get('ALL');
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                recordIds.put('ALL',recordArr); 
            }
        }      
        System.debug('104.10->>>>>>>>>>>>ADUserInactivationEventTriggerHandler:getChangeEventIds:return recordIds: '+recordIds);
        return recordIds;
    }
	*/
}