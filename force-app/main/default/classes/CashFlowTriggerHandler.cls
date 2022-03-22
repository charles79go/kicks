/*
    Handles Create, Edit and Delete actions on Cash_Flow__c object 
    to update the Working_Capital__c in the User object.

    Handles multiple records edited.

    No anticipated multiple deleted records or multiple created records in one transaction from User.
    
    No need to handle Undelete action.  Once System_Delete__c equals true, 
    record can no longer affect the working capital. 
*/

public with sharing class CashFlowTriggerHandler {

    final static String CAPTIAL_RECORD_TYPE = Schema.SObjectType.Cash_Flow__c
                                                .getRecordTypeInfosByName()
                                                ?.get('Capital')
                                                ?.getRecordTypeId();

    final static String EXPENSE_RECORD_TYPE = Schema.SObjectType.Cash_Flow__c
                                                .getRecordTypeInfosByName()
                                                ?.get('Expense')
                                                ?.getRecordTypeId();

    public static void updateWorkingCapitalOnCreate(List<Cash_Flow__c> newCashFlowObjs){

        User recOwnerUserObj;

        for(Cash_Flow__c cf : newCashFlowObjs) {

            recOwnerUserObj = [SELECT Working_Capital__c, Name FROM User WHERE Id = :cf.OwnerId];

            if(cf.RecordTypeId == CAPTIAL_RECORD_TYPE) {
                recOwnerUserObj.Working_Capital__c = recOwnerUserObj.Working_Capital__c == null 
                    ? cf.Amount__c 
                    : recOwnerUserObj.Working_Capital__c + cf.Amount__c;  
            } 

            if(cf.RecordTypeId == EXPENSE_RECORD_TYPE) {
                recOwnerUserObj.Working_Capital__c = recOwnerUserObj.Working_Capital__c == null 
                    ? cf.Amount__c 
                    : recOwnerUserObj.Working_Capital__c - cf.Amount__c;  
            }

            KicksUtility.addErrorIfWorkingCapitalIsLessThanZero(cf, recOwnerUserObj);
        }
        update recOwnerUserObj;
    }

    public static void updateWorkingCapitalOnDelete(List<Cash_Flow__c> oldCashFlowObjs) {

        User recOwnerUserObj;

        for (Cash_Flow__c cf : oldCashFlowObjs) {

            //! don't update the working capital if System_Delete checkbox is checked.
            //! this would be checked from the scheduled clean up function.
            if(cf.System_Delete__c) { 
                continue;
            }

            recOwnerUserObj = [SELECT Working_Capital__c, Name FROM User WHERE Id = :cf.OwnerId];

            if(cf.RecordTypeId == CAPTIAL_RECORD_TYPE) {  
                // reverse the action. need to subtract from working capital.
                recOwnerUserObj.Working_Capital__c -= cf.Amount__c;  
            } 
            if(cf.RecordTypeId == EXPENSE_RECORD_TYPE) {  
                // reverse the action. need to add  from working capital.
                recOwnerUserObj.Working_Capital__c += cf.Amount__c; 
            }

            KicksUtility.addErrorIfWorkingCapitalIsLessThanZero(cf, recOwnerUserObj);
        }
        update recOwnerUserObj;
    }

    public static void updateWorkingCapitalOnEdit(Map<Id, Cash_Flow__c> oldCfs, Map<Id, Cash_Flow__c> newCfs) {

        // use map of users to handle multiple updated records from list inline edit. 
        Map<Id, User> userMap = new Map<Id, User>();

        Set <Id> idSet = oldCfs.keySet();

        for (Id cfId : idSet) {

            Cash_Flow__c oldCfObj = oldCfs.get(cfId);
            Cash_Flow__c newCfObj = newCfs.get(cfId);

            //! don't update the working capital if System_Delete checkbox is checked.
            //! this would be checked from the scheduled clean up function.
            if(newCfObj.System_Delete__c) { 
                continue;
            }

            if(!userMap.containsKey(oldCfObj.OwnerId)) {
                userMap.put(oldCfObj.OwnerId, [ SELECT Working_Capital__c, Name 
                                                FROM User 
                                                WHERE Id = :oldCfObj.OwnerId]);
            }
            if(!userMap.containsKey(newCfObj.OwnerId)) {
                userMap.put(newCfObj.OwnerId, [ SELECT Working_Capital__c, Name 
                                                FROM User 
                                                WHERE Id = :newCfObj.OwnerId]);
            }

            // There is NO change in Record Ownership
            if(oldCfObj.OwnerId == newCfObj.OwnerId) {

                User recOwnerUserObj = userMap.get(newCfObj.OwnerId);

                // No change in Record type. Just get difference in Amount__c.
                if(oldCfObj.RecordTypeId == newCfObj.RecordTypeId) {

                    Decimal diff = newCfObj.Amount__c - oldCfObj.Amount__c;
                    recOwnerUserObj.Working_Capital__c = newCfObj.RecordTypeId == CAPTIAL_RECORD_TYPE
                        ? recOwnerUserObj.Working_Capital__c + diff
                        : recOwnerUserObj.Working_Capital__c - diff;

                // There is a CHANGE in RecordType
                } else {

                    // From Expense to Capital
                    if(oldCfObj.RecordTypeId == EXPENSE_RECORD_TYPE) {
                        // add the old Expense Amount to working capital.
                        // add the new Capital Amount to working capital.
                        recOwnerUserObj.Working_Capital__c += oldCfObj.Amount__c;
                        recOwnerUserObj.Working_Capital__c += newCfObj.Amount__c;

                    // From Capital to Expense
                    } else {
                        // subtract the Capital amount from working capital.
                        // subtract the new Expense Amount from working capital.
                        recOwnerUserObj.Working_Capital__c -= oldCfObj.Amount__c;
                        recOwnerUserObj.Working_Capital__c -= newCfObj.Amount__c;
                    }
                }

                KicksUtility.addErrorIfWorkingCapitalIsLessThanZero(newCfObj, recOwnerUserObj);

            // There is CHANGE in Record Ownership
            } else {

                User oldOwnerUserObj = userMap.get(oldCfObj.OwnerId);
                User newOwnerUserObj = userMap.get(newCfObj.OwnerId);

                // There is NO change in RecordType
                if(oldCfObj.RecordTypeId == newCfObj.RecordTypeId) {

                    if(newCfObj.RecordTypeId == CAPTIAL_RECORD_TYPE) {
                        // subtract the previous Capital amount from previous owners's working capital
                        // add the new Capital to the new Owner's working capital
                        oldOwnerUserObj.Working_Capital__c -= oldCfObj.Amount__c;
                        newOwnerUserObj.Working_Capital__c += newCfObj.Amount__c;
                    }
                    
                    if(newCfObj.RecordTypeId == EXPENSE_RECORD_TYPE) {
                        // add the previous Expense amount to previous owners's working capital
                        // subtract new Expense amount from new Owner's working capital
                        oldOwnerUserObj.Working_Capital__c += oldCfObj.Amount__c;
                        newOwnerUserObj.Working_Capital__c -= newCfObj.Amount__c;
                    }
                
                // There is CHANGE in RecordType
                } else {

                    // From Expense to Capital
                    if(oldCfObj.RecordTypeId == EXPENSE_RECORD_TYPE) {
                        // add the previous Expense amount to previous owners's working capital
                        // add the new Capital to the new Owner's working capital
                        oldOwnerUserObj.Working_Capital__c += oldCfObj.Amount__c;
                        newOwnerUserObj.Working_Capital__c += newCfObj.Amount__c;

                    // From Capital to Expense
                    } else {
                        // subtract the previous Capital amount from previous owners's working capital
                        // subtract new Expense amount from new Owner's working capital
                        oldOwnerUserObj.Working_Capital__c -= oldCfObj.Amount__c;
                        newOwnerUserObj.Working_Capital__c -= newCfObj.Amount__c;
                    }
                }
                KicksUtility.addErrorIfWorkingCapitalIsLessThanZero(newCfObj, newOwnerUserObj);
                KicksUtility.addErrorIfWorkingCapitalIsLessThanZero(oldCfObj, oldOwnerUserObj);
            }
        }

        List<User> listOfUsers = userMap.values();
        update listOfUsers;
    } 
}
