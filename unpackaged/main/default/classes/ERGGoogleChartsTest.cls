@isTest 
public class ERGGoogleChartsTest {
	
	@isTest
	private static void it_should_load_data()
	{
	
		List<Asunto__c> elAsunto = ERGDataFactory.createAsuntos(1); 
		elAsunto[0].Fecha_de_Asignacion_AE__c = System.today(); 
		update elAsunto; 
		
		Etapa_Judicial__c demanda = ERGDataFactory.addEtapaJudicial(elAsunto[0].Id, 'Demanda', System.today().addDays(5)); 
		List<Etapa_Judicial__c> etapas = new List<Etapa_Judicial__c>{demanda};
		
		Map<String,String> fieldColumns = new Map<String,String>(); 
		fieldColumns.put('Main', 'Main'); 
		fieldColumns.put('Label', 'Etapa_Judicial__c'); 
		fieldColumns.put('Start', 'Fecha_de_Etapa_Judicial__c'); 
		fieldColumns.put('End', 'End'); 
		ERGGoogleChartsTimelineSeq theChart = new ERGGoogleChartsTimelineSeq(etapas, Etapa_Judicial__c.SObjectType,  fieldColumns, elAsunto[0].Fecha_de_Asignacion_AE__c, 'Asignacion a AE', elAsunto[0].Name);
		
		System.assertEquals(4, theChart.columns.size()); 
		System.assertEquals(2, theChart.rows.size()); 
	}
}