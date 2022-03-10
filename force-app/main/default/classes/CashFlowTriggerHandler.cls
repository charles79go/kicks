public with sharing class CashFlowTriggerHandler {

    public static void updateWorkingCapitalOnInsert(List<Cash_Flow__c> newCashFlowObjs){

        final String CAPTIAL_RECORD_TYPE = '012P00000032nUTIAY';
        final String EXPENSE_RECORD_TYPE = '012P00000032nUYIAY';

        final String USER_ID = UserInfo.getUserId();  // built in function to get current logged in user id.

        User currentUserObj = [SELECT UserName, Working_Capital__c, Email FROM User WHERE Id = :USER_ID];

        for(Cash_Flow__c cf : newCashFlowObjs) {
            if(cf.RecordTypeId == CAPTIAL_RECORD_TYPE) {
                currentUserObj.Working_Capital__c = currentUserObj.Working_Capital__c == null 
                    ? cf.Amount__c 
                    : currentUserObj.Working_Capital__c + cf.Amount__c;  
            } 
            // use another if statement instead of else so if there is additional record
            // type in the future, less code change / logic change.
            if(cf.RecordTypeId == EXPENSE_RECORD_TYPE) {
                currentUserObj.Working_Capital__c = currentUserObj.Working_Capital__c == null 
                    ? cf.Amount__c 
                    : currentUserObj.Working_Capital__c - cf.Amount__c;  
                
            }
        }

        update currentUserObj;
    }
}
