//! ====================================================
//! Needs to convert to FLOWS

trigger ShoeTrigger on Shoe__c (before insert, before update, before delete) {

    switch on Trigger.operationType {

        when BEFORE_INSERT {
            ShoeTriggerHandler.updateWorkingCapitalOnCreate(Trigger.new);
        }
        when BEFORE_UPDATE {
            ShoeTriggerHandler.updateWorkingCapitalOnEdit(Trigger.oldMap, Trigger.newMap);
        }
        when BEFORE_DELETE {
            ShoeTriggerHandler.updateWorkingCapitalOnDelete(Trigger.old);
        }
        
    }
}