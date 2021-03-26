public without sharing class Views_CF_PBAddPublicGroupFromFlow{

  @InvocableMethod(label='Add User/Group to a Public Group')
  public static void AddPublicGroup(list<AddPublicGroupRequest> requests) {
      
      system.debug('======================Requests'+requests); // This is the GroupMember (GroupID and USErORGroupID)

    list<string> output = new list<string>();

    for (AddPublicGroupRequest request:dedupe(requests)){
          system.debug('============================Request'+request);
          //future methods can only accept primitives, so we serialize to a list of string
          output.add(JSON.serialize(request));
          system.debug('============================output'+output);
    }

    AddPermsLater(output);

  }

  //what Process Builder/Flow Builder can reference for the input variables
  public class AddPublicGroupRequest {
      
    @InvocableVariable(required=true label='Public Group Id')
    public Id PublicGroupId;

    @InvocableVariable(required=true label='User/Group Id')
    public Id UserId;
  }

  public static list<AddPublicGroupRequest> dedupe(list<AddPublicGroupRequest> input){
    set<AddPublicGroupRequest> temp = new set<AddPublicGroupRequest>(input);
    return new list<AddPublicGroupRequest>(temp);
  }

  //has to be handled as an @future transaction because the mixed DML issue!
  @future
  public static void AddPermsLater (list<string> requests){
    list<GroupMember> PSAs = new list<GroupMember>();

    for (string request:requests){
      //turn it back into the request object per Quinton Wall
      //https://developer.salesforce.com/blogs/developer-relations/2013/06/passing-objects-to-future-annotated-methods.html
      AddPublicGroupRequest APSR = (AddPublicGroupRequest)JSON.deserialize(request, AddPublicGroupRequest.class);
      
      GroupMember PSA = new GroupMember();
      PSA.UserOrGroupId = APSR.UserId;
      PSA.GroupID = APSR.PublicGroupId;
      
      PSAs.add(PSA);      
    }
 
    insert PSAs;
  }

}