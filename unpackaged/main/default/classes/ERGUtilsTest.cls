@isTest
public class ERGUtilsTest {
	
	@isTest
	private static void should_get_sobject_name()
	{
		Account theAccount = new Account(); 
		System.assertEquals('Account', ERGUtils.getSObjectName(theAccount)); 
		System.assertEquals('Account', ERGUtils.getSObjectName(Account.SObjectType)); 
	}

	@isTest
	private static void should_get_fields_for_query()
	{
		System.assert(ERGUtils.accessibleFieldNamesForQuery('Contact').containsIgnoreCase('LastName'));
		System.assert(ERGUtils.updateableFieldNamesForQuery('Contact').containsIgnoreCase('LastName')); 
		System.assert(ERGUtils.allFieldNamesForQuery('Contact').containsIgnoreCase('LastName'));
		System.assert(!ERGUtils.updateableFieldNamesForQuery('Contact').containsIgnoreCase('CreatedDate')); 
	}

	@isTest
	private static void should_get_field_label()
	{
		System.assertEquals('Apellidos', ERGUtils.getFieldLabel(Contact.SObjectType, 'LastName'));
	}

	@isTest
	private static void should_get_field_type()
	{
		System.assertEquals(Schema.DisplayType.String , ERGUtils.getFieldType(Contact.SObjectType, 'LastName'));
	}
}