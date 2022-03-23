import { LightningElement, api } from 'lwc';

export default class ShoeThumbnail extends LightningElement {
    @api shoeData;
    
    get lowestPrice(){
        let lowest = null;
        let brandsObj = this.shoeData.lowestResellPrice;

        if(this.shoeData) {
            for(let key in brandsObj){
                if(lowest === null || brandsObj[key] < lowest) {
                    lowest = brandsObj[key];
                }
            }
        }
        return lowest === null ? 0 : lowest;
    }
    get lowestBrand(){
        let lowest = null;
        let brand = null;
        let brandsObj = this.shoeData.lowestResellPrice;

        if(this.shoeData) {
            for(let key in brandsObj){
                if(lowest === null || brandsObj[key] < lowest) {
                    lowest = brandsObj[key];
                    brand = key;
                }
            }
        }
        return brand === null ? '--' : brand;
    }
}