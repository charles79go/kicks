public with sharing class CashFlowTriggerHandler {

    final static String CAPTIAL_RECORD_TYPE = '012P00000032nUTIAY';
    final static String EXPENSE_RECORD_TYPE = '012P00000032nUYIAY';

    final static String USER_ID = UserInfo.getUserId();  // built in function to get current logged in user id.

    public static void updateWorkingCapitalOnInsert(List<Cash_Flow__c> newCashFlowObjs){

        User currentUserObj = [SELECT Working_Capital__c FROM User WHERE Id = :USER_ID];

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

    public static void updateWorkingCapitalOnDelete(List<Cash_Flow__c> oldCashFlowObjs) {

        User currentUserObj = [SELECT Working_Capital__c FROM User WHERE Id = :USER_ID];

        for (Cash_Flow__c cf : oldCashFlowObjs) {
            if(cf.System_Delete__c) { // don't update the working capital if SystemDelete checkbox is checked.
                continue;
            }
            if(cf.RecordTypeId == CAPTIAL_RECORD_TYPE) {  
                // reverse the action. need to subtract from working capital.
                currentUserObj.Working_Capital__c -= cf.Amount__c;  
            } 
            if(cf.RecordTypeId == EXPENSE_RECORD_TYPE) {  
                // reverse the action. need to add  from working capital.
                currentUserObj.Working_Capital__c += cf.Amount__c; 
            }
        }
        update currentUserObj;
    }
}
