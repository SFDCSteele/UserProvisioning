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
        System.debug('101.01->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:processCreate:inside....');
        processTransactions(IdsToProcess);
    
    }
     
    public override void processUpdate(List<Id> IdsToProcess) {
        System.debug('102.01-##############ADGroupChangeEventTriggerHandler:processUpdate:inside....');
        
        processTransactions(IdsToProcess);
    }

    
    public override void processDelete(List<Id> IdsToProcess) {
        System.debug('102.01-##############ADGroupChangeEventTriggerHandler:processDelete:inside....');
        
        processTransactions(IdsToProcess);
    }
    
    private void processTransactions(List<Id> IdsToProcess) {
        System.debug('102.01-##############ADGroupChangeEventTriggerHandler:processTransactions:Ids: '+IdsToProcess);
        
        
        //List<List<String>> grpTrans = [SELECT Id, Name, RecordTypeId, Parent_AD_Group__r.AD_Group_Name__c, AD_Group_Name__c, Status__c, AD_User__r.AD_First_Name__c, 
        //                              AD_User__r.AD_Last_Name__c, AD_User__r.AD_User_Email__c, AD_User__r.AD_Federation_Id__c FROM AD_Group__c];
        //String job_state_query = 'SELECT Id, Name, RecordTypeId, Parent_AD_Group__r.AD_Group_Name__c, AD_Group_Name__c, Status__c, AD_User__r.AD_First_Name__c, '+
        //                              'AD_User__r.AD_Last_Name__c, AD_User__r.AD_User_Email__c, AD_User__r.AD_Federation_Id__c FROM AD_Group__c';
        //List<sObject> grpTrans = Database.query(job_state_query);
        List<UserGroupEvent> grpTrans = [SELECT Id, Name, RecordTypeId, Parent_AD_Group__r.AD_Group_Name__c, AD_Group_Name__c, Status__c, AD_User__r.AD_First_Name__c, 
                                      AD_User__r.AD_Last_Name__c, AD_User__r.AD_User_Email__c, AD_User__r.AD_Federation_Id__c FROM AD_Group__c];
        System.debug('102.02-$$$$$$--##############ADGroupChangeEventTriggerHandler:processTransactions:transactions: '+grpTrans);
        //for (SObject obj : grpTrans) {
	    //    System.debug('102.03-$$$$$$--##############ADGroupChangeEventTriggerHandler:processTransactions:transactions: '+obj);
        //}

        /*
        Map<Id,SObject> grp = [SELECT Id, Name, RecordTypeId, Parent_AD_Group__r.AD_Group_Name__c, AD_Group_Name__c, Status__c, AD_User__r.AD_First_Name__c, 
                                      AD_User__r.AD_Last_Name__c, AD_User__r.AD_User_Email__c, AD_User__r.AD_Federation_Id__c FROM AD_Group__c];
		*/
        /*
       for (SObject grp : [SELECT Id, Name, RecordTypeId, Parent_AD_Group__r.AD_Group_Name__c, AD_Group_Name__c, Status__c, AD_User__r.AD_First_Name__c, 
                                      AD_User__r.AD_Last_Name__c, AD_User__r.AD_User_Email__c, AD_User__r.AD_Federation_Id__c FROM AD_Group__c]) {
	        System.debug('102.02-$$$$$$--##############ADGroupChangeEventTriggerHandler:processTransactions:transactions: '+grp);
            //15:22:23:422 USER_DEBUG [58]|DEBUG|102.02-$$$$$$--##############ADGroupChangeEventTriggerHandler:processTransactions:transactions: 
            //AD_Group__c:{Id=a011F00000EN5h7QAD, 
            //Name=AG-100004, 
            //RecordTypeId=0121F000002lA1FQAU, 
            //Parent_AD_Group__c=a011F00000EN5h6QAD, 
            //AD_Group_Name__c=OHRS-VHA, 
            //Status__c=Active, 
            //AD_User__c=a001F000009BK0yQAG}
            //
            //groupEvents.add(new AD_Group_Update__e(AD_Federation_Id__c=grp.AD_Federation_Id__c,
            //                                       .AD_Federation_Id__c, 
            //                                       Status__c=user.Status__c));
        }
        */
        List<AD_Group_Update__e> groupEvents = new List<AD_Group_Update__e>();
        //AD_Group_Update__e groupEvent = new AD_Group_Update__e();
        
        /*
         * 
         * 12:19:31:492 USER_DEBUG [55]|DEBUG|102.02-##############ADGroupChangeEventTriggerHandler:processTransactions:transactions: 
         * (AD_Group__c:{Id=a011F00000EN5B1QAL, Name=AG-100003, RecordTypeId=0121F000002lA1FQAU, AD_Group_Name__c=Salesforce, Status__c=Inactive, AD_User__c=a001F000009BJ32QAG}, 
         * AD_Group__c:{Id=a011F00000EN5B2QAL, Name=AG-100004, RecordTypeId=0121F000002lA1FQAU, Parent_AD_Group__c=a011F00000EN5B1QAL, AD_Group_Name__c=OHRS-VHA, Status__c=Active, 
         * AD_User__c=a001F000009BJ32QAG}, AD_Group__c:{Id=a011F00000EN5B3QAL, Name=AG-1
         * 
         * 
        for (SObject grp : ADGroups) {
            groupEvents.add(new AD_Group_Update__e(AD_Federation_Id__c=grp.AD_Federation_Id__c,
                                                   .AD_Federation_Id__c, 
                                                   Status__c=user.Status__c));
        }
        // Create an instance of the event and store it in the newsEvent variable
        Cloud_News__e newsEvent = new Cloud_News__e(
                   Location__c='Mountain City',
                   Urgent__c=true,
                   News_Content__c='Lake Road is closed due to mudslides.');
        // Call method to publish events
        Database.SaveResult sr = EventBus.publish(newsEvent);
        // Inspect publishing result
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }
        // Call method to publish events
        List<Database.SaveResult> srs = EventBus.publish(groupEvents);
        // Inspect publishing result
        for (Database.SaveResult sr: srs ) {
            if (sr.isSuccess()) {
                System.debug('102.01-##############ADGroupChangeEventTriggerHandler:processUpdate:Successfully published event: '+sr);
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
        }
        //insert groupEvents;
        //
        */
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
                if ( changedFields.contains('Status__c') && event.get('Status__c') != 'New' ) {
			        System.debug('104.02.03->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:STATUS has changed: '+changedFields);
	                recordIds.put(header.changetype,recordArr); 
                }
            } else {
                recordArr = recordIds.get(header.changetype);
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                if ( changedFields.contains('Status__c') && event.get('Status__c') != 'New' ) {
			        System.debug('104.02.04->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:STATUS has changed: '+changedFields);
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
        System.debug('104.10->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:return recordIds: '+recordIds);
        return recordIds;
    }

    public class UserGroupEvent 
    {
		//Id, Name, RecordTypeId, Parent_AD_Group__r.AD_Group_Name__c, AD_Group_Name__c, Status__c, AD_User__r.AD_First_Name__c, 
        //                              AD_User__r.AD_Last_Name__c, AD_User__r.AD_User_Email__c, AD_User__r.AD_Federation_Id__c
        
        public Id Id {get; private set;}
        public String Name {get; private set;}
        public Id RecordTypeId {get; private set;}
        public String ParentGroupName {get; private set;}
        public String GroupName {get; private set;}
        public string Status {get; private set;}
        public String UserFirstName {get; private set;}
        public String UserLastName {get; private set;}
        public String UserEmail {get; private set;}
        public String UserFederationId {get; private set;}

        public List<UserGroupEvent> transactionsList{get;set;}
        
    }
    /*
    //Wrapper Classes    
    public class QuestionErrorWrapper
    {
        public VBA_QMS_ClaimReviewQuestionResponse__c questionResponse{get;set;}
        public List<ErrorResponseWrapper> erWrapper{get;set;}
        
        public QuestionErrorWrapper(VBA_QMS_ClaimReviewQuestionResponse__c questionResponse)
        {
            this.questionResponse = questionResponse;
        }
    }
    
    public class ErrorResponseWrapper {
        public VBA_QMS_ClaimReviewErrorResponse__c errorResponse{get;set;}
        public List<VBA_QMS_Error_Response_Diagnostic_Code__c> diagnosticCodes {get;set;}
        public List<VBA_QMS_Error_Response_Transaction__c> transactionsList{get;set;}
        public List<VBA_QMS_Error_Response_Claim_Contention__c> contentionsList{get;set;}
    }
	*/
    
}
