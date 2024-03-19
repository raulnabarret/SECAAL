public with sharing class ERGGoogleChartsTimelineSeq {

	public List<ERGGoogleChartsTimelineSeq.Column> columns {get; set;}
	public List<ERGGoogleChartsTimelineSeq.Row> rows {get; set;}
	private Date nextStartDate {get; set;}
	private Date nextEndDate {get; set;}
	private String nextPhaseLabel {get; set;}
	private String principalColumnValue {get; set;}
	
	public ERGGoogleChartsTimelineSeq(List<SObject> pObjects, SObjectType pObjectType, Map<String,String> columnLabelToField, Date startDate, String firstPhaseLabel, String mainColumnValue) {
		
		columns = new List<ERGGoogleChartsTimelineSeq.Column>(); 
		rows = new List<ERGGoogleChartsTimelineSeq.Row>(); 

		for(String label: columnLabelToField.keySet())
		{
			
			String chartsFieldType = '';
			if(label != 'Main' && label != 'End')
			{
				Schema.DisplayType apexFieldType = ERGUtils.getFieldType(pObjectType, columnLabelToField.get(label));  
				if(apexFieldType == Schema.DisplayType.Boolean) chartsFieldType = 'boolean'; 
				if(apexFieldType == Schema.DisplayType.Currency) chartsFieldType = 'number'; 
				if(apexFieldType == Schema.DisplayType.String) chartsFieldType = 'string'; 
				if(apexFieldType == Schema.DisplayType.Picklist) chartsFieldType = 'string'; 
				if(apexFieldType == Schema.DisplayType.Percent) chartsFieldType = 'number'; 
				if(apexFieldType == Schema.DisplayType.Integer) chartsFieldType = 'number';
				if(apexFieldType == Schema.DisplayType.Double) chartsFieldType = 'number'; 
				if(apexFieldType == Schema.DisplayType.Date) chartsFieldType = 'date';
				if(apexFieldType == Schema.DisplayType.DateTime) chartsFieldType = 'date'; 
			}
			else
			{
				if(label == 'Main') chartsFieldType = 'string';
				if(label == 'End') chartsFieldType = 'date'; 
			}
			ERGGoogleChartsTimelineSeq.Column newColumn = new ERGGoogleChartsTimelineSeq.Column();
			newColumn.type = chartsFieldType; 
			newColumn.name = label; 
			columns.add(newColumn);
		}
		
		nextStartDate = startDate;
		nextPhaseLabel = firstPhaseLabel;
		principalColumnValue = mainColumnValue;
		
		for(SObject pObject: pObjects)
		{
			ERGGoogleChartsTimelineSeq.Row newRow = new ERGGoogleChartsTimelineSeq.Row();

			for(String label: columnLabelToField.keySet())
			{

				if(label == 'Main')
				{
					ERGGoogleChartsTimelineSeq.DataPoint newDataPoint = new ERGGoogleChartsTimelineSeq.DataPoint(); 
					newDataPoint.type = 'string';
					newDataPoint.value = principalColumnValue;
					newrow.dataPoints.add(newDataPoint);
				}
				else if(label == 'Label')
				{
					ERGGoogleChartsTimelineSeq.DataPoint newDataPoint = new ERGGoogleChartsTimelineSeq.DataPoint(); 
					newDataPoint.type = 'string';
					newDataPoint.value = nextPhaseLabel;
					newrow.dataPoints.add(newDataPoint);
				}
				else if(label == 'Start')
				{
					ERGGoogleChartsTimelineSeq.DataPoint newDataPoint = new ERGGoogleChartsTimelineSeq.DataPoint(); 
					newDataPoint.type = 'date';
					newDataPoint.value = String.valueOf(nextStartDate);
					newrow.dataPoints.add(newDataPoint);
					
					nextEndDate = (Date) pObject.get(columnLabelToField.get('Start'));
				}
				else if(label == 'End')
				{
					String chartsFieldType = 'date';
                    Date thisEndDate = nextEndDate;
					ERGGoogleChartsTimelineSeq.DataPoint newDataPoint = new ERGGoogleChartsTimelineSeq.DataPoint(); 
					newDataPoint.type = chartsFieldType; 
					newDataPoint.value = String.valueOf(thisEndDate); 
					newrow.dataPoints.add(newDataPoint);
					nextStartDate = thisEndDate;
					nextPhaseLabel = (String) pObject.get(columnLabelToField.get('Label'));
			    }
			}
			
			rows.add(newRow);
		}
		
		/// Add Final Item
		ERGGoogleChartsTimelineSeq.Row newRow = new ERGGoogleChartsTimelineSeq.Row();
		ERGGoogleChartsTimelineSeq.DataPoint newDataPoint = new ERGGoogleChartsTimelineSeq.DataPoint(); 
		newDataPoint.type = 'string';
		newDataPoint.value = principalColumnValue;
		newrow.dataPoints.add(newDataPoint);
		newDataPoint = new ERGGoogleChartsTimelineSeq.DataPoint();
		newDataPoint.type = 'string';
		newDataPoint.value = nextPhaseLabel;
		newrow.dataPoints.add(newDataPoint);
		newDataPoint = new ERGGoogleChartsTimelineSeq.DataPoint(); 
		newDataPoint.type = 'date';
		newDataPoint.value = String.valueOf(nextStartDate);
		newrow.dataPoints.add(newDataPoint);
		newDataPoint = new ERGGoogleChartsTimelineSeq.DataPoint(); 
		newDataPoint.type = 'date';
		Date lastEndDate = System.today() > nextStartDate ? System.today() : nextStartDate;
		newDataPoint.value = String.valueOf(lastEndDate);
		newrow.dataPoints.add(newDataPoint);
		
		rows.add(newRow);
	}

	public class Column{
		public String type {get; set;}
		public String name {get; set;}
	}

	public class DataPoint{
		public String type {get; set;}
		public String value {get; set;}
	}

	public class Row{
		public List<ERGGoogleChartsTimelineSeq.DataPoint> dataPoints {get; set;}

		public Row()
		{
			dataPoints = new List<ERGGoogleChartsTimelineSeq.DataPoint>();
		}
	}

}