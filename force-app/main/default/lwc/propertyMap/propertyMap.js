import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Property__c.Name',
    'Property__c.Address__c',
    'Property__c.City__c',
    'Property__c.State__c',
    'Property__c.Postal_Code__c',
    'Property__c.Country__c'
];

export default class PropertyMap extends LightningElement {
    @api recordId;
    @track mapMarkers = null;
    zoomLevel = 14;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredProperty({ data, error }) {
        if (data) {
            const fields = data.fields;
            this.mapMarkers = [{
                location: {
                    City: fields.City__c.value || 'Coimbatore',
                    State: fields.State__c.value || 'Tamil Nadu',
                    Country: fields.Country__c.value || 'India'
                },
                title: fields.Name.value || 'Property',
                description: 'Property Location'
            }];
        } else if (error) {
            console.error('Error:', JSON.stringify(error));
            this.mapMarkers = null;
        }
    }

    get hasMarkers() {
        return this.mapMarkers && this.mapMarkers.length > 0;
    }
}