import { LightningElement, api } from 'lwc';

export default class ShoeThumbnail extends LightningElement {
    @api shoeData;

    get lowest(){
        let price = null;
        let brand = null;
        let brandsObj = this.shoeData.lowestResellPrice;

        if(this.shoeData) {
            for(let key in brandsObj){
                if(price === null || brandsObj[key] < price) {
                    price = brandsObj[key];
                    brand = key;
                }
            }
        }
        return {price, brand};
    }

    clickHandler(evt){
        const cusEvt = new CustomEvent('sendshoedetail', {detail: this.shoeData.styleID});
        this.dispatchEvent(cusEvt);
    }
}