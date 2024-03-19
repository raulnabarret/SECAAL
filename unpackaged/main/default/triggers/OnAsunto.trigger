trigger OnAsunto on Asunto__c (before update, after insert) {

	if(!AsuntosService.triggerOnAsuntosHasExecuted)
	{	
		/*
		System.debug('Trigger has not executed, entering...');
		if(Trigger.isBefore && Trigger.isUpdate)
		{

			List<Etapa_Judicial__c> allEtapasJuridicas = [SELECT Id, Codigo_de_Resultado__c, Etapa_Judicial__c, Fecha_de_Etapa_Judicial__c, Nivel_de_Etapa__c, Asunto__c, CreatedDate FROM Etapa_Judicial__c WHERE Asunto__c IN: Trigger.newMap.keySet() ORDER BY Fecha_de_Etapa_Judicial__c DESC];
			System.debug('allEtapasJuridicas = '+allEtapasJuridicas);
			Map<ID,Etapa_Judicial__c> mapAsuntoIdToEtapaJudicial = AsuntosService.getMapAsuntoToEtapaJudicial(allEtapasJuridicas);
			System.debug('mapAsuntoIdToEtapaJudicial = '+mapAsuntoIdToEtapaJudicial);
			for(Asunto__c asunto: Trigger.new)
			{
				System.debug('Looping through asuntos...');
				if(mapAsuntoIdToEtapaJudicial.get(asunto.Id) != null)
				{
					asunto.Etapa_Judicial_RO__c = mapAsuntoIdToEtapaJudicial.get(asunto.Id).Etapa_Judicial__c;
					asunto.Codigo_de_Resultado_RO__c = mapAsuntoIdToEtapaJudicial.get(asunto.Id).Codigo_de_Resultado__c;
					System.debug('Mapping Etapa Judicial: '+asunto.Etapa_Judicial_RO__c);
					System.debug('Codigo de Resulto: '+asunto.Codigo_de_Resultado_RO__c);
				}
			}
		}
		*/
		if(Trigger.isAfter)
		{
			if(Trigger.isInsert)
			{
				if(AsuntosService.createNumerosDeCreditoIsEnabled()) AsuntosService.createNumerosDeCredito(Trigger.new);
				if(AsuntosService.createEtapaJudicialIsEnabled()) AsuntosService.createEtapaJudicial(Trigger.new);
			}
			AsuntosService.triggerOnAsuntosHasExecuted = true;
		}
	}
}