@IsTest
global class CacheManager_Test {
    @IsTest
    static void shouldInteractWithOrgCache() {
        CacheManager.CacheType cacheType = CacheManager.CacheType.ORG;
        CacheManager.Partition partition = CacheManager.getPartition(cacheType);
        CacheManager_Test.interactWithCache(partition);
    }

    @IsTest
    static void shouldInteractWithSessionCache() {
        CacheManager.CacheType cacheType = CacheManager.CacheType.SESSION;
        CacheManager.Partition partition = CacheManager.getPartition(cacheType);
        System.debug('partition: ' + partition);
        CacheManager_Test.interactWithCache(partition);
    }

    @IsTest
    static void shouldInteractWithTransactionCache() {
        CacheManager.CacheType cacheType = CacheManager.CacheType.TRANSACTIONAL;
        CacheManager.Partition partition = CacheManager.getPartition(cacheType);
        CacheManager_Test.interactWithCache(partition);
    }

    @IsTest
    static void shouldInteractWithOrgDivision() {
        // Developers can call partition methods on the division itself - it will point to its default partition
        CacheManager.CacheType cacheType = CacheManager.CacheType.ORG;
        CacheManager.Division division = CacheManager.getDivision(cacheType);
        CacheManager_Test.interactWithCache(division);
    }

    @IsTest
    static void shouldInteractWithSessionDivision() {
        // Developers can call partition methods on the division itself - it will point to its default partition
        CacheManager.CacheType cacheType = CacheManager.CacheType.SESSION;
        CacheManager.Division division = CacheManager.getDivision(cacheType);
        CacheManager_Test.interactWithCache(division);
    }

    @IsTest
    static void shouldInteractWithTransactionDivision() {
        // Developers can call partition methods on the division itself - it will point to its default partition
        CacheManager.CacheType cacheType = CacheManager.CacheType.TRANSACTIONAL;
        CacheManager.Division division = CacheManager.getDivision(cacheType);
        CacheManager_Test.interactWithCache(division);
    }

    @IsTest
    static void shouldHandleMissingOrgCache() {
        CacheManager.CacheType cacheType = CacheManager.CacheType.ORG;
        CacheManager_Test.testMissingPartition(cacheType);
    }

    @IsTest
    static void shouldHandleMissingSessionCache() {
        CacheManager.CacheType cacheType = CacheManager.CacheType.SESSION;
        CacheManager_Test.testMissingPartition(cacheType);
    }

    @IsTest
    static void shouldHandleMissingTransactionCache() {
        // Transaction cache doesn't have partitions per-se; just a single static map
        // Therefore, missing partitions should always return itself
        CacheManager.CacheType cacheType = CacheManager.CacheType.TRANSACTIONAL;
        CacheManager_Test.testMissingPartition(cacheType);
    }

    @IsTest
    static void shouldHandleMissingDefaultOrgCache() {
        // Load a mock unconfigured cache, since we can't control org configuration
        CacheManager.CacheType cacheType = CacheManager.CacheType.ORG;
        CacheManager.DIVISIONS_BY_TYPE.put(cacheType, new InvalidPlatformCache(cacheType));

        Test.startTest();
        // Get the default partition
        CacheManager.Partition partition = CacheManager.getPartition(cacheType);
        Test.stopTest();

        System.assertEquals(true, partition instanceof CacheManager.TransactionCache, 'Did not return fallback cache: ' + partition);
    }

    @IsTest
    static void shouldInteractWithPlatformPartition() {
        // Mostly for test coverage in orgs that do not have platform cache enabled
        CacheManager.PlatformPartition partition = new CacheManager.PlatformPartition(null);
        String key = 'foo';
        Object value = 'bar';

        Test.startTest();
        partition?.put(key, value);
        System.assertEquals(false, partition?.contains(key), 'Null partition contains key');
        System.assertEquals(null, partition?.get(key), 'Null partition contains value');
        partition?.remove(key);
        Test.stopTest();
    }

    @IsTest 
    static void shouldNotReturnProxyIfNull() {
        // Mostly for test coverage in orgs that do not have platform cache enabled
        MockPlatformCache platformCache = new MockPlatformCache(null); 

        Test.startTest();
        CacheManager.Partition partition = platformCache?.getPartition('SomePartition');
        Test.stopTest();

        System.assertEquals(true, partition instanceOf CacheManager.TransactionCache, 'Did not use fallback cache');
    }

    // **** HELPER **** //
    static void interactWithCache(CacheManager.Partition partition) {
        String key = 'abcd';
        Object value = 1234;

        Test.startTest();
        // Without any prior interaction, should not contain key
        System.assertEquals(false, partition?.contains(key), 'Unexpected contains() value');
        System.assertEquals(null, partition?.get(key), 'Unexpected get() value');
        // Add the key/value to the cache - should now be returned
        partition?.put(key, value);
        System.assertEquals(true, partition?.contains(key), 'Unexpected contains() value');
        System.assertEquals(value, partition?.get(key), 'Unexpected get() value');
        // Remove the key - should no longer contain
        partition?.remove(key);
        System.assertEquals(false, partition?.contains(key), 'Unexpected contains() value');
        System.assertEquals(null, partition?.get(key), 'Unexpected get() value');
        // Use the TTL param to customize the amount of time persisted in the cache
        partition?.put(key, value, 10);
        System.assertEquals(true, partition?.contains(key), 'Unexpected contains() value');
        Test.stopTest();
    }

    static void testMissingPartition(CacheManager.CacheType cacheType) {
        String fakePartitionName = 'blahblahblahblah1234';

        Test.startTest();
        CacheManager.Partition partition = CacheManager.getPartition(cacheType, fakePartitionName);
        Test.stopTest();

        System.assertEquals(true, partition instanceof CacheManager.TransactionCache, 'Did not fallback to transaction cache');
    }

    global class MockPlatformCache extends CacheManager.PlatformCache {
        global MockPlatformCache(CacheManager.CacheType cacheType) {
            super(cacheType);
        }
    }

    global class InvalidPlatformCache extends CacheManager.PlatformCache {
        // Simulates a PlatformCache partition that has not been set up yet
        global InvalidPlatformCache(CacheManager.CacheType cacheType) {
            super(cacheType);
        }

        global override CacheManager.Partition getPartition(String partitionName) {
            switch on this.cacheType {
                when ORG {
                    throw new Cache.Org.OrgCacheException();
                }
                when SESSION {
                    throw new Cache.Session.SessionCacheException();
                }
            }
            return this;
        }
    }
}
