import { LightningElement } from 'lwc';

export default class ShoePanel extends LightningElement {

    searchItems = '';
    products = [];
    numberOfItems = 10;

    dataLoaded = false;

    connectedCallback(){

        console.log('connected callback ran');

        const getTrending = async () => {

            let data = {};
            try {
                let response = await fetch(`https://us-central1-kicksrestapi.cloudfunctions.net/getTrending?numberOfItems=${this.numberOfItems}`);
                data = await response.json();
                if(data.error) data = {error: data?.error?.error, message: data.error.message }
            } catch (e) {
                data = { error: e, message: '(c) Error retrieving sneakers' };
            }

            if(!data.error) {
                this.products = data;
                this.dataLoaded = true;
            }

            console.log(this.products);
        }

        getTrending();
    }

}