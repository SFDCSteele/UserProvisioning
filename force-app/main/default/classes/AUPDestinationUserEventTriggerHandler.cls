public class AUPDestinationUserEventTriggerHandler extends PlatformEventTriggerHandler {
    
    
    // Map containing all the different change event types
    private Map<String, List<AUP_Destination_User_Event__e>> platformEvents;
    //this is a new method that could parse the events based on changetype, so each changeEvent could be processed differently
    public override void parseEventTypes() {
        System.debug('100.01->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:parseEventTypes:inside....: '+Trigger.new);
        String changeType = 'CREATE';
        List<AUP_Destination_User_Event__e> eventArr = new List<AUP_Destination_User_Event__e>();
        //private Map<String, Integer> myMap = new Map<String, Integer>{'a' => 1, 'b' => 2, 'c' => 3};
        platformEvents = new Map<String, List<AUP_Destination_User_Event__e>>{'TRIGGER' => (List<AUP_Destination_User_Event__e>) Trigger.new};
        System.debug('100.03->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:parseEventTypes:initialized platformEvents....: '+platformEvents);
        for(AUP_Destination_User_Event__e event : (List<AUP_Destination_User_Event__e>) Trigger.new) {
            //EventBus.PlatformEventHeader header = event.PlatformEventHeader;
            System.debug('100.05->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:parseEventTypes:header:  '+changeType+' event: '+event);
            
            System.debug('100.10->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:parseEventTypes:look at platformEvents:  '+platformEvents);
            if (platformEvents == null || platformEvents.get(changeType) == null || platformEvents.isEmpty()  ) {
                eventArr = new List<AUP_Destination_User_Event__e>();
                eventArr.add(event);
            	System.debug('100.20->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:parseEventTypes:empty platformEvents:adding:  '+changeType+' event: '+eventArr);
                platformEvents.put(changeType,eventArr); 
            } else {
                eventArr = platformEvents.get(changeType);
            	System.debug('100.30->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:parseEventTypes:retrieve:  '+changeType+' event: '+eventArr);
                eventArr.add(event);
            	System.debug('100.40->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:parseEventTypes:adding back:  '+changeType+' event: '+eventArr);
                platformEvents.put(changeType,eventArr); 
            }
            System.debug('100.50->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:parseEventTypes:bottom of loop:  '+changeType+' event: '+platformEvents);
        }      
        System.debug('100.90->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:parseEventTypes:exiting:  '+changeType+' event: '+platformEvents);
    }
    
    
    public override void processCreate(List<Id> IdsToProcess) {
        System.debug('101.010->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:processCreate:inside....');
        
        
        //processTransactions(IdsToProcess);
    }
    
    public override void processUpdate(List<Id> IdsToProcess) {
        System.debug('101.020->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:processUpdate:inside....');
        
        
        //processTransactions(IdsToProcess);
    }
    
    public override void afterInsert() {
        System.debug('101.020->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:afterInsert:inside....');
        
        System.debug('777.04-##############AUPDestinationUserEventTriggerHandler:afterInsert:platformEvents: '+platformEvents);
        
        /*
        AUPJSONGenerator sJSonStr = new AUPJSONGenerator();
        String  usrSJONString = '';
        Integer usrCount = 0;
        
        for (AUP_Destination_User_Event__e event : platformEvents.get('CREATE') ) {
            if ( (usrCount++) > 0 ) {
                usrSJONString += ',';
            }
	        usrSJONString  += sJSonStr.generateJSONContent('Group', event);  
        System.debug('777.10-##############AUPDestinationUserEventTriggerHandler:afterInsert:JSON String: '+usrSJONString);
        }
        System.debug('777.20-##############AUPDestinationUserEventTriggerHandler:afterInsert:publishing event: '+usrSJONString);
        */
        AUPDestinationUserService.execute(Trigger.New);
    }
    
    //This method takes all of the events in Trigger.new and maps the record Ids based on change type
    //***this can't be in the Virtual handler as events are typed based on which object it is
    //-----it may be required required to pull in the object based on new critera where the field in question did not actually change
    //--------like the field in question didn't change, but the record type changed which now requires us to look at that field
    //
    /*
    public override Map<String, List<Id>> getChangeEventIds () {
        System.debug('104.01->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:getChangeEventIds:inside....');
        Map<String, List<Id>> recordIds = new Map<String, List<Id>>();
        String changeType = '';
        Id recordId;
        List<Id> recordArr = new List<Id>();
        List<String> changedFields = new List<String>();
        //Set<String> caseIds = new Set<String>();
        
        for(AUP_Destination_User_Event__e event : (List<AUP_Destination_User_Event__e>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            changedFields = header.getChangedFields();
            System.debug('104.02->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:getChangeEventIds:header: '+header+' changeType: '+header.changetype);
            System.debug('104.02.01->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:getChangeEventIds:changeType: '+header.changetype);
            System.debug('104.02.02->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:getChangeEventIds:changedFields: '+changedFields);
            
            if (recordIds.isEmpty() || recordIds.get(header.changetype) == null ) {
                // Get all Record Ids for this change and add to the set
                //List<String> recordIds = change.ChangeEventHeader.getRecordIds();
                //caseIds.addAll(recordIds);
                recordArr = new List<Id>();
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                if ( changedFields.contains('Status__c') ) {
                    System.debug('104.02.03->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:getChangeEventIds:STATUS has changed: '+changedFields);
                    recordIds.put(header.changetype,recordArr); 
                }
            } else {
                recordArr = recordIds.get(header.changetype);
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                if ( changedFields.contains('Status__c') ) {
                    System.debug('104.02.04->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:getChangeEventIds:STATUS has changed: '+changedFields);
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
        System.debug('104.10->>>>>>>>>>>>AUPDestinationUserEventTriggerHandler:getChangeEventIds:return recordIds: '+recordIds);
        return recordIds;
    }
	*/
}