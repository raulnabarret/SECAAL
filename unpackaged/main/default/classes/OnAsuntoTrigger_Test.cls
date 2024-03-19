@isTest
private class OnAsuntoTrigger_Test {
	
	@isTest static void should_update_etapa_judicial() {
		// Implement test code
		Asunto__c theAsunto = Test_DataFactory.createOneAsunto();
		AsuntosService.triggerOnAsuntosHasExecuted = false;
		Etapa_Judicial__c asignacionAExterno = Test_DataFactory.createAsignacionAExternoEtapa(theAsunto.Id);
		Asunto__c testAsunto = [SELECT Id, Etapa_Judicial_RO__c, Codigo_de_Resultado_RO__c FROM Asunto__c WHERE Id =: theAsunto.Id];
		System.assertEquals(testAsunto.Etapa_Judicial_RO__c, asignacionAExterno.Etapa_Judicial__c);
		System.assertEquals(testAsunto.Codigo_de_Resultado_RO__c, asignacionAExterno.Codigo_de_Resultado__c);
	}
	/*
	@isTest static void should_create_numero_de_credito() {
		// Implement test code
		SECAL_App__c settingsApp = Test_DataFactory.enableImportProcesses();
		Asunto__c theAsunto = Test_DataFactory.createOneAsuntoWithNumerosDeCredito();
		List<Numero_de_Credito__c> testNumerosDeCredito = [SELECT Id, Monto__c, Numero_de_Credito__c, Terceros_Obligados__c FROM Numero_de_Credito__c WHERE Asunto__c =: theAsunto.Id];
		Boolean montoSet = false;
		Boolean tercerosSet = false; 
		List<String> numerosDeCredito = theAsunto.NDC_Importe_Only__c.split(',');
		Set<String> numerosDeCreditoSet = new Set<String>(numerosDeCredito);
		for(Numero_de_Credito__c ndc : testNumerosDeCredito)
		{
			if(ndc.Monto__c == theAsunto.Monto_Importe_Only__c) montoSet = true;
			if(ndc.Terceros_Obligados__c == theAsunto.Deudores_Importe_Only__c) tercerosSet = true;
			if(!numerosDeCreditoSet.contains(ndc.Numero_de_Credito__c)) System.assert(false);
		}
		System.assert(montoSet);
		System.assert(tercerosSet);
	}

	@isTest static void should_create_etapa_judicial() {
		// Implement test code
		SECAL_App__c settingsApp = Test_DataFactory.enableImportProcesses();
		Asunto__c theAsunto = Test_DataFactory.createOneAsuntoWithEtapaJudicial(); 
		Etapa_Judicial__c theEtapa = [SELECT Id, Etapa_Judicial__c FROM Etapa_Judicial__c WHERE Asunto__c =: theAsunto.Id LIMIT 1];
		System.assertEquals(theEtapa.Etapa_Judicial__c, theAsunto.Etapa_Judicial_Importe_Only__c);
	}
	*/
}