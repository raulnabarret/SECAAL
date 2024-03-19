public with sharing class AsuntosService {
	
	public static boolean  triggerOnAsuntosHasExecuted = false;
	public static boolean triggerOnEtapaJudicialHasExecuted = false; 

	public static SECAL_App__c appSettings; 

	public static Map<ID,Etapa_Judicial__c> getMapAsuntoToEtapaJudicial(List<Etapa_Judicial__c> pEtapasJudiciales)
	{
		Map<ID,Etapa_Judicial__c> mapAsuntoIdToEtapaJudicial = new Map<ID,Etapa_Judicial__c>(); 

		if(pEtapasJudiciales != null && !pEtapasJudiciales.isEmpty())
		{
			for(Etapa_Judicial__c etapa: pEtapasJudiciales)
			{
				Etapa_Judicial__c theEtapa = mapAsuntoIdToEtapaJudicial.get(etapa.Asunto__c); 
				if(theEtapa == null)
				{
					mapAsuntoIdToEtapaJudicial.put(etapa.Asunto__c, etapa);
				}
				else
				{
					if(theEtapa.Fecha_de_Etapa_Judicial__c < etapa.Fecha_de_Etapa_Judicial__c)
					{
						mapAsuntoIdToEtapaJudicial.put(etapa.Asunto__c, etapa);
					}
					if(theEtapa.Fecha_de_Etapa_Judicial__c == etapa.Fecha_de_Etapa_Judicial__c)
					{
						if(theEtapa.Nivel_de_Etapa__c < etapa.Nivel_de_Etapa__c)
						{
							mapAsuntoIdToEtapaJudicial.put(etapa.Asunto__c, etapa);
						}
						if(theEtapa.Nivel_de_Etapa__c == etapa.Nivel_de_Etapa__c)
						{
							if(theEtapa.CreatedDate < etapa.CreatedDate)
							{
								mapAsuntoIdToEtapaJudicial.put(etapa.Asunto__c, etapa);
							}
						}
					}
				}
			}
		}
		return mapAsuntoIdToEtapaJudicial;
	}

	public static List<Numero_de_Credito__c> createNumerosDeCredito(List<Asunto__c> asuntos)
	{
		List<Numero_de_Credito__c> numerosDeCredito = new List<Numero_de_Credito__c>();

		for(Asunto__c asunto: asuntos)
		{
			System.debug('Adding Credit for Asunto: '+asunto);
			List<String> numerosDeCreditoString = new List<String>(); 
			if(asunto.NDC_Importe_Only__c != null) numerosDeCreditoString = asunto.NDC_Importe_Only__c.split(',');
			for(Integer i = 0; i < numerosDeCreditoString.size(); i++)
			{
				System.debug('Adding Credit :'+numerosDeCreditoString[i]);
				Numero_de_Credito__c newNC = new Numero_de_Credito__c(); 
				newNC.Numero_de_Credito__c = numerosDeCreditoString[i]; 
				newNC.Asunto__c = asunto.Id; 
				newNC.Monto__c = 0;
				if(i == 0)
				{
					newNC.Monto__c = asunto.Monto_Importe_Only__c; 
					newNC.Terceros_Obligados__c = asunto.Deudores_Importe_Only__c; 
				}
				numerosDeCredito.add(newNC);
			}
		}
		if(!numerosDeCredito.isEmpty()) insert numerosDeCredito;
		return numerosDeCredito;
	}

	public static List<Etapa_Judicial__c> createEtapaJudicial(List<Asunto__c> asuntos)
	{
		List<Etapa_Judicial__c> etapasJudiciales = new List<Etapa_Judicial__c>(); 
		for(Asunto__c asunto: asuntos)
		{
			Etapa_Judicial__c etapaJudicial = new Etapa_Judicial__c();
			etapaJudicial.Fecha_de_Etapa_Judicial__c = Date.newInstance(2016,3,9); 
			etapaJudicial.Etapa_Judicial__c = asunto.Etapa_Judicial_Importe_Only__c; 
			etapaJudicial.Asunto__c = asunto.Id;
			etapasJudiciales.add(etapaJudicial);
		}
		if(!etapasJudiciales.isEmpty()) insert etapasJudiciales;
		return etapasJudiciales;
	}

	public static Boolean createNumerosDeCreditoIsEnabled()
	{
		if(appSettings == null)
		{
			appSettings = SECAL_App__c.getOrgDefaults();
		}

		return appSettings.Crear_Numeros_de_Credito_en_Importe__c; 
	}

	public static Boolean createEtapaJudicialIsEnabled()
	{
		if(appSettings == null)
		{
			appSettings = SECAL_App__c.getOrgDefaults();
		}

		return appSettings.Crear_Etapas_Judiciales_en_Importe__c; 
	}

	public static void updateEtapasJudicialesAndCodigos(List<Etapa_Judicial__c> etapasList)
	{
		Map<Id,Etapa_Judicial__c> mapAsuntoIdToEtapaJudicial = new Map<Id,Etapa_Judicial__c>();
		Set<Id> allAsuntosIds = new Set<Id>();
		for(Etapa_Judicial__c etapa: etapasList)
		{
			allAsuntosIds.add(etapa.Asunto__c);
		}

		List<Etapa_Judicial__c> allEtapasJuridicas = [SELECT Id, Codigo_de_Resultado__c, Etapa_Judicial__c, Fecha_de_Etapa_Judicial__c, Nivel_de_Etapa__c, Asunto__c, CreatedDate FROM Etapa_Judicial__c WHERE Asunto__c IN: allAsuntosIds ORDER BY Fecha_de_Etapa_Judicial__c DESC];

		mapAsuntoIdToEtapaJudicial = AsuntosService.getMapAsuntoToEtapaJudicial(allEtapasJuridicas);
		
		List<Asunto__c> allAsuntos = [SELECT Id, Etapa_Judicial_RO__c, Codigo_de_Resultado_RO__c FROM Asunto__c WHERE Id IN: mapAsuntoIdToEtapaJudicial.keySet()]; 
		List<Asunto__c> asuntosToUpdate = new List<Asunto__c>();
		for(Asunto__c asunto: allAsuntos)
		{
			if(mapAsuntoIdToEtapaJudicial.get(asunto.Id) != null)
			{
				asunto.Etapa_Judicial_RO__c = mapAsuntoIdToEtapaJudicial.get(asunto.Id).Etapa_Judicial__c;
				asunto.Codigo_de_Resultado_RO__c = mapAsuntoIdToEtapaJudicial.get(asunto.Id).Codigo_de_Resultado__c;
				asuntosToUpdate.add(asunto);
			}
		}
		if(!asuntosToUpdate.isEmpty())
		{
			update asuntosToUpdate;
		}
	}
}