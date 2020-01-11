trigger AlluraTrigger on Opportunity (after update) {
    for(Opportunity opp:Trigger.New){
        if(opp.StageName == 'Proposal/Price Quote') {
            AlluraClass ac = new AlluraClass();
            ac.AlluraClass(opp.Id);
            System.enqueueJob(ac);
        }
    }
}
