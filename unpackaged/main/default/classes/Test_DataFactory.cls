public class Test_DataFactory {

	public static Contact createContact(String lastName)
	{
		Contact theContact = new Contact(LastName = lastName); 
		insert theContact;
		return theContact;
	}

	public static Sucursal__c createSucursal(String sucursalName)
	{
		Sucursal__c sucursal = new Sucursal__c(Name=sucursalName, Ciudad2__c = 'Monterrey');
		insert sucursal; 
		return sucursal;
	}

	public static Asunto__c createAsunto(Id sucursal, Id interno, Id externo)
	{
		Asunto__c theAsunto = Test_DataFactory.buildAsunto(sucursal, interno, externo);
		insert theAsunto; 
		return theAsunto;
	}

	public static Asunto__c buildAsunto(Id sucursal, Id interno, Id externo)
	{
		Asunto__c theAsunto = new Asunto__c();
		theAsunto.Fecha_de_Ingreso__c = System.today(); 
		theAsunto.Abogado_Interno__c = interno;
		theAsunto.Abogado_Externo__c = externo;
		theAsunto.Sucursal__c = sucursal;
		theAsunto.Acreditado__c = 'el acreditado';
		return theAsunto;
	}

	public static Asunto__c createOneAsunto()
	{
		Contact interno = Test_DataFactory.createContact('interno');
		Contact externo = Test_DataFactory.createContact('externo');
		Sucursal__c sucursal = Test_DataFactory.createSucursal('sucursal');
		Asunto__c asunto = Test_DataFactory.createAsunto(sucursal.Id, interno.Id, externo.Id);
		return asunto;
	}

	public static Asunto__c buildOneAsunto()
	{
		Contact interno = Test_DataFactory.createContact('interno');
		Contact externo = Test_DataFactory.createContact('externo');
		Sucursal__c sucursal = Test_DataFactory.createSucursal('sucursal');
		Asunto__c asunto = Test_DataFactory.buildAsunto(sucursal.Id, interno.Id, externo.Id);
		return asunto;
	}

	public static Asunto__c createOneAsuntoWithNumerosDeCredito()
	{
		Asunto__c theAsunto = Test_DataFactory.buildOneAsunto(); 
		theAsunto.Deudores_Importe_Only__c = 'deudores';
		theAsunto.Monto_Importe_Only__c = 1000;
		theAsunto.NDC_Importe_Only__c = '12345,67890';
		insert theAsunto;
		return theAsunto;
	}

	public static Asunto__c createOneAsuntoWithEtapaJudicial()
	{
		Asunto__c theAsunto = Test_DataFactory.buildOneAsunto(); 
		theAsunto.Etapa_Judicial_Importe_Only__c = 'Demanda';
		insert theAsunto;
		return theAsunto;
	}
	
	public static Etapa_Judicial__c createAsignacionAExternoEtapa(Id asuntoId)
	{
		Etapa_Judicial__c theEtapa = new Etapa_Judicial__c();
		theEtapa.Etapa_Judicial__c = 'Demanda';
		theEtapa.Codigo_de_Resultado__c = '10 - Asignación a Externo';
		theEtapa.Fecha_de_Etapa_Judicial__c = System.today();
		theEtapa.Asunto__c = asuntoId; 
		insert theEtapa;
		return theEtapa;
	}

	public static SECAL_App__c enableImportProcesses()
	{
		SECAL_App__c appSettings = new SECAL_App__c(); 
		appSettings.Crear_Numeros_de_Credito_en_Importe__c = true;
		appSettings.Crear_Etapas_Judiciales_en_Importe__c = true;
		insert appSettings;
		return appSettings;
	}
}