public with sharing class ERGUtils {
	
	// ---- SObjects INFORMATION  ---- // 

    public static String getSObjectName(sObject theObject)
    {
        return theObject.getSObjectType().getDescribe().getName();
    }

    public static String getSObjectName(SObjectType theType)
    {
    	return theType.getDescribe().getName();
    }

    // --- Record Type Tools --- // 
/*
    public static Id getRecordTypeId(String pSObjectName, String pDeveloperName)
    {
        RecordType theRecordType; 
        try
        {
            theRecordType = [SELECT Id FROM RecordType WHERE sObjectType =: pSObjectName AND DeveloperName =: pDeveloperName LIMIT 1];
        }
        catch (Exception e)
        {
            return null;
        }

        return theRecordType.Id;
    }
*/
    // --- Query Tools --- //

    public static String updateableFieldNamesForQuery(String ObjectName)
    {

        Map<String,Schema.SObjectField> allFieldsMap = ERGUtils.getFieldsMap(ObjectName);
        System.debug(':::allFieldsMap: '+allFieldsMap); 

        if(allFieldsMap == null) return null;


        Integer fieldCount = 0;
        String result = '';
        for(String fieldName: allFieldsMap.keySet())
        {
            if(allFieldsMap.get(fieldName).getDescribe().isUpdateable())
            {
                 if(fieldCount > 0)
                    result += ', ';
                result += fieldName;
                fieldCount++;
            }
        }
        
        return result; 
    } 

    public static String accessibleFieldNamesForQuery(String ObjectName)
    {

        Map<String,Schema.SObjectField> allFieldsMap = ERGUtils.getFieldsMap(ObjectName);
        System.debug(':::allFieldsMap: '+allFieldsMap); 

        if(allFieldsMap == null) return null;


        Integer fieldCount = 0;
        String result = '';
        for(String fieldName: allFieldsMap.keySet())
        {
            if(allFieldsMap.get(fieldName).getDescribe().isAccessible())
            {
                 if(fieldCount > 0)
                    result += ', ';
                result += fieldName;
                fieldCount++;
            }
        }
        
        return result; 
    } 

    public static String allFieldNamesForQuery(String ObjectName)
    {

        Map<String,Schema.SObjectField> allFieldsMap = ERGUtils.getFieldsMap(ObjectName);
        System.debug(':::allFieldsMap: '+allFieldsMap); 

        if(allFieldsMap == null) return null;

        Integer fieldCount = 0;
        String result = '';
        for(String fieldName: allFieldsMap.keySet())
        {
            if(fieldCount > 0)
                result += ', ';
            result += fieldName;
            fieldCount++;
        }
        
        return result; 
    } 


    public static Map<String,Schema.SObjectField> getFieldsMap(String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        
        if(SObjectTypeObj == null) return null;
        
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Map<String,Schema.SObjectField> allFieldsMap = DescribeSObjectResultObj.fields.getMap();

        return allFieldsMap;
    }

    // --- Fields Tools --- //

    public static String getFieldLabel(sObjectType type, String fieldName)
    {
        try
        {
            Map<String, Schema.SObjectField> fieldMap = type.getDescribe().fields.getMap(); 
            return fieldMap.get(fieldName).getDescribe().getLabel();
        } catch(Exception e)
        {
            System.debug('Could not fiend field Label for: '+type+' - '+fieldName); 
        }
        return ''; 
    }

    public static Schema.DisplayType getFieldType(SObjectType theType, String pField)
    {
        Map<String, Schema.SObjectField> M = theType.getDescribe().fields.getMap();
        Schema.SObjectField field = M.get(pField);
        Schema.DisplayType FldType = field.getDescribe().getType();
        return FldType;
    }
/*
    public static List<String> allFieldNames(String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        
        if(SObjectTypeObj == null) return null;
        
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Map<String,Schema.SObjectField> allFieldsMap = DescribeSObjectResultObj.fields.getMap();

        if(allFieldsMap == null) return null;

        List<String> updateableFields = new List<String>(); 

        for(String fieldName: allFieldsMap.keySet())
        {
            updateableFields.add(fieldName);

        }
        
        return updateableFields; 
    }

    // ---- APPROVAL PROCESSES ---- // 

    public static Set<String> getIdsWithNoComments(Set<ID> records)
    {
        Set<String> noComments = new Set<String>();

        for(ProcessInstance pi: [SELECT TargetObjectId,
                                   (SELECT Id, StepStatus, Comments 
                                    FROM Steps
                                    WHERE StepStatus = 'Rejected'
                                    ORDER BY CreatedDate DESC
                                    LIMIT 1)
                               FROM ProcessInstance
                               WHERE TargetObjectId IN :records
                               ORDER BY CreatedDate DESC])
        {
            System.debug(pi);
            
            try {
                if(pi != null)
                if(pi.Steps[0] != null) 
                if ((pi.Steps[0].Comments == null || 
                    pi.Steps[0].Comments.trim().length() == 0))
                  {
                    noComments.add(pi.TargetObjectId);
                  }
            }
            catch(Exception e)
            {
                System.debug('Error getting if approval process has comments');
            }
        }

        return noComments;
    }

    public static Boolean havePendingApprovalProcesses(Set<ID> recordsIds)
    {
        List<ProcessInstance> approvalProcesses = [SELECT TargetObjectId,
                                   (SELECT Id, StepStatus, Comments 
                                    FROM Steps
                                    WHERE StepStatus = 'Pending'
                                    ORDER BY CreatedDate DESC
                                    LIMIT 1)
                               FROM ProcessInstance
                               WHERE TargetObjectId IN :recordsIds
                               ORDER BY CreatedDate DESC]; 

        return (approvalProcesses != null && !approvalProcesses.isEmpty()); 

    }

    public static Map<ID,ID> getMapofRecordAndApproverId(Set<ID> records)
    {
        Map<ID,ID> recordIdToApproverIdmap = new Map<ID,ID>();
        for(ProcessInstance pi: [SELECT TargetObjectId, LastActorId
                               FROM ProcessInstance
                               WHERE TargetObjectId IN :records
                               ORDER BY CreatedDate DESC])
        {
            recordIdToApproverIdmap.put(pi.TargetObjectId, pi.LastActorId);
        }

        return recordIdToApproverIdmap;
    }

    public static Approval.ProcessResult submitRequestForApproval(Id objectId, String comments)
    {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
        req.setObjectId(objectId);
        req.setComments(comments);
        Approval.ProcessResult result = Approval.process(req);
        return result;
    }

    public static Approval.ProcessResult processApprovalRequest(Id requestObjectId, String processInstanceStatus, String action, String comments)
    {
        List<ProcessInstanceWorkItem> existingApprovals = [SELECT Id,OriginalActorId
                                            FROM ProcessInstanceWorkItem 
                                            WHERE ProcessInstance.TargetObjectId = :requestObjectId
                                            AND ProcessInstance.Status = :processInstanceStatus];
        
        Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
        testRej.setAction(action);
        testRej.setComments(comments); 
        testRej.setWorkitemId(existingApprovals[0].Id);


        return Approval.process(testRej);
    }

    public static List<ProcessInstanceWorkItem> getAllPendingApprovalsForObject(String pObjectId)
    {
        List<ProcessInstanceWorkItem> existingApprovals = [SELECT Id,OriginalActorId
                                            FROM ProcessInstanceWorkItem 
                                            WHERE ProcessInstance.TargetObjectId = :pObjectId
                                            AND ProcessInstance.Status = 'Pending'];
        return existingApprovals;
    }

    // --- USER INFORMATION --- // 


    public static Boolean userIsAdmin()
    {
        Boolean isAdmin = false;
        Id userId = UserInfo.getUserId();
        User loggedInUser;  
        try {
            loggedInUser = [SELECT Profile.Name, ProfileId FROM User WHERE Id =: userId];
            if(loggedInUser.Profile.Name.contains('Administrator'))
                isAdmin = true;
        } catch(Exception e)
        {
            System.debug('Problem obtaining user profile.');
        }
        return isAdmin;
    }

    public static String getUserName(Id userId)
    {
        User theUser; 
        String theName = ''; 
        try {
            theUser = [SELECT FirstName, LastName FROM User WHERE Id =: userId]; 
            theName = theUser.FirstName + ' ' + theUser.LastName; 
        } catch(Exception e)
        {
            System.debug('Invalid User ID submitted: '+userId); 
        }
        return theName; 
    }

    // --- ATTACHMENTS AND NOTES PROCESSES --- // 

    public static void copyAttachments(String sourceId, String destinationId)
    {
        List<Attachment> existingAttachments = [SELECT Id, Name, Description, ContentType, Body FROM Attachment WHERE parentId =:  sourceId];
        if(existingAttachments == null || existingAttachments.isEmpty()) return;

        List<Attachment> attachmentsToInsert = new List<Attachment>();
        
        for(Attachment a: existingAttachments)
        {
            Attachment newAttachment = new Attachment();
            newAttachment.Name = a.Name;
            newAttachment.Description = a.Description;
            newAttachment.ContentType = a.ContentType; 
            newAttachment.Body = a.Body; 
            newAttachment.ParentId = destinationId;
            attachmentsToInsert.add(newAttachment);
        }

        try{
            if(!attachmentsToInsert.isEmpty())
                insert attachmentsToInsert;
        } catch (Exception e)
        {
            System.debug('Problem copying attachments: '+e.getMessage());
        }
    }

    public static void copyNotes(String sourceId, String destinationId)
    {
        List<Note> existingNotes = [SELECT Id, Title, Body FROM Note WHERE parentId =:  sourceId];
        if(existingNotes == null || existingNotes.isEmpty()) return;

        List<Note> notesToInsert = new List<Note>();
        
        for(Note a: existingNotes)
        {
            Note newNote = new Note();
            newNote.Title = a.Title;
            newNote.Body = a.Body;
            newNote.ParentId = destinationId;
            notesToInsert.add(newNote);
        }

        try{
            if(!notesToInsert.isEmpty())
                insert notesToInsert;
        } catch (Exception e)
        {
            System.debug('Problem copying attachments: '+e.getMessage());
        }
    }

    // --- DATE MENTHODS --- // 
    public static String formatDateForQuery(Date pDate)
    {
        String response = ''; 
        if(pDate != null)
        {
            String monthZero = ''; 
            String dayZero = ''; 
            if(pDate.month() < 10) monthZero = '0';
            if(pDate.day() < 10) dayZero = '0';
            response = pDate.year()+'-'+monthZero+pDate.month()+'-'+dayZero+pDate.day(); 
        }
        return response;
    }
   
    // ---- STRING METHODS --- // 

    public static Boolean stringHasData(String pString)
    {
        if(pString != null && pString != '' && pString.length() > 1)
        {
            return true; 
        }

        return false;
    }

    public static Boolean stringsHaveData(List<String> pStrings)
    {
        for(String search: pStrings)
        {
            if(ERGUtils.stringHasData(search)) return true;
        }
        return false; 
    }


    // ----- FIELSETS TOOLS --- // 

    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        
        if(SObjectTypeObj == null) return null;
        
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        
        if(fieldSetObj == null) return null;
        
        return fieldSetObj.getFields(); 
    }   

    public static String getFieldsNames(String fieldSet, String ObjectName)
    {
        String result = '';
        Integer fieldCount = 0;
        List<Schema.FieldSetMember> fieldSetMemberList =  ERGUtils.readFieldSet(fieldSet, ObjectName);
        if(fieldSetMemberList != null)
        {
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
            {
                if(fieldCount > 0)
                    result += ', ';
                result += fieldSetMemberObj.getFieldPath(); 
                fieldCount++;
            }
        }
        return result;
    }

    public static Set<String> getFieldsNamesSet(String fieldSet, String ObjectName)
    {
        String result = '';
        Integer fieldCount = 0;
        Set<String> fieldNames = new Set<String>();
        List<Schema.FieldSetMember> fieldSetMemberList =  ERGUtils.readFieldSet(fieldSet, ObjectName);
        if(fieldSetMemberList != null)
        {
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
            {
                fieldNames.add(fieldSetMemberObj.getFieldPath());
            }
        }
        return fieldNames;
    }

    public static Set<String> getAllFieldsInFieldSets(Set<String> fieldSets, String ObjectName)
    {
        if(ObjectName == null) return null; 
        if(fieldSets == null || fieldSets.isEmpty()) return null; 
        Set<String> allFields = new Set<String>(); 
        for(String fieldSet: fieldSets)
        {
            allFields.addAll(ERGUtils.getFieldsNamesSet(fieldSet, ObjectName)); 
        }
        return allFields;
    }

    public static Set<String> getAllFieldSetNames(String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        
        if(SObjectTypeObj == null) return null;
        
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Map<String, Schema.FieldSet> FsMap = DescribeSObjectResultObj.FieldSets.getMap();
        
        if (FsMap == null) return null;
        
        return FsMap.keySet();
    }
    
    public static Map<String,String> getFieldSetNamesAndDescriptions(String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        
        if(SObjectTypeObj == null) return null;
        
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Map<String, Schema.FieldSet> FsMap = DescribeSObjectResultObj.FieldSets.getMap();
        
        if (FsMap == null) return null;
        
        Map<String,String> result = new Map<String,String>();
        for(String key: FsMap.keySet())
        {
            String description = FsMap.get(key).getDescription();
            result.put(key,description);
        }
        
        return result;
    }

    // ---- Picklist Tools --- // 

    public static List<String> getPicklistValues(String sObjectName, String fieldName)
    {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName); 
        Schema.SObjectField fieldType = objectType.getDescribe().fields.getMap().get(fieldName); 
        List<String> picklistOptions = new List<String>(); 

        Schema.DescribeFieldResult fieldResult = fieldType.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f: ple)
        {
            picklistOptions.add(f.getValue());
        }

        return picklistOptions;
    }

    // ---- CRUD Security Methods ----- // 

    public static Boolean isAccessible(SObjectType theType)
    {
        return theType.getDescribe().isAccessible(); 
    }

    public static Boolean isCreateable(SObjectType theType)
    {
        return theType.getDescribe().isCreateable(); 
    }

    public static Boolean isUpdateable(SObjectType theType)
    {
        return theType.getDescribe().isUpdateable(); 
    }

    public static Boolean isDeletable(SObjectType theType)
    {
        return theType.getDescribe().isDeletable(); 
    }
*/
}