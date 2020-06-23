trigger CaseTrigger on Case (before insert, before update, after insert) {
    if(trigger.isAfter){
        Set<Id> caseIdSet = new Set<Id>();
        for(Case c : trigger.new) {
            caseIdSet.add(c.Id);
        }
    
        List<Case> caseList = new List<Case>();
    
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
    
        for(Case c : [SELECT Id FROM Case WHERE Id IN: caseIdSet]) {
            /*if((c.Owner).ProfileId == '00e6g000000VaM1AAK'){
                
            }*/
            c.setOptions(dmo);
            caseList.add(c);
        }
    
        update caseList;
    }
    
    if(Trigger.isBefore){
            //handle entitlement
        Set<Id> contactIds = new Set<Id>();
        Set<Id> acctIds = new Set<Id>();
        for (Case c : Trigger.new) {
            contactIds.add(c.ContactId);
            acctIds.add(c.AccountId);
        }
        List <EntitlementContact> entlContacts = 
                    [Select e.EntitlementId,e.ContactId,e.Entitlement.AssetId 
                    From EntitlementContact e
                    Where e.ContactId in :contactIds
                    And e.Entitlement.EndDate >= Today 
                    And e.Entitlement.StartDate <= Today];
        if(entlContacts.isEmpty()==false){
            for(Case c : Trigger.new){
                if(c.EntitlementId == null && c.ContactId != null){
                    for(EntitlementContact ec:entlContacts){
                        if(ec.ContactId==c.ContactId){
                            c.EntitlementId = ec.EntitlementId;
                            if(c.AssetId==null && ec.Entitlement.AssetId!=null)
                                c.AssetId=ec.Entitlement.AssetId;
                            break;
                        }
                    } 
                }
            } 
        } else{
            List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate, 
                    e.AccountId, e.AssetId
                    From Entitlement e
                    Where e.AccountId in :acctIds And e.EndDate >= Today 
                    And e.StartDate <= Today];
            if(entls.isEmpty()==false){
                for(Case c : Trigger.new){
                    if(c.EntitlementId == null && c.AccountId != null){
                        for(Entitlement e:entls){
                            if(e.AccountId==c.AccountId){
                                c.EntitlementId = e.Id;
                                if(c.AssetId==null && e.AssetId!=null)
                                    c.AssetId=e.AssetId;
                                break;
                            }
                        } 
                    }
                } 
            }
        }

    }
    
}