trigger CashFlowTrigger on Cash_Flow__c (before insert, before update, before delete) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            CashFlowTriggerHandler.updateWorkingCapitalOnCreate(Trigger.new);
        }

        when BEFORE_DELETE {
            CashFlowTriggerHandler.updateWorkingCapitalOnDelete(Trigger.old);
        }
        when BEFORE_UPDATE {
            CashFlowTriggerHandler.updateWorkingCapitalOnEdit(Trigger.oldMap, Trigger.newMap);
        }
    }
}