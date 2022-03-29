import { LightningElement, api } from 'lwc';

export default class ShoeModal extends LightningElement {
    @api shoeData;
    
    priceChart = null;
    renderedCallbackDidRun = false;

    get description(){
        return this.shoeData.description === '' ? 'No description available.' : this.shoeData.description;
    }

    get lowestPrices() {
        return Object.keys(this.shoeData.lowestResellPrice).map((brandName, ind) => {
            return {id: ind, name: brandName, price: this.shoeData.lowestResellPrice[brandName]}
        });
    }

    priceChartHelperFn(priceSizeObj) {
        let chartMap = {};
    
        // transform object {brandX: {'5': 120, '6': 150}, brandY: {'5': 125, '6': 155}} to
        // {'5':{brandX: 120, brandY: 125}, '6':{brandX: 120, brandY: 155}}
        for (let brandKey in priceSizeObj) {
            for (let sizeKey in priceSizeObj[brandKey]) {
                if (!chartMap[sizeKey]) chartMap[sizeKey] = {_id: sizeKey};
                chartMap[sizeKey][brandKey] = priceSizeObj[brandKey][sizeKey];
            }
        }
    
        let keys = Object.keys(chartMap);
        keys.sort((a, b) => a - b);
    
        let sortedSizeObjList = keys.map((key) => {
            return chartMap[key];
        });
    
        return sortedSizeObjList;
    };

    backButtonHandler(){
        const cusEvt = new CustomEvent('closemodal');
        this.dispatchEvent(cusEvt);
    }

    renderedCallback() {
        if(this.renderedCallbackDidRun) return;
        this.priceChart = this.priceChartHelperFn(this.shoeData?.resellPrices);
        this.renderedCallbackDidRun = true;
    }
}