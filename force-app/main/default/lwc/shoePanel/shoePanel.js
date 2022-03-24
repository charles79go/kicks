import { LightningElement } from 'lwc';

export default class ShoePanel extends LightningElement {

    trendingSneakers = [];
    numberOfItems = 12;
    trendingDataLoaded = false;
    searchDataLoaded = false;
    
    isLoading = false;

    searchedSneakers = [];
    searchText = '';

    sneakerDetail = {};
    sneakerDetailDataLoaded = false;

    connectedCallback(){

        const getTrending = async () => {

            this.isLoading = true;

            let data = {};
            try {
                let response = await fetch(`https://us-central1-kicksrestapi.cloudfunctions.net/getTrending?numberOfItems=${this.numberOfItems}`);

                data = await response.json();

                if(data.error) data = console.log(data);

            } catch (e) {
                data = { error: e, message: '(c) Error retrieving sneakers' };
            }

            if(!data.error) {
                this.trendingSneakers = data;
                this.trendingDataLoaded = true;
            }

            this.isLoading = false;
        }

        getTrending();
    }

    async searchShoes(searchText){

        this.isLoading = true;

        let data = {};
        try {
            let response = await fetch(`https://us-central1-kicksrestapi.cloudfunctions.net/searchProducts?searchText=${searchText}&numberOfItems=${this.numberOfItems}`);

            data = await response.json();

            if(data.error) console.log(data);
            

        } catch (e) {
            data = { error: e, message: '(c) Error retrieving sneakers' };
        }

        if(!data.error) {
            this.searchedSneakers = data;
            this.searchDataLoaded = true;
        }

        this.isLoading = false;
    }

    async getShoeDetails(styleId){

        this.isLoading = true;

        let data = {};
        try {
            let response = await fetch(`https://us-central1-kicksrestapi.cloudfunctions.net/getProductPrices?styleId=${styleId}`);

            data = await response.json();

            if(data.error) console.log(data);
            
        } catch (e) {
            data = { error: e, message: '(c) Error retrieving sneakers' };
        }

        if(!data.error) {
            this.sneakerDetail = data;
            this.sneakerDetailDataLoaded = true;
        }

        this.isLoading = false;

        console.log('SNEAKER DETAIL >>>>', this.sneakerDetail);
    }

    handleSearchInput(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.searchShoes(this.searchText);
        }
        this.searchText = evt.target.value;
    }

    handleSearchClick(evt) {
        this.searchShoes(this.searchText);
    }

    onSneakerCardClick(evt) {
        this.getShoeDetails(evt.detail);
    }

    closeModalHandler(){
        this.sneakerDetail = {};
        this.sneakerDetailDataLoaded = false;
    }
}