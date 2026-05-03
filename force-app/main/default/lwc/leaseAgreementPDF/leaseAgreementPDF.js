import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import sendLeaseEmail from '@salesforce/apex/LeaseAgreementController.sendLeaseEmail';
import jspdf from '@salesforce/resourceUrl/jspdf';

const FIELDS = [
    'Lease_Agreement__c.Name',
    'Lease_Agreement__c.Agreed_Monthly_Rent__c',
    'Lease_Agreement__c.Start_Date__c',
    'Lease_Agreement__c.End_Date__c',
    'Lease_Agreement__c.Terms__c',
    'Lease_Agreement__c.Tenant__r.Name',
    'Lease_Agreement__c.Property__r.Name'
];

export default class LeaseAgreementPDF extends LightningElement {
    @api recordId;
    leaseData = null;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredLease({ data, error }) {
        if (data) {
            this.leaseData = data.fields;
        } else if (error) {
            console.error('Error loading lease:', error);
        }
    }

   downloadPDF() {
    if (!this.leaseData) {
        this.showToast('Error', 'Lease data not loaded yet', 'error');
        return;
    }
    loadScript(this, jspdf)
        .then(() => {
            this.generatePDF();
        })
        .catch(error => {
            console.error('Error:', error);
            this.showToast('Error', 'Failed to load PDF library', 'error');
        });
}

    generatePDF() {
        try {
            const fields = this.leaseData;
            const tenantName = fields.Tenant__r?.value?.fields?.Name?.value || 'N/A';
            const propertyName = fields.Property__r?.value?.fields?.Name?.value || 'N/A';
            const rent = fields.Agreed_Monthly_Rent__c?.value || 'N/A';
            const startDate = fields.Start_Date__c?.value || 'N/A';
            const endDate = fields.End_Date__c?.value || 'N/A';
            const terms = fields.Terms__c?.value || 'N/A';
            const name = fields.Name?.value || 'N/A';

            let jsPDFConstructor;
            if (window.jspdf && window.jspdf.jsPDF) {
                jsPDFConstructor = window.jspdf.jsPDF;
            } else if (window.jsPDF) {
                jsPDFConstructor = window.jsPDF;
            } else {
                throw new Error('jsPDF not found');
            }

            const doc = new jsPDFConstructor();

            doc.setFontSize(22);
            doc.setFont('helvetica', 'bold');
            doc.text('LEASE AGREEMENT', 105, 25, { align: 'center' });

            doc.setFontSize(12);
            doc.setFont('helvetica', 'normal');
            doc.line(20, 30, 190, 30);

            doc.text(`Agreement : ${name}`, 20, 45);
            doc.text(`Tenant    : ${tenantName}`, 20, 60);
            doc.text(`Property  : ${propertyName}`, 20, 75);
            doc.text(`Rent      : $${rent}`, 20, 90);
            doc.text(`Start     : ${startDate}`, 20, 105);
            doc.text(`End       : ${endDate}`, 20, 120);
            doc.text(`Terms     : ${terms}`, 20, 135);

            doc.line(20, 145, 190, 145);
            doc.setFontSize(10);
            doc.text('This is an auto-generated lease agreement.', 105, 155, { align: 'center' });

            const pdfData = doc.output('datauristring');
            const link = document.createElement('a');
            link.href = pdfData;
            link.download = 'LeaseAgreement.pdf';
            link.click();

            this.showToast('Success', 'PDF Downloaded Successfully!', 'success');
        } catch(error) {
            console.error('PDF Error:', error.message);
            this.showToast('Error', error.message, 'error');
        }
    }

    sendPDF() {
        sendLeaseEmail({ recordId: this.recordId })
            .then(() => {
                this.showToast('Success', 'PDF sent to Tenant successfully!', 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}