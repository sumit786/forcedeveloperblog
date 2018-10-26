public class MetadataExample{

    public void updateMetadata (){

        Metadata.CustomMetadata customMetadata  = new Metadata.CustomMetadata();
        customMetadata.fullName  = 'MyNamespace__MyMetadataTypeName.MyMetadataRecordName';
        Metadata.CustomMetadataValue customField  = new Metadata.CustomMetadataValue();
        customField.customField__c = 'New value';
        customMetadata.add(customField);

        Metadata.DeployContaine deployContainer  = new Metadata.DeployContaine();
        deployContainer.addMetadata(customMetadata);

        Id asyncResultId = Metadata.Operations.enqueueDeployment(deployContainer, null);
    }
}