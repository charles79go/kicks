public with sharing class ShoeTriggerHandler {

        final static String USER_ID = UserInfo.getUserId();
        final static User currentUserObj = [
            SELECT Working_Capital__c 
            FROM User 
            WHERE Id = :USER_ID ];

        public static void updateWorkingCapitalOnCreate(List<Shoe__c> newShoesList) {
            for(Shoe__c shu : newShoesList) {
                currentUserObj.Working_Capital__c += shu.Profit__c;
            }
            update currentUserObj;
        }

        public static void updateWorkingCapitalOnDelete(List<Shoe__c> oldShoesList) {
            for(Shoe__c shu : oldShoesList) {
                currentUserObj.Working_Capital__c -= shu.Profit__c;
            }
            update currentUserObj;
        }

        public static void updateWorkingCapitalOnEdit(Map<Id, Shoe__c> oldShoesMap, 
        Map<Id, Shoe__c> newShoesMap ) {

            Set<Id> shoeIds = oldShoesMap.keySet();

            for(Id shoeId : shoeIds) {
                Shoe__c oldShoeObj = oldShoesMap.get(shoeId);
                Shoe__c newShoeObj = newShoesMap.get(shoeId);

                Decimal diff = newShoeObj.Profit__c - oldShoeObj.Profit__c;
                currentUserObj.Working_Capital__c += diff;
            }
            update currentUserObj;
        }
}
