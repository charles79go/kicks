import { LightningElement, api } from 'lwc';

export default class ShoeModal extends LightningElement {
    @api shoeData;

    get description(){
        return this.shoeData.description === '' ? 'No description available.' : this.shoeData.description;
    }

    backButtonHandler(){
        const cusEvt = new CustomEvent('closemodal');
        this.dispatchEvent(cusEvt);
    }

}