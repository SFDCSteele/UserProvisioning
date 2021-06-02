public class AUPDestinationUserService {
    
    private static String debugMethod  = '';
    private static String debugScction = '';
    private static boolean debugOn     = true;//false;
    
    public static void execute (List<AUP_Destination_User_Event__e> incomingMessages ) {
        String debugSection = '000';
        String debugMethod  = 'execute';
        
        printDebug (debugMethod,debugSection,'incoming messages: '+incomingMessages);
        
        Map<String,Contact> createdContacts = new Map<String,Contact>();
        
        //createdContacts = createContacts(incomingMessages);
        createUsers ( incomingMessages,createdContacts );
                
    }
    
    public static void createUsers(List<AUP_Destination_User_Event__e> incomingMessages, Map<String,Contact> createdContactMap) {
        
        String debugSection = '600';
        String debugMethod  = 'createUsers';
        List<User> newUsers = new List<User>();
        User newUser = new User();
        //List<AUP_Destination_User_Event__e> userEvents = new List<AUP_Destination_User_Event__e>();
        //AUP_Destination_User_Event__e userEvent = new AUP_Destination_User_Event__e();
        List<String> secIdArr = new List<String>();

        Id hubProfileId = null;// = new Id();
        Id hubRoleId    = null;//new List<String>();
        String hubLicenseId = ''; 
        //String destProfile  = '';
        //String destRole     = '';
        //String destLicense  = ''; 
 
        Boolean bIsActive = true;
        String sLanguagelocalekey='en_US';
        String sTimezonesidkey='America/New_York';
        String sLocalesidkey='en_US';
        String sEmailencodingkey='UTF-8';

        
        Contact cont = new Contact();
        Map<Id,Contact> contactMap      = new Map<Id,Contact>();
        Map<String,AUP_Destination_User_Event__e>  messageMap = new Map<String,AUP_Destination_User_Event__e>();
        Map<String,Id>  existingUserMap = new Map<String,Id>();
        Map<String,Id>  destOrgProfile  = new Map<String,Id>();
        Map<String,Id>  destOrgRole     = new Map<String,Id>();

        for ( AUP_Destination_User_Event__e msg : incomingMessages ) {
            if ( msg.AD_SEC_ID__c != null ) {
                secIdArr.add (msg.AD_SEC_ID__c);
            }
            if (messageMap.isEmpty() || messageMap.get(msg.AD_SEC_ID__c) == null ) {
                messageMap.put(msg.AD_SEC_ID__c,msg);
            }
        }
        printDebug (debugMethod,debugSection,'-10:SECIDs: '+secIdArr);
        
        existingUserMap = getExistingUsers ( secIdArr );
        printDebug (debugMethod,debugSection,'-12:existingUserMap: '+existingUserMap);
        destOrgProfile  = getProfileIds(incomingMessages);
        printDebug (debugMethod,debugSection,'-14:destOrgProfile: '+destOrgProfile);
        destOrgRole     = getRoleIds(incomingMessages);
        printDebug (debugMethod,debugSection,'-16:destOrgRole: '+destOrgRole);
        
        printDebug (debugMethod,debugSection,'-20:existingUserMap: '+existingUserMap);
        
        for ( AUP_Destination_User_Event__e msg : incomingMessages ) {

	        printDebug (debugMethod,debugSection,'-30:current event record: '+msg);
            
            if (existingUserMap.isEmpty() || existingUserMap.get(msg.AD_SEC_ID__c) == null ) {
                newUser = new User(username=msg.Username__c ,
                                   firstname=msg.FirstName__c,
                                   lastname=msg.LastName__c,
                                   email=msg.Email_Address__c,
                                   SECID__c=msg.AD_SEC_ID__c,
                                   federationidentifier=msg.Federation_Id__c,
                                   alias=msg.FirstName__c.substring(0, 2)+msg.LastName__c.substring(0,3),
                                   profileid=destOrgProfile.get(msg.Profile_Name__c),
                                   isactive=bIsActive,
                                   languagelocalekey=sLanguagelocalekey,timezonesidkey=sTimezonesidkey,localesidkey=sLocalesidkey,emailencodingkey=sEmailencodingkey);
                newUsers.add(newUser);
                printDebug (debugMethod,debugSection,'-40:Users to be created: '+newUsers);
                //                                   ContactId=createdContactMap.get(msg.AD_SEC_ID__c).Id,

            } 
        }
        
        /*List<User>     usersToAdd    = new List<User>();
        
        printDebug (debugMethod,debugSection,'-92:here are the new users: '+newUsers+'\nhere are the existing users: '+existingUsers);
        for (User usr : newUsers) {
	        printDebug (debugMethod,debugSection,'-94:looping through new users: '+usr+' checking against: '+existingUsers);
            if (existingUsers.isEmpty() || existingUsers.get(usr.SECID__c) == null ) {
                usersToAdd.add(usr);
            } else {
		        printDebug (debugMethod,debugSection,'-96:found new user: '+usr+' in existing users: '+existingUsers+'---SKIPPED!!!');
            }
        }
        printDebug (debugMethod,debugSection,'-98:ADDING new users: '+usersToAdd);
		*/
        
        try {
            insert newUsers;
        } catch (Exception e) {
            System.debug(debugMethod+':'+debugSection+'--Exception while try to insert users: '+newUsers+' => '+e.getStackTraceString());
        }
        
        //Lets get all the users we added as well as the users that already existed
        List<User> listOfUsers = [Select SECID__c,Id from User where SECID__c =: secIdArr];
        for ( User usr : listOfUsers ) {
        
            //1. Read the user
            //2. Find the 'hub' permission set groups using the SECID
            //3. Find the 'hub' permission sets using the SECID
            //4. Find the 'hub' groups using the SECID 
            //5. Find the 'hub' queues using the SECID 
            //
           
            //Add permission Permission Set Groups
            addPermissionSetGroups(usr.Id,messageMap.get(usr.SECID__c));
            
            //Add permission sets
            addPermissionSets(usr.Id,messageMap.get(usr.SECID__c));
            
            //Add Permission Set Licenses
            addPermissionSetLicenses(usr.Id,messageMap.get(usr.SECID__c));
                        
            //Add Groups
            addGroups(usr.Id,messageMap.get(usr.SECID__c));
                       
            //Add Queues
            addQueues(usr.Id,messageMap.get(usr.SECID__c));

        }
            
    }
    
    private static Map<String,Id> getProfileIds (List<AUP_Destination_User_Event__e> incomingMessages) {
        
        String debugSection = '710';
        String debugMethod  = 'getProfileIds';
        List<String>   passedProfileNames = new List<String>();
        Map<String,Id> returnProfileMap = new Map<String,Id>();

        for ( AUP_Destination_User_Event__e evnt : incomingMessages ) {
            passedProfileNames.add(evnt.Profile_Name__c);
        }
        printDebug (debugMethod,debugSection,'-10:Looking for profile: '+passedProfileNames);
        for ( Profile prof : [Select Id,Name From Profile Where Name =: passedProfileNames]) {
            returnProfileMap.put(prof.Name,prof.Id);
        }
        
        return returnProfileMap;
        
    }

    
    private static Map<String,Id> getRoleIds (List<AUP_Destination_User_Event__e> incomingMessages) {
        
        List<String>   passedRoleNames = new List<String>();
        Map<String,Id> returnRoleMap = new Map<String,Id>();

        for ( AUP_Destination_User_Event__e evnt : incomingMessages ) {
            passedRoleNames.add(evnt.Profile_Name__c);
        }
        for ( UserRole uRole : [SELECT Id FROM UserRole where DeveloperName =: passedRoleNames]) {
            returnRoleMap.put(uRole.DeveloperName,uRole.Id);
        }
        
        return returnRoleMap;
        
    }
    
    private static void addQueues (Id usrId,AUP_Destination_User_Event__e msgEvent ) {
        
        String debugSection = '690';
        String debugMethod  = 'addQueues';
        printDebug (debugMethod,debugSection,'-00:inside:groups for user('+usrId+'): '+msgEvent);
        List<String> existingQueues = msgEvent.Queues__c.split('\\|');
        printDebug (debugMethod,debugSection,'-10:queues for user('+usrId+'): '+existingQueues);
        for ( String queName : existingQueues ) {
	        printDebug (debugMethod,debugSection,'-11:looping through queues to show names: '+queName+'*');            
        }
        //Take the names and query the actual queue object to get the Ids
        List<Group> queueList = [SELECT Id, Name, DeveloperName, Type, Email FROM Group where DeveloperName =: existingQueues AND Type = 'Queue' ];
        Map<Id,Group> queueMap = new Map<Id,Group>();
        Map<String,Group> existingQueueMap = new Map<String,Group>();
        printDebug (debugMethod,debugSection,'-12:looking for groups based on the api names: '+queueList);
        for (Group queue: queueList) {
            queueMap.put(queue.Id,queue);                               
            existingQueueMap.put(queue.DeveloperName,queue);
		}
        printDebug (debugMethod,debugSection,'-20:groups to be added: '+queueMap);
        //there were groups part of the permission mapping that don't actually exist---lets add them
        List<Group> newQueues = new List<Group>();
        printDebug (debugMethod,debugSection,'-20.03:do we need to add groups-existing groups: '+queueList.size()+' permission groups: '+existingQueues.size());
        if (queueList.size() < existingQueues.size() ) {
            for ( String queue : existingQueues ) {
	            if (existingQueueMap.isEmpty() || existingQueueMap.get(queue) == null ) {
                    newQueues.add(new Group(Name=queue.replace('_',' '), DeveloperName=queue, Type='Queue'));
                }
            }
            try {
	            insert newQueues;
            } catch (Exception e) {
                System.debug(debugMethod+':'+debugSection+'--Exception while try to insert Queues: '+newQueues+' => '+e.getStackTraceString());
            }
            for ( Group newQueue : newQueues ) {
                queueMap.put(newQueue.Id,newQueue);
            }
        }        
        printDebug (debugMethod,debugSection,'-20.07:NEW Queues to be added: '+newQueues);
        
        //now, loop through the existing assignments for this user and save off the ones that don't already exist
        List<GroupMember> newAssignments = new List<GroupMember>();
        Map<Id,GroupMember> existingAssignmentMap = new Map<Id,GroupMember>();
        for ( GroupMember queueM : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where UserOrGroupId =: usrId]) {
            existingAssignmentMap.put(queueM.GroupId,queueM);
        }
        printDebug (debugMethod,debugSection,'-22:existing assignments: '+existingAssignmentMap);        
		//I need to loop through my assignments and if I already have an assignment one of the permission sets I'm concerned about, I need to skip it
		//If I don't have an assignment for one of my permission sets, I need to add it to the new assignments        
        for (Group que: queueList) {
           if ((existingAssignmentMap.isEmpty() || existingAssignmentMap.get(que.Id) == null)  && que.Id != null ) {
                  newAssignments.add(new GroupMember(GroupId = que.Id,UserOrGroupId = usrId)); 
           }
		}
        //There weren't any existing assignments, so we'll add all the new ones
        if ( newAssignments.size() <= 0 ) {
            for (Group queue2: queueList) {
		        printDebug (debugMethod,debugSection,'-24:looping through Queues: '+queue2);        
	            newAssignments.add(new GroupMember(GroupId = queue2.Id,UserOrGroupId = usrId)); 
            }
        }
        printDebug (debugMethod,debugSection,'-30:Queue assignments to be added: '+newAssignments);
        
       //now we know the ones that need to be added, lets load up the object and insert them
        try {
            insert newAssignments;
        } catch (Exception e) {
            System.debug(debugMethod+':'+debugSection+'--Exception while try to insert assignments: '+newAssignments+' => '+e.getStackTraceString());
        }
    }
    
    private static void addGroups (Id usrId,AUP_Destination_User_Event__e msgEvent ) {
        
        String debugSection = '680';
        String debugMethod  = 'addGroups';
        printDebug (debugMethod,debugSection,'-00:inside:groups for user('+usrId+'): '+msgEvent);
        List<String> existingGrp = msgEvent.Groups__c.split('\\|');
        printDebug (debugMethod,debugSection,'-10:permission sets for user('+usrId+'): '+existingGrp);
        //Take the names and query the actual group object to get the Ids
        List<Group> grpList = [SELECT Id, Name, DeveloperName, Type, Email FROM Group where DeveloperName =: existingGrp AND Type = 'Regular' ];
        Map<Id,Group> grpMap = new Map<Id,Group>();
        Map<String,Group> existingGrpMap = new Map<String,Group>();
        printDebug (debugMethod,debugSection,'-12:looking for groups based on the api names: '+grpList);
        for (Group grp: grpList) {
            grpMap.put(grp.Id,grp);                               
            existingGrpMap.put(grp.DeveloperName,grp);
		}
        printDebug (debugMethod,debugSection,'-20:groups to be added: '+grpMap);
        //there were groups part of the permission mapping that don't actually exist---lets add them
        List<Group> newGroups = new List<Group>();
        printDebug (debugMethod,debugSection,'-20.03:do we need to add groups-existing groups: '+grpList.size()+' permission groups: '+existingGrp.size());
        if (grpList.size() < existingGrp.size() ) {
            for ( String grp : existingGrp ) {
	            if (existingGrpMap.isEmpty() || existingGrpMap.get(grp) == null ) {
                    newGroups.add(new Group(Name=grp.replace('_',' '), DeveloperName=grp, Type='Regular'));
                }
            }
            try {
                insert newGroups;
            } catch (Exception e) {
                System.debug(debugMethod+':'+debugSection+'--Exception while try to insert groups: '+newGroups+' => '+e.getStackTraceString());
            }
            for ( Group newGrp : newGroups ) {
                grpMap.put(newGrp.Id,newGrp);
            }
        }        
        printDebug (debugMethod,debugSection,'-20.07:NEW groups to be added: '+newGroups);
        
        //now, loop through the existing assignments for this user and save off the ones that don't already exist
        List<GroupMember> newAssignments = new List<GroupMember>();
        Map<Id,GroupMember> existingAssignmentMap = new Map<Id,GroupMember>();
        for ( GroupMember grpM : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where UserOrGroupId =: usrId]) {
            existingAssignmentMap.put(grpM.GroupId,grpM);
        }
        printDebug (debugMethod,debugSection,'-22:existing assignments: '+existingAssignmentMap);        
		//I need to loop through my assignments and if I already have an assignment one of the permission sets I'm concerned about, I need to skip it
		//If I don't have an assignment for one of my permission sets, I need to add it to the new assignments        
        for (Group grp: grpList) {
           if ((existingAssignmentMap.isEmpty() || existingAssignmentMap.get(grp.Id) == null) && grp.Id != null ) {
                  newAssignments.add(new GroupMember(GroupId = grp.Id,UserOrGroupId = usrId)); 
           }
		}
        //There weren't any existing assignments, so we'll add all the new ones
        if ( newAssignments.size() <= 0 ) {
            for (Group grp2: grpList) {
		        printDebug (debugMethod,debugSection,'-24:looping through PSLs: '+grp2);        
	            newAssignments.add(new GroupMember(GroupId = grp2.Id,UserOrGroupId = usrId)); 
            }
        }
        printDebug (debugMethod,debugSection,'-30:permission set group assignments to be added: '+newAssignments);
        
       //now we know the ones that need to be added, lets load up the object and insert them
        try {
            insert newAssignments;
        } catch (Exception e) {
            System.debug(debugMethod+':'+debugSection+'--Exception while try to insert assignments: '+newAssignments+' => '+e.getStackTraceString());
        }
    }
    
    private static void addPermissionSetLicenses (Id usrId,AUP_Destination_User_Event__e msgEvent ) {
        
        String debugSection = '670';
        String debugMethod  = 'addPermissionSetLiceenses';
        printDebug (debugMethod,debugSection,'-00:inside:permission set groups for user('+usrId+'): '+msgEvent);
        List<String> existingPsl = msgEvent.Permission_Set_Licenses__c.split('\\|');
        printDebug (debugMethod,debugSection,'-10:permission sets for user('+usrId+'): '+existingPsl);
        //Take the names and query the actual permission set group object to get the Ids
        List<PermissionSetLicense> pslList = [SELECT Id, DeveloperName, Language, MasterLabel, TotalLicenses, Status, ExpirationDate, UsedLicenses FROM PermissionSetLicense where DeveloperName =: existingPsl];
        Map<Id,PermissionSetLicense> pslMap = new Map<Id,PermissionSetLicense>();
        printDebug (debugMethod,debugSection,'-12:looking for permission set licenses based on the api names: '+pslList);
        //now, loop through the existing assignments for this user and save off the ones that don't already exist
        List<PermissionSetLicenseAssign> newAssignments = new List<PermissionSetLicenseAssign>();
        Map<Id,PermissionSetLicenseAssign> existingAssignmentMap = new Map<Id,PermissionSetLicenseAssign>();
        for ( PermissionSetLicenseAssign psla :  [SELECT Id, PermissionSetLicenseId, AssigneeId FROM PermissionSetLicenseAssign where AssigneeId =: usrId]) {
            existingAssignmentMap.put(psla.PermissionSetLicenseId,psla);
        }
        printDebug (debugMethod,debugSection,'-22:existing assignments: '+existingAssignmentMap);        
		//I need to loop through my assignments and if I already have an assignment one of the permission sets I'm concerned about, I need to skip it
		//If I don't have an assignment for one of my permission sets, I need to add it to the new assignments        
        for (PermissionSetLicense psl: pslList) {
           if ((existingAssignmentMap.isEmpty() || existingAssignmentMap.get(psl.Id) == null) && psl.Id != null ) {
                  newAssignments.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = psl.Id,AssigneeId = usrId)); 
           }
		}
        //There weren't any existing assignments, so we'll add all the new ones
        if ( newAssignments.size() <= 0 ) {
            for (PermissionSetLicense psl2: pslList) {
		        printDebug (debugMethod,debugSection,'-24:looping through PSLs: '+psl2);        
	            newAssignments.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = psl2.Id,AssigneeId = usrId)); 
            }
        }
        printDebug (debugMethod,debugSection,'-30:permission set license assignments to be added: '+newAssignments);
        
       //now we know the ones that need to be added, lets load up the object and insert them
        try {
            insert newAssignments;
        } catch (Exception e) {
            System.debug(debugMethod+':'+debugSection+'--Exception while try to insert assignments: '+newAssignments+' => '+e.getStackTraceString());
        }
    }
    
    private static void addPermissionSets (Id usrId,AUP_Destination_User_Event__e msgEvent ) {
        
        String debugSection = '660';
        String debugMethod  = 'addPermissionSets';
        printDebug (debugMethod,debugSection,'-00:inside:permission set groups for user('+usrId+'): '+msgEvent);
        List<String> existingPs = msgEvent.Permission_Sets__c.split('\\|');
        printDebug (debugMethod,debugSection,'-10:permission sets for user('+usrId+'): '+existingPs);
        //Take the names and query the actual permission set group object to get the Ids
        List<PermissionSet> psList = [SELECT Id, Name, Label, LicenseId, ProfileId, IsCustom, Description, Type, PermissionSetGroupId, NamespacePrefix, IsOwnedByProfile 
                                       FROM PermissionSet where Name =: existingPs];
        printDebug (debugMethod,debugSection,'-12:extracted permission sets based on the api names: '+psList);
        //now, loop through the existing assignments for this user and save off the ones that don't already exist
        List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
        Map<Id,PermissionSetAssignment> existingAssignmentMap = new Map<Id,PermissionSetAssignment>();
        for ( PermissionSetAssignment psa :  [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment where AssigneeId =: usrId]) {
            //if ((existingAssignmentMap.isEmpty() || existingAssignmentMap.get(psa.PermissionSetId) == null) ) {
                existingAssignmentMap.put(psa.PermissionSetId,psa);
            //}           
        }
        printDebug (debugMethod,debugSection,'-22:existing assignments: '+existingAssignmentMap);
		//I need to loop through my assignments and if I already have an assignment one of the permission sets I'm concerned about, I need to skip it
		//If I don't have an assignment for one of my permission sets, I need to add it to the new assignments        
        for (PermissionSet ps: psList) {
           if ((existingAssignmentMap.isEmpty() || existingAssignmentMap.get(ps.Id) == null) && ps.Id != null ) {
                  newAssignments.add(new PermissionSetAssignment(PermissionSetId = ps.Id,AssigneeId = usrId)); 
           }
		}
        //There weren't any existing assignments, so we'll add all the new ones
        if ( newAssignments.size() <= 0 ) {
            for (PermissionSet ps2: psList) {
		        printDebug (debugMethod,debugSection,'-24:looping through PSGs: '+ps2);        
	            newAssignments.add(new PermissionSetAssignment(PermissionSetId = ps2.Id,AssigneeId = usrId)); 
            }
        }
        printDebug (debugMethod,debugSection,'-30:permission set group assignments to be added: '+newAssignments);
        
       //now we know the ones that need to be added, lets load up the object and insert them
        try {
            insert newAssignments;
        } catch (Exception e) {
            System.debug(debugMethod+':'+debugSection+'--Exception while try to insert assignments: '+newAssignments+' => '+e.getStackTraceString());
        }
    }
    
    private static void addPermissionSetGroups (Id usrId,AUP_Destination_User_Event__e msgEvent ) {
        
        String debugSection = '650';
        String debugMethod  = 'addPermissionSetGroups';
        printDebug (debugMethod,debugSection,'-00:inside:permission set groups for user('+usrId+'): '+msgEvent);
        List<String> existingPsgs = msgEvent.Permission_Set_Groups__c.split('\\|');
        printDebug (debugMethod,debugSection,'-10:permission set groups for user('+usrId+'): '+existingPsgs);
        //Take the names and query the actual permission set group object to get the Ids
        List<PermissionSetGroup> psgList = [SELECT Id, IsDeleted, DeveloperName, Language, MasterLabel, NamespacePrefix, Description, Status 
                                       FROM PermissionSetGroup where DeveloperName =: existingPsgs];
        //now, loop through the existing assignments for this user and save off the ones that don't already exist
        List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
        Map<Id,PermissionSetAssignment> existingAssignmentMap = new Map<Id,PermissionSetAssignment>();
        for ( PermissionSetAssignment psa :  [SELECT Id, PermissionSetId, PermissionSetGroupId, AssigneeId FROM PermissionSetAssignment where AssigneeId =: usrId]) {
            existingAssignmentMap.put(psa.PermissionSetGroupId,psa);
        }
        //List<PermissionSetAssignment> existingAssignments = ;
        printDebug (debugMethod,debugSection,'-22:existing assignments: '+existingAssignmentMap);        
		//I need to loop through my assignments and if I already have an assignment one of the permission sets I'm concerned about, I need to skip it
		//If I don't have an assignment for one of my permission sets, I need to add it to the new assignments        
        for (PermissionSetGroup psg: psgList) {
           if ((existingAssignmentMap.isEmpty() || existingAssignmentMap.get(psg.Id) == null) && psg.Id != null ) {
                  newAssignments.add(new PermissionSetAssignment(PermissionSetGroupId = psg.Id,AssigneeId = usrId)); 
           }
		}
        //There weren't any existing assignments, so we'll add all the new ones
        if ( newAssignments.size() <= 0 ) {
            for (PermissionSetGroup psg2: psgList) {
		        printDebug (debugMethod,debugSection,'-24:looping through PSGs: '+psg2);        
	            newAssignments.add(new PermissionSetAssignment(PermissionSetGroupId = psg2.Id,AssigneeId = usrId)); 
            }
        }
        printDebug (debugMethod,debugSection,'-30:permission set group assignments to be added: '+newAssignments);
        
       //now we know the ones that need to be added, lets load up the object and insert them
        try {
            insert newAssignments;
        } catch (Exception e) {
            System.debug(debugMethod+':'+debugSection+'--Exception while try to insert assignments: '+newAssignments+' => '+e.getStackTraceString());
        }
    }
    /*
    private static boolean publishUserEvents (List<AUP_Destination_User_Event__e> userEvents ) {
        boolean returnStatus = false;
        String debugSection = '700';
        String debugMethod  = 'publishUserEvents';
   
        printDebug (debugMethod,debugSection,'-10:Ready to published events: '+userEvents);
        if ( userEvents.size() > 0 ) {
            // Call method to publish events
            List<Database.SaveResult> srs = EventBus.publish(userEvents);
            // Inspect publishing result
            for (Database.SaveResult sr: srs ) {
                if (sr.isSuccess()) {
                    printDebug (debugMethod,debugSection,'-20:Successfully published event: '+sr);
                    returnStatus = true;
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        printDebug (debugMethod,debugSection,'Error returned: ' +
                                     err.getStatusCode() +
                                     ' - ' +
                                     err.getMessage());
                    }
                }
            }
            printDebug (debugMethod,debugSection,'-30:FINISHING UP!');
        }

        
        return returnStatus;
    }

	private static String appendString(String location, String type, List<CF_Permission_Mapping__c> permissions) {
        String returnString = '';
        
        try {
            for ( CF_Permission_Mapping__c perm : permissions ) {
                if ( perm.Permission_Location__c.equals(location) && perm.Access_Type__c.equals(type) ) {
                        returnString += perm.Name + '|';
                }
            }        
        } catch (Exception e) {
            System.debug('Exception while tring to append: '+permissions+' to '+returnString+' => '+e.getStackTraceString());
            //rtnDTCApplicationLevel = null;
        }
        return returnString;
    }    
	*/
    
    private static Map<String,Id> getExistingUsers ( List<String> secIdArr ) {
        
        String debugSection = '600';
        String debugMethod  = 'getExistingUsers';
        Map<String,Id> existingUserMap = new Map<String,Id>();
        for ( User usr : [Select SECID__c,Id from User where SECID__c =: secIdArr]) {
            existingUserMap.put(usr.SECID__c,usr.Id);
        }
        
        printDebug (debugMethod,debugSection,'-70:existing Users: '+existingUserMap);
        
        return existingUserMap;
    }
    /*
    private static DTC_Application_Level__c getDTCApplicationLevel (Id DTCApplicationLevelId) {
        DTC_Application_Level__c rtnDTCApplicationLevel = new DTC_Application_Level__c();
        try {
            rtnDTCApplicationLevel = [select Id,Name,Is_Active__c,
                                      Hub_Org_Role__c,Hub_Org_Profile__c,Hub_Org_License__c,
                                      Destination_Org_Role__c,Destination_Org_Profile__c,Destination_Org_License__c,
                                      Application_Level_User_Creation_Flow__c,Application_Level_User_Creation_Apex__c 
                                      FROM DTC_Application_Level__c where Id =: DTCApplicationLevelId];
        }
        catch (Exception e) {
            System.debug('Exception while looking for DTC Application: '+DTCApplicationLevelId+': '+e.getStackTraceString());
            rtnDTCApplicationLevel = null;
        }
        return rtnDTCApplicationLevel;
    }
   
    private static DTC_Application__c getDTCApplication (Id DTCApplicationId) {
        DTC_Application__c rtnDTCApplication = new DTC_Application__c();
        try {
            rtnDTCApplication = [select Id,Name,Application_Description__c,Org__c,Profile_ID__c, 
                                 Overall_User_Creation_Flow__c,Overall_User_Creation_Apex__c  
                                 FROM DTC_Application__c where Id =: DTCApplicationId];
        }
        catch (Exception e) {
            System.debug('Exception while looking for DTC Application: '+DTCApplicationId+': '+e.getStackTraceString());
            rtnDTCApplication = null;
        }
        return rtnDTCApplication;
    }
    
    private static Contact getContact (Id contactId) {
        Contact rtnContact = new Contact();
        try {
            rtnContact = [select Id,FirstName,LastName,Email,Federation_Id__c,SECID__c FROM Contact where Id =: contactId];
        }
        catch (Exception e) {
            System.debug('Exception while looking for contact: '+contactId+': '+e.getStackTraceString());
            rtnContact = null;
        }
        return rtnContact;
    }
    */
    private static Map<String,Contact> createContacts (List<AUP_Destination_User_Event__e> incomingMessages) {
        
        String debugSection = '400';
        String debugMethod  = 'createContacts';
        printDebug (debugMethod,debugSection,'-10:incomingMessages: '+incomingMessages);
        
        Id     accountId;
        Contact             newContact       = new Contact();
        List<Contact>       newContacts      = new List<Contact>();
        Map<String,Contact> newContactsMap   = new Map<String,Contact>();
        Map<String,Contact> existingContacts = new Map<String,Contact>();
        Map<String,Account> exstingAccounts  = new Map<String,Account>();
        
        existingContacts = getExistingContacts(incomingMessages);
        printDebug (debugMethod,debugSection,'-20:existingContacts: '+existingContacts);
        exstingAccounts  = getExistingAccounts(incomingMessages);
        printDebug (debugMethod,debugSection,'-30:exstingAccounts: '+exstingAccounts);
        
        for ( AUP_Destination_User_Event__e msg : incomingMessages ) {
            if (!exstingAccounts.isEmpty() || exstingAccounts.get(msg.AD_SEC_ID__c) != null ) {
                accountId = exstingAccounts.get(msg.AD_SEC_ID__c).Id;
            }
            if (existingContacts.isEmpty() || existingContacts.get(msg.AD_SEC_ID__c) == null ) {
               newContact = new Contact(AccountId=accountId,
                                        Email=msg.Email_Address__c ,
                                        Federation_Id__c=msg.Federation_Id__c ,
                                        SECID__c=msg.AD_SEC_ID__c,
                                        FirstName=msg.FirstName__c,
                                        LastName=msg.LastName__c,
                                        Description='AUP Created Contact');
                newContacts.add(newContact);
            } else {
	            newContactsMap.put(msg.AD_SEC_ID__c,existingContacts.get(msg.AD_SEC_ID__c));
            }           
        }
        try {
            insert newContacts;
        } catch (Exception e) {
            System.debug(debugMethod+':'+debugSection+'--Exception while try to insert contacts: '+newContacts+' => '+e.getStackTraceString());
        }
        printDebug (debugMethod,debugSection,'-40:newContact: '+newContacts);
        
        for ( Contact cntct : newContacts ) {
            newContactsMap.put(cntct.SECID__c,cntct);
        }
        printDebug (debugMethod,debugSection,'-50:newContactsMap: '+newContactsMap);
        return newContactsMap;        
        
    }
    
    private static Map<String,Contact> getExistingContacts (List<AUP_Destination_User_Event__e> incomingMessages) {
        Map<String,Contact> existingContacts = new Map<String,Contact>();
        List<String> secIdArr = new List<String>();
        
        for ( AUP_Destination_User_Event__e msg : incomingMessages ) {
            if ( msg.AD_SEC_ID__c != null ) {
                secIdArr.add (msg.AD_SEC_ID__c);
            }
        }
        
        for ( Contact cntct : [Select Id, SECID__c from Contact where SECID__c =: secIdArr]) {
            if (existingContacts.isEmpty() || existingContacts.get(cntct.SECID__c) == null ) {
                existingContacts.put(cntct.SECID__c,cntct);
            }
        }
        return existingContacts;
    }

    private static Map<String,Account> getExistingAccounts (List<AUP_Destination_User_Event__e> incomingMessages) {
        Map<String,Account> exstingAccounts  = new Map<String,Account>();
        List<String> accountNames = new List<String>();
        
        for ( AUP_Destination_User_Event__e msg : incomingMessages ) {
            if ( msg.Account_Name__c != null ) {
                accountNames.add (msg.Account_Name__c);
            }
        }
        
        for ( Account acct : [Select Id, Name from Account where Name =: accountNames]) {
            if (exstingAccounts.isEmpty() || exstingAccounts.get(acct.Name) == null ) {
                exstingAccounts.put(acct.Name,acct);
            }
        }
        
        return exstingAccounts;
    }
    
    private static boolean contactExists (String passedSECID ) {
        String debugSection = '300';
        String debugMethod  = 'contactExists';
        boolean returnStatus = false;
        
        List<Contact> cnt = [Select Id,Name from Contact where SECID__c =: passedSECID];
        printDebug (debugMethod,debugSection,'-10:lookin for contact: passedSECID: '+passedSECID+' found: '+cnt.size());
        if (cnt.size() > 0 ) {
            returnStatus = true;
        }
        
        return returnStatus;
    }
    /*
    private static boolean applicationAccessExists (String passedSECID, Id applicationId, Id applicationLevelId ) {
        String debugSection = '310';
        String debugMethod  = 'applicationAccessExists';
        boolean returnStatus = false;
        
    	List<CF_Application_Access__c> aa = [Select Id, Name, Approval_Status__c, Application_Name__c, DTC_Application_Level__r.Name, 
                                             Inactive__c, DTC_Application__r.Name, Contact__r.SECID__c FROM CF_Application_Access__c 
                                             where Contact__r.SECID__c =: passedSECID AND Inactive__c = true AND 
                                             DTC_Application__c =: applicationId AND DTC_Application_Level__c =: applicationLevelId];
        printDebug (debugMethod,debugSection,'-20:lookin for applicationAccess: passedSECID: '+passedSECID+
                     ' application Id: '+applicationId+' application level id: '+applicationLevelId+
                     ' found: '+aa.size());
        if (aa.size() > 0 ) {
            returnStatus = true;
        }
        
        return returnStatus;
    }

    
    private static DTC_Application__c getDTCApplication (String applicationName ) {
        String debugSection = '200';
        String debugMethod  = 'getDTCApplication';
        DTC_Application__c returnApplication = new DTC_Application__c();
        
        printDebug (debugMethod,debugSection,'-10:lookin for applicationName: '+applicationName);
        try {
            returnApplication = [select Id, Name, Account__c, Application_Description__c, Org__c, Profile_ID__c from DTC_Application__c where Name =: applicationName ];
        } catch (Exception e) {
            printDebug (debugMethod,debugSection,'ADUpdateGroupService:getDTCApplication:Exception: '+e.getStackTraceString());
            returnApplication = null;
        }
        printDebug (debugMethod,debugSection,'-15:found application: '+returnApplication);
        
        return returnApplication;
        
    }
    
    private static DTC_Application_Level__c getDTCApplicationLevel (Id applicationId, String applicationLevelName ) {
        String debugSection = '210';
        String debugMethod  = 'getDTCApplicationLevel';
        DTC_Application_Level__c returnApplicationLevel = new DTC_Application_Level__c();
        
        printDebug (debugMethod,debugSection,'-10:lookin for applicationLevelName: '+applicationLevelName);
        try {
            returnApplicationLevel = [select Id, Name, DTC_Application__c, Is_Active__c from DTC_Application_Level__c 
                                      where Name =: applicationLevelName AND DTC_Application__c =: applicationId];
        } catch (Exception e) {
            printDebug (debugMethod,debugSection,'ADUpdateGroupService:getDTCApplicationLevel:Exception: '+e.getStackTraceString());
            returnApplicationLevel = null;
        }
        printDebug (debugMethod,debugSection,'-15:found application Level: '+returnApplicationLevel);
        
        return returnApplicationLevel;
        
    }
     
    private static List<CF_Permission_Mapping__c> getApplicationLevelPermissions (Id applicationId, Id applicationLevelId,String permissionLocation ) {
        String debugSection = '220';
        String debugMethod  = 'getApplicationLevelPermissions';
        List<CF_Permission_Mapping__c> returnApplicationLevelPermissions = new List<CF_Permission_Mapping__c>();
        
        printDebug (debugMethod,debugSection,'-10:lookin for applicationId: '+applicationId+
                     ' applicationLevelId: '+applicationLevelId);
        try {
            returnApplicationLevelPermissions = [select Id, Name, DTC_Application__c , DTC_Application_Level__c, Access_Type__c, Permission_Location__c, Permission_Set_API_Name__c     
                                                 from CF_Permission_Mapping__c 
                                      where DTC_Application_Level__c =: applicationLevelId AND 
                                                 DTC_Application__c =: applicationId AND 
                                                 Permission_Location__c =: permissionLocation];
        } catch (Exception e) {
            printDebug (debugMethod,debugSection,'ADUpdateGroupService:getApplicationLevelPermissions:Exception: '+e.getStackTraceString());
            returnApplicationLevelPermissions = null;
        }
        printDebug (debugMethod,debugSection,'-15:found application Level permissions: '+returnApplicationLevelPermissions);
       
        
        return returnApplicationLevelPermissions;
        
    }
    */
    private static void printDebug(String method, String section, String debugMessage) {
        if ( debugOn ) {
            System.debug('AUPDestinationUserService: '+method+': '+section+': >>>>>>>>>>>>>>>>>>>> '+debugMessage);
        }  
    }

    
}