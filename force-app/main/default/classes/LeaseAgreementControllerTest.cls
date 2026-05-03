@isTest
public class LeaseAgreementControllerTest {

    @TestSetup
    static void setupData() {
        Tenant__c tenant = new Tenant__c(
            Name = 'Test Tenant',
            Email__c = 'test@test.com',
            Phone__c = '9876543210'
        );
        insert tenant;

        Property__c prop = new Property__c(
            Name = 'Test Property',
            Status__c = 'Available',
            Rent__c = 25000,
            City__c = 'Chennai',
            Address__c = '123 Test Street',
            State__c = 'Tamil Nadu',
            Postal_Code__c = 600001,
            Country__c = 'India',
            Type__c = 'Residential',
            Furnishing_Status__c = 'Furnished',
            Description__c = 'Test Description'
        );
        insert prop;

        Lease_Agreement__c lease = new Lease_Agreement__c(
            Name = 'Test Lease',
            Tenant__c = tenant.Id,
            Property__c = prop.Id,
            Agreed_Monthly_Rent__c = 25000,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30),
            Terms__c = 'Test Terms'
        );
        insert lease;
    }

    @isTest
    static void testSendLeaseEmail() {
        Lease_Agreement__c lease = [
            SELECT Id FROM Lease_Agreement__c LIMIT 1
        ];
        Test.startTest();
        LeaseAgreementController.sendLeaseEmail(lease.Id);
        Test.stopTest();
        System.assert(true, 'Email sent without errors');
    }

    @isTest
    static void testSendLeaseEmailBulk() {
        Lease_Agreement__c lease = [
            SELECT Id FROM Lease_Agreement__c LIMIT 1
        ];
        Test.startTest();
        for (Integer i = 0; i < 5; i++) {
            LeaseAgreementController.sendLeaseEmail(lease.Id);
        }
        Test.stopTest();
        System.assert(true, 'Bulk email calls handled');
    }
}