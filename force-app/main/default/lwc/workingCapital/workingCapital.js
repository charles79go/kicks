import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import WORKING_CAPITAL from '@salesforce/schema/User.Working_Capital__c';

export default class WorkingCapital extends LightningElement {

    userId = Id;
    workingCapital;

    errorObj;

    @wire(getRecord, {recordId: '$userId', fields: [WORKING_CAPITAL]}) 
    userObjHandler({data, error}) {
        if(data) {
            this.workingCapital = data.fields.Working_Capital__c.displayValue;
        }
        if(error) {
            console.error('error object >>>', error);
            this.errorObj = error;
        }
    }
}