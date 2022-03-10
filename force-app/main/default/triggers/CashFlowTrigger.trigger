trigger CashFlowTrigger on Cash_Flow__c (before insert, after insert, before update, after update, before delete, after delete) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            CashFlowTriggerHandler.updateWorkingCapitalOnInsert(Trigger.new);
        }

        when BEFORE_DELETE {
            CashFlowTriggerHandler.updateWorkingCapitalOnDelete(Trigger.old);
        }
    }
}