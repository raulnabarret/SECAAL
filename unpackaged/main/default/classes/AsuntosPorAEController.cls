public with sharing class AsuntosPorAEController {

	public String aeID {get; set;}
	public List<Asunto__c> losAsuntos {get; set;}

	public AsuntosPorAEController() {
		aeID = apexpages.currentpage().getparameters().get('AEID');
		if(aeID == null)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No se encontro al Abogado Externo en el Sistema.'));
			losAsuntos = new List<Asunto__c>();
		}
		else
		{
			losAsuntos = [SELECT Id, 
								Abogado_Externo__c,
								Abogado_Interno__c, 
								Acreditado__c, 
								Etapa_Judicial_RO__c, 
								Codigo_de_Resultado_RO__c
								FROM Asunto__c 
								WHERE Abogado_Externo__c =: aeID ];
		}
	}
}