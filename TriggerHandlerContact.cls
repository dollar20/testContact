public class TriggerHandlerContact {
  
    public void afterInsert( List<Contact> addData) {
        setCaseData(addData);
    }
 
    private void setCaseData(List<Contact> addData) {

        List<Case> newCases = new List<Case>();
        Id OwnerId ;
       
        Map<String,PriorityContactLevel__c> OC = PriorityContactLevel__c.getAll();

        for (Contact currContact :  addData) {

            if( currContact.AccountId != null ){
                Account selectAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :currContact.AccountId];
                OwnerId = selectAccount.OwnerId;
            }else{
                OwnerId = UserInfo.getUserId() ;
            }
                
            newCases.add(
                new Case(
                    Account = currContact.Account,
                    Status = 'Working',
                    Origin = 'New Contact',
                    ContactId = currContact.Id,
                    Priority = OC.get(currContact.Contact_Level__c).Priority__c,
                    OwnerId = OwnerId 
                 )
             );
        }            
        
        insert newCases;
    }
}