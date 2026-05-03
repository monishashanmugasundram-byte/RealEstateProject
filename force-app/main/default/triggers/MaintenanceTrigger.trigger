trigger MaintenanceTrigger on Maintenance__c (before insert) {
    List<Vendor__c> vendors = [
        SELECT Id,
        (SELECT Id FROM Maintenance__r
         WHERE Status__c IN ('Open','In Progress'))
        FROM Vendor__c
    ];
    if (vendors.isEmpty()) return;
    for (Maintenance__c mr : Trigger.new) {
        if (mr.Vendor__c == null) {
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
    }
}