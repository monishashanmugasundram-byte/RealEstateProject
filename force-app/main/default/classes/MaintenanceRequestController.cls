public with sharing class MaintenanceRequestController {
    
    public static void assignVendor(Id maintenanceRequestId) {
        List<Vendor__c> vendors = [
            SELECT Id, 
            (SELECT Id FROM Maintenance__r 
             WHERE Status__c IN ('Open','In Progress')) 
            FROM Vendor__c
        ];
        
        if (vendors.isEmpty()) return;
        
        Id leastBusyVendor = null;
        Integer minCount = 999999;
        
        for (Vendor__c v : vendors) {
            Integer count = v.Maintenance__r.size();
            if (count < minCount) {
                minCount = count;
                leastBusyVendor = v.Id;
            }
        }
        
        Maintenance__c mr = [
            SELECT Id, Vendor__c
            FROM Maintenance__c
            WHERE Id = :maintenanceRequestId
        ];
        mr.Vendor__c = leastBusyVendor;
        update mr;
    }

    public static void assignVendorBulk(
            List<Maintenance__c> maintenanceRequests) {
        
        List<Vendor__c> vendors = [
            SELECT Id,
            (SELECT Id FROM Maintenance__r 
             WHERE Status__c IN ('Open','In Progress'))
            FROM Vendor__c
        ];
        
        if (vendors.isEmpty()) return;
        
        for (Maintenance__c mr : maintenanceRequests) {
            Id leastBusyVendor = null;
            Integer minCount = 999999;
            
            for (Vendor__c v : vendors) {
                Integer count = v.Maintenance__r.size();
                if (count < minCount) {
                    minCount = count;
                    leastBusyVendor = v.Id;
                }
            }
            mr.Vendor__c = leastBusyVendor;
        }
        update maintenanceRequests;
    }
}