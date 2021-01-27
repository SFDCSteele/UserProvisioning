public class ADGroupChangeEventTriggerHandler extends ChangeEventTriggerHandler {
    
    
    // Map containing all the different change event types
    private Map<String, List<AD_Group__ChangeEvent>> changeEvents;
    //this is a new method that could parse the events based on changetype, so each changeEvent could be processed differently
    public override void parseEventTypes() {
        String changeType = '';
        List<AD_Group__ChangeEvent> eventArr = new List<AD_Group__ChangeEvent>();
        for(AD_Group__ChangeEvent event : (List<AD_Group__ChangeEvent>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            
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
        
        //each team could either add fields to this SOQL or perform an additional SOQL based on their own criteria and then call their method/class
        //List<AD_Group__c> AD_Group__c = [select Id,AD_Group_Name__c,AD_User__c,Parent_AD_Group__r.AD_Group_Name__c,Status__c from AD_Group__c where Id= : IdsToProcess];
        
        //each team could place their calls here to process CREATED ADGroups
        //executeAccountCheck(AD_Group__c);
    }
    
    private void executeAccountCheck(List<AD_Group__c> passedADGroups) {
        //Unverified Veteran
        //rADGroupUVId = Schema.SObjectType.ADGroup.getRecordTypeInfosByName().get('Unverified Veteran').getRecordTypeId();
        Id groupRecTypeId = Schema.SObjectType.AD_Group__c.getRecordTypeInfosByName().get('ADGroupMain').getRecordTypeId();
        //Verified Veteran
        //rADGroupVId = Schema.SObjectType.ADGroup.getRecordTypeInfosByName().get('WH_VA_Call_Center_Veteran').getRecordTypeId();
        //Id contWHVRecTypeId = Schema.SObjectType.AD_Group__c.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        //Account record type
        //Id acctRecTypeId = Schema.SObjectType.ADGroup.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        //Id acctRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        
        //Account creation variables
        /*
        List<Account> newAccounts = new List<Account>();
        
        for (AD_Group__c cont : passedADGroups) {
            
            if ( (cont.RecordTypeId == groupRecTypeId || cont.RecordTypeId == contWHVRecTypeId) && cont.AccountId==null ) {
                newAccounts.add(new Account(Name = cont.FirstName + ' ' + cont.LastName, RecordTypeID = acctRecTypeId));                
            }
            
        }
        insert newAccounts;
        List<AD_Group__c> updateADGroups = new List<AD_Group__c>();
        //loop through the ADGroups, match up to the newly created accounts, adding the Id to the ADGroup
        for (AD_Group__c cont : passedADGroups) {
            
            if ( (cont.RecordTypeId == contUVRecTypeId || cont.RecordTypeId == contWHVRecTypeId) && cont.AccountId==null ) {
                for (Account acct: newAccounts ) {
                    //compName = cont.FirstName + ' ' + cont.LastName;
                    if ( acct.Name == (cont.FirstName + ' ' + cont.LastName) ) {
                        cont.AccountId = acct.Id;
                        updateADGroups.add(cont);                        
                    }
                    
                }
            }
            
        }
        update updateADGroups;
        */
    }
    
    //This method takes all of the events in Trigger.new and maps the record Ids based on change type
    //***this can't be in the Virtual handler as events are typed based on which object it is
    //-----it may be required required to pull in the object based on new critera where the field in question did not actually change
    //--------like the field in question didn't change, but the record type changed which now requires us to look at that field
    public override Map<String, List<Id>> getChangeEventIds () {
        Map<String, List<Id>> recordIds = new Map<String, List<Id>>();
        String changeType = '';
        Id recordId;
        List<Id> recordArr = new List<Id>();
    	//Set<String> caseIds = new Set<String>();
        
        for(AD_Group__ChangeEvent event : (List<AD_Group__ChangeEvent>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            
            if (recordIds.isEmpty() || recordIds.get(header.changetype) == null ) {
                // Get all Record Ids for this change and add to the set
                //List<String> recordIds = change.ChangeEventHeader.getRecordIds();
                //caseIds.addAll(recordIds);
                recordArr = new List<Id>();
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                recordIds.put(header.changetype,recordArr); 
            } else {
                recordArr = recordIds.get(header.changetype);
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                recordIds.put(header.changetype,recordArr); 
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
        return recordIds;
    }
}