/*
    Creation of account validate the billing address of account and update latitute and logitute value
*/

/*
    Solution : trigger on after insert,update making a callout 
*/


trigger AccountTrigger on Account (after insert,after update){

    AccountTriggerHandler accountHanlder = TriggerHandler.getTriggerHandler(account.sobjectType);
    accountHanlder.updateAccountAddress(Trigger.newMap.keySet().get(0));
}
public class BatchAccountAddressUpdater implemets Database.Batchable<sobject>,Database.AllowsCallout,Database.stateful {
    List<string> recIds;
    public BatchAccountAddressUpdater(List<string> recIds){
        this.recIds = recIds;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('select Id , Name ,Location__Latitude__s  , Location__Longitude__s, 
                       BillingStreet ,BillingCity ,BillingState ,BillingPostalCode,
                       BillingCountry from Account where id : '+recIds);
    }
    public void execute(Database.BatchableContext bc , List<Account> accounts){
        List<Account> updateAccounts = new List<Account>();
        for(Account acc : accounts){
            String httpReqURI = 'https://maps.googleapis.com/maps/api/geocode/json?address='+
            acc.BillingStreet+','+acc.BillingCity+','
            +acc.BillingState+','+acc.BillingPostalCode+','+
            acc.BillingCountry
            +'&key=AIzaSyBDZab96dfn0JTbg2z7dsUhMQyA-pxwKxg';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
        
            if (response.getStatusCode() == 200) {
                JSONParser parser = JSON.createParser(response.getBody());
                Map <String, Object> root = (Map <String, Object>) JSON.deserializeUntyped(response.getBody());
                List <Object> childLevel = (List<Object>) root.get('results');
                for( Object o : childLevel){
                    Map <String, Object> childLevel2 = (Map <String, Object>) o;
                    Map <String, Object> grandChaildLevel= (Map <String, Object>) childLevel2.get('geometry');
                    Object objFinal = grandChaildLevel.get('location');
                    Map<String, Object> locs = (Map<String, Object>)objFinal;
                    acc.Location__Latitude__s = (Decimal)locs.get('lat') ; 
                    acc.Location__Longitude__s = (Decimal)locs.get('lng');
                    updateAccounts.add(acc);
                }
            }
        }
        if(!updateAccounts.isEmpty())
            update updateAccounts;
    }
}