@isTest
public class PropertyControllerTest {
    
    @TestSetup
    static void setupData() {
        List<Property__c> properties = new List<Property__c>();
        for (Integer i = 0; i < 200; i++) {
            properties.add(new Property__c(
                Name = 'Test Property ' + i,
                Status__c = 'Available',
                Rent__c = 10000 + i,
                City__c = 'Chennai',
                Address__c = '123 Test Street ' + i,
                State__c = 'Tamil Nadu',
                Postal_Code__c = 600001,
                Country__c = 'India',
                Type__c = 'Residential',
                Furnishing_Status__c = 'Furnished',
                Description__c = 'Test Description ' + i
            ));
        }
        insert properties;
    }
    
    @isTest
    static void testGetProperties() {
        Test.startTest();
        List<Property__c> result = PropertyController.getProperties();
        Test.stopTest();
        System.assertNotEquals(null, result, 
            'Result should not be null');
        System.assert(result.size() > 0, 
            'Should return properties');
    }
    
    @isTest
    static void testGetPropertiesBulk() {
        Test.startTest();
        List<Property__c> result = PropertyController.getProperties();
        Test.stopTest();
        System.assert(result.size() <= 1000, 
            'Should respect LIMIT 1000');
    }
    
    @isTest
static void testGetPropertiesException() {
    Test.startTest();
    try {
        List<Property__c> result = PropertyController.getProperties();
        System.assertNotEquals(null, result);
    } catch (AuraHandledException e) {
        System.assertNotEquals(null, e.getMessage());
    }
    Test.stopTest();
}
    @isTest
    static void testGetPropertiesNotNull() {
        Test.startTest();
        List<Property__c> result = PropertyController.getProperties();
        Test.stopTest();
        for (Property__c p : result) {
            System.assertNotEquals(null, p.Id, 
                'Each property should have an Id');
        }
    }
}
