@IsTest 
global class TestUtils {
    static Integer numIdsGenerated = 0; 

    global static Id generateFakeId(SObjectType objectType) {
        String prefix = Describes.getSObjectDescribe(objectType)?.getKeyPrefix();
        String suffix = String.valueOf(numIdsGenerated++);
        return prefix + '0'.repeat(15-suffix?.length()) + suffix; 
    }

    global static SObject generateFakeId(SObject record) {
        return generateFakeIds(new List<SObject>{record})[0];
    }

    global static List<SObject> generateFakeIds(List<SObject> records) {
        for (SObject record : records) {
            record.Id = (record?.Id != null) ? record?.Id : generateFakeId(record.getSObjectType()); 
        }
        return records;
    }
}