/*
    Handles Create, Edit and Delete actions on Cash_Flow__c object 
    to update the Working_Capital__c in the User object.
    
    No need to handle Undelete action.  Once System_Delete__c equals true, 
    record can no longer affect the working capital. 
*/

public with sharing class CashFlowTriggerHandler {

    final static String CAPTIAL_RECORD_TYPE = '012P00000032nUTIAY';
    final static String EXPENSE_RECORD_TYPE = '012P00000032nUYIAY';

    // built in function to get current logged in user id.
    final static String USER_ID = UserInfo.getUserId();  

    public static void updateWorkingCapitalOnCreate(List<Cash_Flow__c> newCashFlowObjs){

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

            //! don't update the working capital if System_Delete checkbox is checked.
            //! this would be checked from the scheduled clean up function.
            if(cf.System_Delete__c) { 
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

    public static void updateWorkingCapitalOnEdit(Map<Id, Cash_Flow__c> oldCfs, Map<Id, Cash_Flow__c> newCfs) {
        
        User currentUserObj = [SELECT Working_Capital__c FROM User WHERE Id = :USER_ID];

        Set <Id> idSet = oldCfs.keySet();

        for (Id cfId : idSet) {

            Cash_Flow__c oldCfObj = oldCfs.get(cfId);
            Cash_Flow__c newCfObj = newCfs.get(cfId);

            //! don't update the working capital if System_Delete checkbox is checked.
            //! this would be checked from the scheduled clean up function.
            if(newCfObj.System_Delete__c) { 
                continue;
            }

            // No change in Record type. Just get difference in Amount__c.
            if(oldCfObj.RecordTypeId == newCfObj.RecordTypeId) {
                
                Decimal diff = newCfObj.Amount__c - oldCfObj.Amount__c;
                currentUserObj.Working_Capital__c = newCfObj.RecordTypeId == CAPTIAL_RECORD_TYPE
                    ? currentUserObj.Working_Capital__c + diff
                    : currentUserObj.Working_Capital__c - diff;

            // There is a change in RecordType
            } else {
                // From Expense to Capital
                if(oldCfObj.RecordTypeId == EXPENSE_RECORD_TYPE) {
                    // add the old Expense Amount to working capital. Then also add
                    // the new Capital Amount to working capital.
                    currentUserObj.Working_Capital__c += oldCfObj.Amount__c;
                    currentUserObj.Working_Capital__c += newCfObj.Amount__c;

                // From Capital to Expense
                } else {
                    // subtract the Capital amount from working capital. Then also 
                    // subtract the new Expense Amount from working capital.
                    currentUserObj.Working_Capital__c -= oldCfObj.Amount__c;
                    currentUserObj.Working_Capital__c -= newCfObj.Amount__c;
                }
            }
        }
        update currentUserObj;
    } 
}
