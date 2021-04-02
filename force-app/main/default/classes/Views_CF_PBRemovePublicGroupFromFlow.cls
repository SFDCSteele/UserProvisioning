public class Views_CF_PBRemovePublicGroupFromFlow {
    

 @InvocableMethod(label='Remove User/Group from a Public Group')
  public static void RemovePublicGroup(list<RemovePublicGroupRequest> requests) {
    
        list<string> output = new list<string>();
        for (RemovePublicGroupRequest request:dedupe(requests)){
             system.debug('======================='+request);
          //future methods can only accept primitives, so we serialize to a list of string
          output.add(JSON.serialize(request));
        }
    
        RemovePermsLater(output);
  }

  //what Process Builder/Flow Builder can reference for the input variables
  public class RemovePublicGroupRequest {
      
        @InvocableVariable(required=true label='Public Group Id')
        public Id PublicGroupId;
    
        @InvocableVariable(required=true label='User/Group Id')
        public Id UserId;
        
        
        @InvocableVariable(required=true label='Record Id')
        public Id RecordID;
  }

  public static list<RemovePublicGroupRequest> dedupe(list<RemovePublicGroupRequest> input){
            set<RemovePublicGroupRequest> temp = new set<RemovePublicGroupRequest>(input);
            return new list<RemovePublicGroupRequest>(temp);
  }

  //has to be handled as an @future transaction because the mixed DML issue!
  @future
  public static void RemovePermsLater (list<string> requests){
        system.debug('=====================requests'+requests); 
        list<GroupMember> PSAs = new list<GroupMember>();

        for (string request:requests){
           
              RemovePublicGroupRequest APSR = (RemovePublicGroupRequest)JSON.deserialize(request, RemovePublicGroupRequest.class);
              GroupMember PSA = new GroupMember();
              PSA.ID =APSR.RecordID;
              PSAs.add(PSA);  
              system.debug('=====================Delete Items'+PSAs);
        }
    
        system.debug('=====================Delete Items Outside of the loop'+PSAs);

       try{ 
           
             delete PSAs ;
         
       }Catch(exception e){}
    
  }

}