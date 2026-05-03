import { LightningElement, track, wire } from 'lwc';
import getProperties from '@salesforce/apex/PropertyController.getProperties';

const PAGE_SIZE = 25;

const COLUMNS = [
    { label: 'Property Name', fieldName: 'Name' },
    { label: 'City', fieldName: 'City__c' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Furnishing', fieldName: 'Furnishing_Status__c' },
    { label: 'Rent', fieldName: 'Rent__c', type: 'currency' }
];

export default class PropertyListView extends LightningElement {
    @track allProperties = [];
    @track properties = [];
    @track currentPage = 1;
    columns = COLUMNS;

    rentFilter = '';
    statusFilter = '';
    furnishFilter = '';

    statusOptions = [
        { label: 'All', value: '' },
        { label: 'Available', value: 'Available' },
        { label: 'Occupied', value: 'Occupied' }
    ];

    furnishOptions = [
        { label: 'All', value: '' },
        { label: 'Furnished', value: 'Furnished' },
        { label: 'Semi-Furnished', value: 'Semi-Furnished' },
        { label: 'Unfurnished', value: 'Unfurnished' }
    ];

   @wire(getProperties)
wiredProperties({ data, error }) {
    if (data) {
        this.allProperties = data;
        this.applyFilters();
    } else if (error) {
        console.error('Error fetching properties:', error);
    }
}

    handleRentFilter(event) {
        this.rentFilter = event.target.value;
        this.currentPage = 1;
        this.applyFilters();
    }

    handleStatusFilter(event) {
        this.statusFilter = event.target.value;
        this.currentPage = 1;
        this.applyFilters();
    }

    handleFurnishFilter(event) {
        this.furnishFilter = event.target.value;
        this.currentPage = 1;
        this.applyFilters();
    }

    applyFilters() {
        let filtered = this.allProperties;
        if (this.rentFilter) {
            filtered = filtered.filter(p => p.Rent__c <= this.rentFilter);
        }
        if (this.statusFilter) {
            filtered = filtered.filter(p => p.Status__c === this.statusFilter);
        }
        if (this.furnishFilter) {
            filtered = filtered.filter(p => p.Furnishing_Status__c === this.furnishFilter);
        }
        this.filteredProperties = filtered;
        this.updatePage();
    }

    filteredProperties = [];

    get totalPages() {
        return Math.ceil(this.filteredProperties.length / PAGE_SIZE) || 1;
    }
    get isFirstPage() { return this.currentPage === 1; }
    get isLastPage() { return this.currentPage >= this.totalPages; }

    updatePage() {
        const start = (this.currentPage - 1) * PAGE_SIZE;
        this.properties = this.filteredProperties.slice(start, start + PAGE_SIZE);
    }

    previousPage() { this.currentPage--; this.updatePage(); }
    nextPage() { this.currentPage++; this.updatePage(); }
}