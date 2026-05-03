public with sharing class MaintenanceRequestController {

    @AuraEnabled
    public static void assignVendor(Id maintenanceRequestId) {
        // Get all vendors
        List<Vendor__c> vendors = [
            SELECT Id, Name 
            FROM Vendor__c
        ];

        if (vendors.isEmpty()) return;

        // Count open requests per vendor
        List<AggregateResult> vendorWorkload = [
            SELECT Vendor__c, COUNT(Id) requestCount
            FROM Maintenance__c
            WHERE Status__c NOT IN ('Completed', 'Cancelled')
            AND Vendor__c != null
            GROUP BY Vendor__c
        ];

        // Map vendor id to workload count
        Map<Id, Integer> workloadMap = new Map<Id, Integer>();
        for (Vendor__c v : vendors) {
            workloadMap.put(v.Id, 0);
        }
        for (AggregateResult ar : vendorWorkload) {
            Id vendorId = (Id)ar.get('Vendor__c');
            Integer count = (Integer)ar.get('requestCount');
            workloadMap.put(vendorId, count);
        }

        // Find vendor with least workload
        Id leastBusyVendor = null;
        Integer minCount = 999999;
        for (Id vendorId : workloadMap.keySet()) {
            if (workloadMap.get(vendorId) < minCount) {
                minCount = workloadMap.get(vendorId);
                leastBusyVendor = vendorId;
            }
        }

        // Assign vendor to maintenance request
        if (leastBusyVendor != null) {
            Maintenance__c mr = [
                SELECT Id, Vendor__c 
                FROM Maintenance__c 
                WHERE Id = :maintenanceRequestId
            ];
            mr.Vendor__c = leastBusyVendor;
            update mr;
        }
    }
}