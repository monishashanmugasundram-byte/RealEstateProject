public with sharing class PropertyController {
    @AuraEnabled(cacheable=true)
    public static List<Property__c> getProperties() {
        try {
            return [SELECT Id, Name, City__c, Status__c, 
                    Furnishing_Status__c, Rent__c 
                    FROM Property__c 
                    ORDER BY Name ASC
                    LIMIT 1000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}