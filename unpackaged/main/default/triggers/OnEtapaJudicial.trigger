trigger OnEtapaJudicial on Etapa_Judicial__c (after insert, after update, after delete) {

	if(!AsuntosService.triggerOnEtapaJudicialHasExecuted)
	{
		if(Trigger.isInsert || Trigger.isUpdate)
		{
			AsuntosService.updateEtapasJudicialesAndCodigos(Trigger.new);
		}
		if(Trigger.isDelete)
		{
			AsuntosService.updateEtapasJudicialesAndCodigos(Trigger.old);
		}
	}
}