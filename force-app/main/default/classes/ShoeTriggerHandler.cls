public with sharing class ShoeTriggerHandler {

        public static void updateWorkingCapitalOnCreate(List<Shoe__c> newShoesList) {

            User currentUserObj;

            for(Shoe__c shu : newShoesList) {

                currentUserObj = [  SELECT Working_Capital__c, Name 
                                    FROM User 
                                    WHERE Id = :shu.OwnerId ];

                currentUserObj.Working_Capital__c += shu.Profit__c;

                KicksUtility.checkShoeProfit(shu, currentUserObj);
            }
            update currentUserObj;
        }

        public static void updateWorkingCapitalOnDelete(List<Shoe__c> oldShoesList) {

            User currentUserObj;

            for(Shoe__c shu : oldShoesList) {

                //! don't update the working capital if System_Delete checkbox is checked.
                //! this would be checked from the scheduled clean up function.
                if(shu.System_Delete__c) { 
                    continue;
                }

                currentUserObj = [  SELECT Working_Capital__c, Name 
                FROM User 
                WHERE Id = :shu.OwnerId ];

                currentUserObj.Working_Capital__c -= shu.Profit__c;

                KicksUtility.checkShoeProfit(shu, currentUserObj);
            }
            update currentUserObj;
        }

        public static void updateWorkingCapitalOnEdit(Map<Id, Shoe__c> oldShoesMap, 
        Map<Id, Shoe__c> newShoesMap ) {

            Map<Id, User> userMap = new Map<Id, User>();

            Set<Id> shoeIds = oldShoesMap.keySet();

            for(Id shoeId : shoeIds) {

                Shoe__c oldShoeObj = oldShoesMap.get(shoeId);
                Shoe__c newShoeObj = newShoesMap.get(shoeId);

                //! don't update the working capital if System_Delete checkbox is checked.
                //! this would be checked from the scheduled clean up function.
                if(newShoeObj.System_Delete__c) { 
                    continue;
                }

                if(!userMap.containsKey(oldShoeObj.OwnerId)) {
                    userMap.put(oldShoeObj.OwnerId, [   SELECT Working_Capital__c, Name 
                                                        FROM User 
                                                        WHERE Id = :oldShoeObj.OwnerId]);
                }
                if(!userMap.containsKey(newShoeObj.OwnerId)) {
                    userMap.put(newShoeObj.OwnerId, [   SELECT Working_Capital__c, Name 
                                                        FROM User 
                                                        WHERE Id = :newShoeObj.OwnerId]);
                }

                // If NO change in Record Owner
                if(oldShoeObj.OwnerId == newShoeObj.OwnerId ) {

                    Decimal diff = newShoeObj.Profit__c - oldShoeObj.Profit__c;
                    userMap.get(newShoeObj.OwnerId).Working_Capital__c += diff;

                // If CHANGE in Record Owner
                } else {
                    // reverse the profit from previous Owner working capital.
                    // add the profit to new Owner working capital.
                    userMap.get(oldShoeObj.OwnerId).Working_Capital__c -= oldShoeObj.Profit__c;
                    userMap.get(newShoeObj.OwnerId).Working_Capital__c += newShoeObj.Profit__c;
                }

                KicksUtility.checkShoeProfit(oldShoeObj, userMap.get(oldShoeObj.OwnerId));
                KicksUtility.checkShoeProfit(newShoeObj, userMap.get(newShoeObj.OwnerId));
            }

            List<User> userList = userMap.values();
            update userList;
        }
}
