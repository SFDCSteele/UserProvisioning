public class ADGroupChangeEventTriggerHandler extends ChangeEventTriggerHandler {
    
    
    // Map containing all the different change event types
    private Map<String, List<AD_Group__ChangeEvent>> changeEvents;
    //this is a new method that could parse the events based on changetype, so each changeEvent could be processed differently
    public override void parseEventTypes() {
        System.debug('100.01->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:parseEventTypes:inside....');
        String changeType = '';
        List<AD_Group__ChangeEvent> eventArr = new List<AD_Group__ChangeEvent>();
        for(AD_Group__ChangeEvent event : (List<AD_Group__ChangeEvent>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            System.debug('100.02->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:parseEventTypes:header:  '+header);
            
            if (changeEvents.isEmpty() || changeEvents.get(header.changetype) == null ) {
                eventArr = new List<AD_Group__ChangeEvent>();
                eventArr.add(event);
                changeEvents.put(header.changetype,eventArr); 
            } else {
                eventArr = changeEvents.get(header.changetype);
                eventArr.add(event);
                changeEvents.put(header.changetype,eventArr); 
            }
            //if (header.changetype == 'CREATE') {
            //}
        }      
    }
    
    
    public override void processCreate(List<Id> IdsToProcess) {
        System.debug('101.01->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:processCreate:inside....IdsToProcess: '+IdsToProcess);
        processTransactions(IdsToProcess);
        
    }
    
    public override void processUpdate(List<Id> IdsToProcess) {
        System.debug('101.02-##############ADGroupChangeEventTriggerHandler:processUpdate:inside....IdsToProcess: '+IdsToProcess);
        
        processTransactions(IdsToProcess);
    }
    
    
    public override void processDelete(List<Id> IdsToProcess) {
        System.debug('101.03-##############ADGroupChangeEventTriggerHandler:processDelete:inside....IdsToProcess: '+IdsToProcess);
        
        processTransactions(IdsToProcess);
    }
    
    private void processTransactions(List<Id> IdsToProcess) {
        System.debug('777.04-##############ADGroupChangeEventTriggerHandler:processTransactions:Ids: '+IdsToProcess);
        
        AUPJSONGenerator sJSonStr = new AUPJSONGenerator();
        List<AD_Group_Update__e> groupEvents = new List<AD_Group_Update__e>();
        AD_Group_Update__e groupEvent = new AD_Group_Update__e();
        
        String applicationName = '';
        String applicationLevelName = '';
        boolean assignmentFound = false;
        String  grpSJONString = '';
        Integer grpCount = 0;
        for(AD_Group__c grp: [SELECT Id, Name, RecordTypeId, Parent_AD_Group__c, AD_Group_Name__c, Status__c,AD_User__c FROM AD_Group__c where Id =: IdsToProcess]){
            applicationName = '';
            applicationLevelName = '';
            assignmentFound = false;
            System.debug('777.05.100-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+grp.AD_Group_Name__c+' Parent Group Id: '+grp.Parent_AD_Group__c+
                         ' user: '+grp.AD_User__c);
            if ( grp.Parent_AD_Group__c != null ) {
                try {
                    for(AD_Group__c parentGroup : [SELECT Id, Name, RecordTypeId, Parent_AD_Group__c, AD_Group_Name__c, Status__c FROM AD_Group__c where Id =: grp.Parent_AD_Group__c]){
                        //parentGroupName = parentGroup.AD_Group_Name__c;
                        System.debug('777.05.110-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+grp.AD_Group_Name__c+
                                     ' Parent Group Name: '+parentGroup.AD_Group_Name__c);
                        if ( parentGroup.Parent_AD_Group__c != null ) {
                            applicationName = parentGroup.AD_Group_Name__c;
                            applicationLevelName = grp.AD_Group_Name__c;
                            assignmentFound = true;
                        }
                    }
                } catch (NullPointerException npe) {
                    System.debug('777.05.120-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+grp.AD_Group_Name__c+
                                 ' Parent_AD_Group__c: '+grp.Parent_AD_Group__c+' IS NULL!');
                    
                }
            }
            if ( assignmentFound ) {
                System.debug('777.05.XXX-##############ADGroupChangeEventTriggerHandler:processTransactions:applicationName => '+applicationName+
                             ' applicationLevelName: '+applicationLevelName);
                try {
                    for(AD_User__c adUser : [SELECT SECID__c, AD_First_Name__c, AD_Last_Name__c, AD_User_Email__c, AD_Federation_Id__c FROM AD_User__c where Id =: grp.AD_User__c]){
                        System.debug('777.05.130-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+grp.AD_Group_Name__c+
                                     ' User: '+adUser.AD_First_Name__c+' '+adUser.AD_Last_Name__c);
                        groupEvent = new AD_Group_Update__e(
                            AD_SEC_ID__c=aduser.SECID__c,
                            Group_Name__c=applicationLevelName,
                            Email_Address__c=adUser.AD_User_Email__c,
                            Federation_Id__c=adUser.AD_Federation_Id__c,
                            FirstName__c=adUser.AD_First_Name__c,
                            LastName__c=adUser.AD_Last_Name__c,
                            Parent_AD_Group__c=applicationName,
                            Status__c=grp.Status__c);
                        groupEvents.add(groupEvent);  
                        if ( (grpCount++) > 0 ) {
                            grpSJONString += ',';
                        }
                        grpSJONString  += sJSonStr.generateJSONContent('Group', groupEvent);  
                        /*
                        grpSJONString += '{"AD_SEC_ID__c":"'+aduser.SECID__c+'",'+
                            '"Group_Name__c":"'+applicationLevelName+'",'+
                            '"Email_Address__c":"'+adUser.AD_User_Email__c+'",'+
                            '"Federation_Id__c":"'+adUser.AD_Federation_Id__c+'",'+
                            '"FirstName__c":"'+adUser.AD_First_Name__c+'",'+
                            '"LastName__c":"'+adUser.AD_Last_Name__c+'",'+
                            '"Parent_AD_Group__c":"'+applicationName+'",'+
                            '"Status__c":"'+grp.Status__c+'"}';
						*/
                    }
                    System.debug('777.05.200-##############ADGroupChangeEventTriggerHandler:processTransactions:groupEvents => '+groupEvents);
                } catch (NullPointerException npe) {
                    System.debug('777.05.300-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+grp.AD_Group_Name__c+' AD_User__c: '+grp.AD_User__c+' IS NULL!');
                    
                }
            }
        }
        if ( groupEvents.size() > 0 ) {
            // Call method to publish events
            List<Database.SaveResult> srs = EventBus.publish(groupEvents);
            // Inspect publishing result
            for (Database.SaveResult sr: srs ) {
                if (sr.isSuccess()) {
                    System.debug('777.01-##############ADGroupChangeEventTriggerHandler:processTransactions:Successfully published event: '+sr);
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                     err.getStatusCode() +
                                     ' - ' +
                                     err.getMessage());
                    }
                }
            }
            System.debug('777.05.190-##############ADGroupChangeEventTriggerHandler:processTransactions:FINISHING UP!');
            List<Profile> prof = [Select Id,Name from Profile where Name='System Administrator'];
            AUP_Core_Functionality_Settings__c aupSettings = AUP_Core_Functionality_Settings__c.getInstance(prof[0].Id);
            System.debug('AUP Settings: '+
                         '\nExecute\t:\t'+aupSettings.AUP_ENT_Execute__c+
                         '\nUsername\t:\t'+aupSettings.AUP_ENT_Username__c+
                         '\npassword\t:\t'+aupSettings.AUP_ENT_Password__c+
                         '\nClientId\t:\t'+aupSettings.AUP_ENT_Client_Id__c+
                         '\nClientSecret\t:\t'+aupSettings.AUP_ENT_Client_Secret__c+
                         '\nentEndPoint\t:\t'+aupSettings.AUP_ENT_End_Point__c);
            
            System.debug('777.01-##############ADGroupChangeEventTriggerHandler:processUpdate:Sending through the web service? '+aupSettings.AUP_ENT_Execute__c);
            if ( aupSettings.AUP_ENT_Execute__c ) {
                ADPublishUserEvent.processEvents('Group',grpSJONString);
            }
        }
    }
    
    //This method takes all of the events in Trigger.new and maps the record Ids based on change type
    //***this can't be in the Virtual handler as events are typed based on which object it is
    //-----it may be required required to pull in the object based on new critera where the field in question did not actually change
    //--------like the field in question didn't change, but the record type changed which now requires us to look at that field
    public override Map<String, List<Id>> getChangeEventIds () {
        System.debug('104.01->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:inside....');
        Map<String, List<Id>> recordIds = new Map<String, List<Id>>();
        String changeType = '';
        Id recordId;
        List<Id> recordArr = new List<Id>();
        List<String> changedFields = new List<String>();
        //Set<String> caseIds = new Set<String>();
        
        for(AD_Group__ChangeEvent event : (List<AD_Group__ChangeEvent>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            changedFields = header.getChangedFields();
            System.debug('104.02->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:header: '+header+' changeType: '+header.changetype);
            System.debug('104.02.01->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:changeType: '+header.changetype);
            System.debug('104.02.02->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:changedFields: '+changedFields);
            
            if (recordIds.isEmpty() || recordIds.get(header.changetype) == null ) {
                // Get all Record Ids for this change and add to the set
                recordArr = new List<Id>();
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                //if ( changedFields.contains('Status__c') && event.get('Status__c') != 'New' ) {
                    System.debug('104.02.03->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:Fields have changed: '+changedFields);
                    recordIds.put(header.changetype,recordArr); 
                //}
            } else {
                recordArr = recordIds.get(header.changetype);
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                //if ( changedFields.contains('Status__c') && event.get('Status__c') != 'New' ) {
                    System.debug('104.02.04->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:Fields have changed: '+changedFields);
                    recordIds.put(header.changetype,recordArr); 
                //}
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
        System.debug('104.10->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:return recordIds: '+recordIds);
        return recordIds;
    }
    
}