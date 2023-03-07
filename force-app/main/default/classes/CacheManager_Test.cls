@IsTest 
global class CacheManager_Test {
    /*
        Add to test methods:
        Map<String, Boolean> contains(Set<String> keys);
        Boolean containsAll(Set<String> keys);
        Boolean containsSome(Set<String> keys);
        Map<String, Object> get(Set<String> keys);
        Map<String, Object> getAll();
        Set<String> getKeys();
        Partition put(Map<String, Object> valueMap);
        Partition remove(Set<String> keys);
        Partition removeAll();
    */

    @IsTest 
    static void shouldInteractWithDefaultOrgCache() {
        String key = 'foo';
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
        String key = 'foo';
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
        String key = 'foo';
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
        String partitionName = 'NonExistentPartition';
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
        String partitionName = 'NonExistentPartition';
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
        String partitionName = 'NonExistentPartition';
        CacheManager.CacheType cacheType = CacheManager.CacheType.TRANSACTIONAL; 

        Test.startTest();
        CacheManager.Partition partition = CacheManager.getPartition(cacheType, partitionName); 
        Test.stopTest();

        // Since surely a partition doesn't *actually* exist with this name, should default to TransactionCache
        System.assertNotEquals(null, partition, 'Null partition returned');
        System.assertEquals(CacheManager.TransactionCache.class, TypeUtils.getType(partition), 'Wrong partition type returned');
    }

    @IsTest 
    static void shouldMockPlatformCache() {
        CacheManager.Division mockDivision = new MockPlatformCache(); 
        // This mock division type will always no-op
        CacheManager.CacheType cacheType = CacheManager.CacheType.ORG; 
        CacheManager.DIVISIONS_BY_TYPE?.put(cacheType, mockDivision);
        String key = 'foo';
        Object value = 'bar';

        Test.startTest();
        CacheManager.Division division = CacheManager.getDivision(cacheType); 
        System.assertEquals(MockPlatformCache.class, TypeUtils.getType(division), 'Wrong Division type');
        System.assertEquals(false, division?.contains(key), 'Mock division contains a key');
        System.assertEquals(null, division?.get(key), 'Mock division did not return null for missing key');
        // Mock divisions put/remove methods are no-op
        division?.put(key, value); 
        System.assertEquals(false, division?.contains(key), 'Mock division contains a key');
        System.assertEquals(null, division?.get(key), 'Mock division did not return null for missing key');
        division?.remove(key);
        System.assertEquals(false, division?.contains(key), 'Mock division contains a key');
        System.assertEquals(null, division?.get(key), 'Mock division did not return null for missing key');
    }

    @IsTest 
    static void shouldFallbackToTransactionCache() {
        CacheManager.Division mockDivision = new InvalidCache();
        // This mock division will always throw an exception, 
        // This exception will be caught & resolved via Transaction cache
        CacheManager.CacheType cacheType = CacheManager.CacheType.ORG; 
        CacheManager.DIVISIONS_BY_TYPE?.put(cacheType, mockDivision);
        
        Test.startTest();
        CacheManager.Division division = CacheManager.getDivision(cacheType); 
        System.assertEquals(InvalidCache.class, TypeUtils.getType(division), 'Wrong Division type');
        CacheManager.Partition partition = division?.getDefault();
        System.assertEquals(CacheManager.TransactionCache.class, TypeUtils.getType(partition), 'Wrong Partition');
        Test.stopTest();
    }

    @IsTest 
    static void shouldHandleNullValuesInOrgCache() {
        CacheManager.CacheType cacheType = CacheManager.CacheType.ORG;
        String key = 'foo';
        Object value = null;

        Test.startTest();
        try {
            CacheManager.getDivision(cacheType)?.put(key, value);
        } catch (Exception error) {
            System.assert(false, 'An error was thrown during cache.put(): ' + error);
        }
        try {
            Object result = CacheManager.getDivision(cacheType)?.get(key); 
            System.assertEquals(null, result, 'Null cache value did not return null');
        } catch (Exception error) {
            System.assert(false, 'An error was thrown during cache.get(): ' + error);
        }
        Test.stopTest();
    }

    @IsTest 
    static void shouldHandleNullValuesInSessionCache() {
        CacheManager.CacheType cacheType = CacheManager.CacheType.SESSION;
        String key = 'foo';
        Object value = null;

        Test.startTest();
        try {
            CacheManager.getDivision(cacheType)?.put(key, value);
        } catch (Exception error) {
            System.assert(false, 'An error was thrown during cache.put(): ' + error);
        }
        try {
            Object result = CacheManager.getDivision(cacheType)?.get(key); 
            System.assertEquals(null, result, 'Null cache value did not return null');
        } catch (Exception error) {
            System.assert(false, 'An error was thrown during cache.get(): ' + error);
        }
        Test.stopTest();
    }

    @IsTest 
    static void shouldHandleNullValuesInTransactionCache() {
        CacheManager.CacheType cacheType = CacheManager.CacheType.TRANSACTIONAL;
        String key = 'foo';
        Object value = null;

        Test.startTest();
        try {
            CacheManager.getDivision(cacheType)?.put(key, value);
        } catch (Exception error) {
            System.assert(false, 'An error was thrown during cache.put(): ' + error);
        }
        try {
            Object result = CacheManager.getDivision(cacheType)?.get(key); 
            System.assertEquals(null, result, 'Null cache value did not return null');
        } catch (Exception error) {
            System.assert(false, 'An error was thrown during cache.get(): ' + error);
        }
        Test.stopTest();
    }

    // **** INNER **** //
    global virtual class MockPlatformCache extends CacheManager.PlatformCache {
        global override Cache.Partition getUnderlyingPartition(String partitionName) {
            return null;
        }

        global override String getDefaultPartitionName() {
            return 'My_Cache_Partition';
        }
        
        global override CacheManager.Partition getFallbackCache() {
            return new PlatformPartition(null); 
        }
    }

    global virtual class InvalidCache extends CacheManager.PlatformCache {
        global override Cache.Partition getUnderlyingPartition(String partitionName) {
            throw new Cache.Org.OrgCacheException();
        }

        global override String getDefaultPartitionName() {
            throw new Cache.Org.OrgCacheException();
        }
    }
}