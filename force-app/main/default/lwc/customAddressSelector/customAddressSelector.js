import { LightningElement, wire } from 'lwc';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import COUNTRY_CODE from '@salesforce/schema/Account.BillingCountryCode';
import BILLING_STATE_CODE from '@salesforce/schema/Account.BillingStateCode';

export default class CustomAddressSelector extends LightningElement {
    _countries = [];
    _countryToStates = {};

    selectedCountry;
    selectedState;

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: COUNTRY_CODE
    })
    wiredCountires({ data }) {
        this._countries = data?.values;
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: BILLING_STATE_CODE })
    wiredStates({ data }) {
        if (!data) {
            return;
        }

        const validForToCountry = Object.fromEntries(Object.entries(data.controllerValues).map(([key, value]) => [value, key]));

        this._countryToStates = data.values.reduce((accumulatedStates, state) => {
            const countryIsoCode = validForToCountry[state.validFor[0]];

            return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state] };
        }, {});
    }

    get countries() {
        return this._countries;
    }

    get states() {
        return this._countryToStates[this.selectedCountry] || [];
    }

    handleCountry(e) {
        this.selectedCountry = e.detail.value;
    }

    handleState(e) {
        this.selectedState = e.detail.value;
    }
}
