public with sharing class KicksUtility {

    public static void addErrorIfWorkingCapitalIsLessThanZero(SObject obj, User usrObj) {
        if(usrObj.Working_Capital__c < 0) {
            obj.addError('Working Capital of Record Owner (' 
                    + usrObj.Name + ': ' + usrObj.Working_Capital__c + ' dollars) cannot go less than zero.');
        }
    }

    public static void checkShoeProfit(SObject obj, User usrObj) {
        if(usrObj.Working_Capital__c < 0) {
            obj.addError('Profit calculated from Buy Amount and Sell Amount will make Record owner\'s Working Capital  (' 
                    + usrObj.Name + ': ' + usrObj.Working_Capital__c + ' dollars) less than zero.');
        }
    }
}
