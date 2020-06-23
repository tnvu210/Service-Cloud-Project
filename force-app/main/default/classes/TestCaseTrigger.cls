@isTest
private class TestCaseTrigger {
	@isTest 
    static void TestCaseTrigger() {
        // Test data setup
        Case c = new Case();
        c.Product__c = 'Health Insurance';
        c.Type = 'Claim';
        c.Status = 'New';
        c.Origin = 'Web';
        insert c;
 
        // Perform test
        Test.startTest();
        Database.DMLOptions dmo = new Database.DMLOptions();
    	dmo.AssignmentRuleHeader.useDefaultRule = true;
        c.setOptions(dmo);
        update c;
        Test.stopTest();
                 
    }
}