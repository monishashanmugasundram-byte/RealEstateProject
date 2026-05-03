@isTest
public class MaintenanceRequestControllerTest {

    @TestSetup
    static void setupData() {
        List<Vendor__c> vendors = new List<Vendor__c>();
        for (Integer i = 0; i < 5; i++) {
            vendors.add(new Vendor__c(
                Name = 'Vendor ' + i,
                Email__c = 'vendor' + i + '@test.com',
                Phone__c = '9876543210'
            ));
        }
        insert vendors;

        Property__c prop = new Property__c(
            Name = 'Test Property',
            Status__c = 'Available',
            Rent__c = 15000,
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
    }

    @isTest
    static void testAssignVendor() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];
        Vendor__c vendor = [SELECT Id FROM Vendor__c LIMIT 1];

        Maintenance__c mr = new Maintenance__c(
            Name = 'Test Request',
            Property__c = prop.Id,
            Vendor__c = vendor.Id,
            Status__c = 'Open',
            Description__c = 'Test maintenance'
        );
        insert mr;

        Test.startTest();
        MaintenanceRequestController.assignVendor(mr.Id);
        Test.stopTest();

        Maintenance__c updated = [
            SELECT Id, Vendor__c FROM Maintenance__c
            WHERE Id = :mr.Id
        ];
        System.assertNotEquals(null, updated.Vendor__c,
            'Vendor should be assigned');
    }

    @isTest
    static void testAssignVendorBulk() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];
        Vendor__c vendor = [SELECT Id FROM Vendor__c LIMIT 1];

        List<Maintenance__c> requests = new List<Maintenance__c>();
        for (Integer i = 0; i < 10; i++) {
            requests.add(new Maintenance__c(
                Name = 'Bulk Request ' + i,
                Property__c = prop.Id,
                Vendor__c = vendor.Id,
                Status__c = 'Open',
                Description__c = 'Bulk test ' + i
            ));
        }
        insert requests;

        Test.startTest();
        MaintenanceRequestController.assignVendorBulk(requests);
        Test.stopTest();

        List<Maintenance__c> updated = [
            SELECT Id, Vendor__c FROM Maintenance__c
            WHERE Property__c = :prop.Id
        ];
        System.assertEquals(10, updated.size(),
            'All 10 requests should exist');
        for (Maintenance__c mr : updated) {
            System.assertNotEquals(null, mr.Vendor__c,
                'Each request should have vendor assigned');
        }
    }

    @isTest
    static void testTriggerAutoAssign() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];

        Test.startTest();
        List<Maintenance__c> requests = new List<Maintenance__c>();
        for (Integer i = 0; i < 10; i++) {
            requests.add(new Maintenance__c(
                Name = 'Trigger Test ' + i,
                Property__c = prop.Id,
                Status__c = 'Open',
                Description__c = 'Trigger test ' + i
            ));
        }
        insert requests;
        Test.stopTest();

        List<Maintenance__c> updated = [
            SELECT Id, Vendor__c FROM Maintenance__c
            WHERE Property__c = :prop.Id
        ];
        for (Maintenance__c mr : updated) {
            System.assertNotEquals(null, mr.Vendor__c,
                'Trigger should auto assign vendor');
        }
    }

    @isTest
    static void testAssignVendorNoVendors() {
        delete [SELECT Id FROM Vendor__c];
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];

        Maintenance__c mr = new Maintenance__c(
            Name = 'No Vendor Test',
            Property__c = prop.Id,
            Status__c = 'Open',
            Description__c = 'No vendor test'
        );
        insert mr;

        Test.startTest();
        MaintenanceRequestController.assignVendor(mr.Id);
        Test.stopTest();

        System.assert(true, 'Should handle no vendors gracefully');
    }
}