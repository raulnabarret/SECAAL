public with sharing class ERGDataFactory {

	// ------------------ ACCOUNT METHODS ------------------------

	public static List<Account> createAccounts(Integer pNumber)
	{
		List<Account> accountsToCreate = new List<Account>(); 

		if(pNumber <= 0) return accountsToCreate; 

		for(Integer i = 0; i < pNumber; i++)
		{
			Account newAccount = new Account(Name = 'Name'+i); 
			accountsToCreate.add(newAccount);
		}

		insert accountsToCreate;

		return accountsToCreate;
	}

	// ------------------ CONTACTS METHODS ------------------------

	public static List<Contact> createContacts(Integer pNumber, Id pAccountId)
	{
		List<Contact> theContactsToCreate = new List<Contact>(); 

		for(Integer i = 0; i < pNumber; i++)
		{
			Contact aContact = new Contact(); 
			aContact.FirstName = 'FirstName'+i;
			aContact.LastName = 'LastName'+i;
			aContact.Email = 'test'+i+'@testContact.com';
			aContact.AccountId = pAccountId;
			theContactsToCreate.add(aContact);
		}

		if(!theContactsToCreate.isEmpty())
		{
			insert theContactsToCreate;
		}

		return theContactsToCreate;
	}
	
	public static List<Sucursal__c> createSucursales(Integer pNumber)
	{
		List<Sucursal__c> sucursalesToCreate = new List<Sucursal__c>(); 

		for(Integer i = 0; i < pNumber; i++)
		{
			Sucursal__c aSucursal = new Sucursal__c(); 
			aSucursal.Name = 'Sucursal'+i;
			aSucursal.Ciudad2__c = 'Ciudad'+i;
			sucursalesToCreate.add(aSucursal);
		}

		if(!sucursalesToCreate.isEmpty())
		{
			insert sucursalesToCreate;
		}

		return sucursalesToCreate;
	}

	public static List<Asunto__c> createAsuntos(Integer pNumber)
	{
		List<Asunto__c> asuntosToCreate = new List<Asunto__c>();
		List<Account> accountAbogados = ERGDataFactory.createAccounts(1);
		List<Contact> abogadoInternos = ERGDataFactory.createContacts(1, accountAbogados[0].Id); 
		List<Sucursal__c> sucursales = ERGDataFactory.createSucursales(1); 
		
		for(Integer i = 0; i < pNumber; i++)
		{
			Asunto__c anAsunto = new Asunto__c(); 
			anAsunto.Fecha_de_Ingreso__c = System.today(); 
			anAsunto.Acreditado__c = 'Acreditado'+i;
			anAsunto.Abogado_Interno__c = abogadoInternos[0].Id;
			anAsunto.Direcci_n_o_Filial__c = 'Comercial';
			anAsunto.Sucursal__c = sucursales[0].Id;
			asuntosToCreate.add(anAsunto);
		}

		if(!asuntosToCreate.isEmpty())
		{
			insert asuntosToCreate;
		}

		return asuntosToCreate;
	}
	
	public static Etapa_Judicial__c addEtapaJudicial(Id asuntoId, String etapaName, Date fecha)
	{
		Etapa_Judicial__c theEtapa = new Etapa_Judicial__c(); 
		theEtapa.Asunto__c = asuntoId; 
		theEtapa.Etapa_Judicial__c = etapaName; 
		theEtapa.Fecha_de_Etapa_Judicial__c = fecha; 
		insert theEtapa; 
		return theEtapa; 
	}
}