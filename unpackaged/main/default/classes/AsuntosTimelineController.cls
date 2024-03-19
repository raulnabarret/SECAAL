public with sharing class AsuntosTimelineController {
    
    private final sObject mysObject;
    public ERGGoogleChartsTimelineSeq timelineData {get; set;}
    public Boolean timelineHasData {get; set;}
    public AsuntosTimelineController(ApexPages.StandardController stdController)
    {
        this.mysObject = (sObject)stdController.getRecord();
        List<Asunto__c> elAsunto = [SELECT Id, Fecha_de_Asignacion_AE__c, Name FROM Asunto__c WHERE Id =: this.mysObject.Id LIMIT 1];
        
        List<Etapa_Judicial__c> etapas = [SELECT Id, Etapa_Judicial__c, Fecha_de_Etapa_Judicial__c FROM Etapa_Judicial__c WHERE Asunto__c =: elAsunto[0].Id ORDER BY Fecha_de_Etapa_Judicial__c ASC];
        Map<String,String> columns = new Map<String,String>(); 
        columns.put('Main', 'Main'); 
        columns.put('Label', 'Etapa_Judicial__c'); 
        columns.put('Start', 'Fecha_de_Etapa_Judicial__c'); 
        columns.put('End','End');
        timelineData = new ERGGoogleChartsTimelineSeq((List<SObject>) etapas, Etapa_Judicial__c.SObjectType, columns, elAsunto[0].Fecha_de_Asignacion_AE__c, 'Asignacion a AE', elAsunto[0].Name);
    
        timelineHasData = !timelineData.rows.isEmpty();
    }
}