public with sharing class LeaseAgreementController {
    @AuraEnabled
    public static void sendLeaseEmail(Id recordId) {
        Lease_Agreement__c lease = [
            SELECT Id, Name, Agreed_Monthly_Rent__c, 
                   Start_Date__c, End_Date__c, Terms__c,
                   Tenant__r.Name, Tenant__r.Email__c,
                   Property__r.Name
            FROM Lease_Agreement__c 
            WHERE Id = :recordId
            LIMIT 1
        ];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{ lease.Tenant__r.Email__c });
        email.setSubject('Your Lease Agreement - ' + lease.Name);
        email.setPlainTextBody(
            'Dear ' + lease.Tenant__r.Name + ',\n\n' +
            'Please find your lease agreement details below:\n\n' +
            'Property: ' + lease.Property__r.Name + '\n' +
            'Monthly Rent: $' + lease.Agreed_Monthly_Rent__c + '\n' +
            'Start Date: ' + lease.Start_Date__c + '\n' +
            'End Date: ' + lease.End_Date__c + '\n' +
            'Terms: ' + (lease.Terms__c != null ? lease.Terms__c : 'N/A') + '\n\n' +
            'Thank you.'
        );

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });
    }
}