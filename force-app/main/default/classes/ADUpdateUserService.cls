//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

public class ADUpdateUserService {

	public String SECID {get;set;} 
	public String FederationId {get;set;} 
	public String Status {get;set;} 

	public ADUpdateUserService(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'FederationId') {
						FederationId = parser.getText();
					} else if (text == 'SECID') {
						SECID = parser.getText();
					} else if (text == 'Status') {
						Status = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'ADUpdateUserService consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static ADUpdateUserService parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ADUpdateUserService(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    public static String execute (String messageRecived ) {
        ADUpdateUserService r = ADUpdateUserService.parse(messageRecived);
	    String returnMessage = 'Success';

        System.debug('ADUserReceiveEvent:SECID: '+r.SECID);
        System.debug('ADUserReceiveEvent:FederationId: '+r.FederationId);
        System.debug('ADUserReceiveEvent:Status: '+r.Status);
        
        if ( r.Status.equals('Inactive')) {
            returnMessage += inactivateUser(r.SECID);
        }
        
        return returnMessage;
        
    }

    private static String inactivateUser (String SECID) {
        
	    String returnMessage = ':';
        System.debug('ADUserReceiveEvent:looking for SECID: '+SECID);
		List<User> inActivateUsers = new List<User>();
        List<Id>   usrIds          = new List<Id>();
        Id newProfileId = [Select Id From Profile Where Name = 'Force.com - Free User' limit 1].Id;

        for (User usr : [select Id, username, SECID__C,IsActive,profileid from User where SECID__c =: SECID]) {
            usr.IsActive = false;
            usr.profileid = newProfileId;
            inActivateUsers.add(usr);
            usrIds.add(usr.Id);
            returnMessage += 'User Inactivated';
        }
        System.debug('ADUserReceiveEvent:preparing to update users: '+inActivateUsers);
        
        try {
            removePermissionSetLicenses(usrIds);
            removePermissionSets(usrIds);
            removeGroupsAndQueues(usrIds);
	        update inActivateUsers;
        } catch (Exception e) {
            System.debug('ADUserReceiveEvent:inactivateUser:Exception: '+e.getStackTraceString());
            //return e.getStackTraceString();
        }
        return returnMessage;
    }
    
    private static void removePermissionSets (List<Id> usrIds ) {
        List<PermissionSetAssignment> delAssignments = new List<PermissionSetAssignment>();
        for ( PermissionSetAssignment dassgn :  [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment where AssigneeId =: usrIds]) {
            delAssignments.add(dassgn);
        }
        try {
	        delete delAssignments;
        } catch (Exception e) {
            System.debug('ADUpdateUserService:removePermissionSets:Exception: '+e.getStackTraceString());
        }
        
    }
    
    private static void removePermissionSetLicenses (List<Id> usrIds ) {
        List<PermissionSetLicenseAssign> delAssignments = new List<PermissionSetLicenseAssign>();
        for ( PermissionSetLicenseAssign dassgn :  [SELECT Id, PermissionSetLicenseId, AssigneeId FROM PermissionSetLicenseAssign where AssigneeId =: usrIds]) {
            delAssignments.add(dassgn);
        }
        try {
	        delete delAssignments;
        } catch (Exception e) {
            System.debug('ADUpdateUserService:removePermissionSetLicenses:Exception: '+e.getStackTraceString());
        }
        
    }
   
    private static void removeGroupsAndQueues (List<Id> usrIds ) {
        List<GroupMember> delAssignments = new List<GroupMember>();
        for ( GroupMember dassgn :  [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where UserOrGroupId =: usrIds]) {
            delAssignments.add(dassgn);
        }
        try {
	        delete delAssignments;
        } catch (Exception e) {
            System.debug('ADUpdateUserService:removeGroupsAndQueues:Exception: '+e.getStackTraceString());
        }
        
    }

}