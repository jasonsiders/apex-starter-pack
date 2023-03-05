@IsTest 
private class CacheManager_Test {
    @IsTest 
    static void shouldInteractWithDefaultOrgCache() {
        String key = 'CacheManager_Test: foo';
        Object value = 'bar';
        CacheManager.CacheType cacheType = CacheManager.CacheType.ORG;
        CacheManager.Partition partition = CacheManager.getPartition(cacheType);
        System.debug(cacheType + ' is a ' + TypeUtils.getTypeName(partition));

        Test.startTest();
        System.assertEquals(false, partition?.contains(key), 'Partition already contains key');
        System.assertEquals(null, partition?.get(key), 'get(): non-existent key did not return null');
        partition?.put(key, value);
        System.assertEquals(true, partition?.contains(key), 'Key was not added');
        System.assertEquals(value, partition?.get(key), 'Wrong value for key');
        partition?.remove(key);
        System.assertEquals(false, partition?.contains(key), 'Key was not removed');
        Test.stopTest();
    }

    @IsTest 
    static void shouldInteractWithDefaultSessionCache() {
        String key = 'CacheManager_Test: foo';
        Object value = 'bar';
        CacheManager.CacheType cacheType = CacheManager.CacheType.SESSION;
        CacheManager.Partition partition = CacheManager.getPartition(cacheType);
        System.debug(cacheType + ' is a ' + TypeUtils.getTypeName(partition));

        Test.startTest();
        System.assertEquals(false, partition?.contains(key), 'Partition already contains key');
        System.assertEquals(null, partition?.get(key), 'get(): non-existent key did not return null');
        partition?.put(key, value);
        System.assertEquals(true, partition?.contains(key), 'Key was not added');
        System.assertEquals(value, partition?.get(key), 'Wrong value for key');
        partition?.remove(key);
        System.assertEquals(false, partition?.contains(key), 'Key was not removed');
        Test.stopTest();
    }

    @IsTest 
    static void shouldInteractWithDefaultTransactionCache() {
        String key = 'CacheManager_Test: foo';
        Object value = 'bar';
        CacheManager.CacheType cacheType = CacheManager.CacheType.TRANSACTIONAL;
        CacheManager.Partition partition = CacheManager.getPartition(cacheType);
        System.debug(cacheType + ' is a ' + TypeUtils.getTypeName(partition));

        Test.startTest();
        System.assertEquals(false, partition?.contains(key), 'Partition already contains key');
        System.assertEquals(null, partition?.get(key), 'get(): non-existent key did not return null');
        partition?.put(key, value);
        System.assertEquals(true, partition?.contains(key), 'Key was not added');
        System.assertEquals(value, partition?.get(key), 'Wrong value for key');
        partition?.remove(key);
        System.assertEquals(false, partition?.contains(key), 'Key was not removed');
        Test.stopTest();
    }

    @IsTest 
    static void shouldHandleMissingOrgPartition() {
        String partitionName = 'Non-existing partition blah blah blah';
        CacheManager.CacheType cacheType = CacheManager.CacheType.ORG; 

        Test.startTest();
        CacheManager.Partition partition = CacheManager.getPartition(cacheType, partitionName); 
        Test.stopTest();

        // Since surely a partition doesn't *actually* exist with this name, should default to TransactionCache
        System.assertNotEquals(null, partition, 'Null partition returned');
        System.assertEquals(CacheManager.TransactionCache.class, TypeUtils.getType(partition), 'Wrong partition type returned');
    }

    @IsTest 
    static void shouldHandleMissingSessionPartition() {
        String partitionName = 'Non-existing partition blah blah blah';
        CacheManager.CacheType cacheType = CacheManager.CacheType.SESSION; 

        Test.startTest();
        CacheManager.Partition partition = CacheManager.getPartition(cacheType, partitionName); 
        Test.stopTest();

        // Since surely a partition doesn't *actually* exist with this name, should default to TransactionCache
        System.assertNotEquals(null, partition, 'Null partition returned');
        System.assertEquals(CacheManager.TransactionCache.class, TypeUtils.getType(partition), 'Wrong partition type returned');
    }

    @IsTest 
    static void shouldHandleMissingTransactionPartition() {
        String partitionName = 'Non-existing partition blah blah blah';
        CacheManager.CacheType cacheType = CacheManager.CacheType.TRANSACTIONAL; 

        Test.startTest();
        CacheManager.Partition partition = CacheManager.getPartition(cacheType, partitionName); 
        Test.stopTest();

        // Since surely a partition doesn't *actually* exist with this name, should default to TransactionCache
        System.assertNotEquals(null, partition, 'Null partition returned');
        System.assertEquals(CacheManager.TransactionCache.class, TypeUtils.getType(partition), 'Wrong partition type returned');
    }

    @IsTest 
    static void shouldInteractWithPlatformPartitions() {
        // This is mostly for test coverage. If Org/Session cache is not enabled in an org, will fallback to TransactionCache
        Boolean isEnabled = true; 
        Cache.Partition cachePartition;
        try {
            String partitionName = Cache.Org.getName(); 
            cachePartition = Cache.Org.getPartition(partitionName);
        } catch (Exception error) {
            // Cache doesn't exist - will affect our asserts later
            isEnabled = false;
        }
        CacheManager.PlatformPartition partition = new CacheManager.PlatformPartition(cachePartition);
        String key = 'CacheManager_Test.foo';
        Object value = Crypto.getRandomInteger();
        
        Test.startTest();
        System.assertEquals(false, partition?.contains(key), 'Unmapped key already exists in partition');
        partition?.put(key, value);
        Object cachedValue = partition?.get(key);
        if (isEnabled) {
            System.assertEquals(value, cachedValue, 'Incorrect cached value'); 
        }
        partition?.remove(key);
        System.assertEquals(false, partition?.contains(key), 'Removed key still exists in partition');
        Test.stopTest();
    }
}