@IsTest
global class CacheManager_Test {
    @IsTest
    static void shouldInteractWithOrgCache() {
        CacheManager.Partition partition = CacheManager.getOrgCache()?.getDefault();
        CacheManager_Test.interactWithCache(partition);
    }

    @IsTest
    static void shouldInteractWithSessionCache() {
        CacheManager.Partition partition = CacheManager.getSessionCache()?.getDefault();
        CacheManager_Test.interactWithCache(partition);
    }

    @IsTest
    static void shouldInteractWithTransactionCache() {
        CacheManager.Partition partition = CacheManager.getTransactionCache()?.getDefault();
        CacheManager_Test.interactWithCache(partition);
    }

    @IsTest
    static void shouldInteractWithOrgDivision() {
        // Developers can call partition methods on the division itself - it will point to its default partition
        CacheManager.CacheDivision division = CacheManager.getOrgCache();
        CacheManager_Test.interactWithCache(division);
    }

    @IsTest
    static void shouldInteractWithSessionDivision() {
        // Developers can call partition methods on the division itself - it will point to its default partition
        CacheManager.CacheDivision division = CacheManager.getSessionCache();
        CacheManager_Test.interactWithCache(division);
    }

    @IsTest
    static void shouldInteractWithTransactionDivision() {
        // Developers can call partition methods on the division itself - it will point to its default partition
        CacheManager.CacheDivision division = CacheManager.getTransactionCache();
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
        CacheManager.Partition partition = CacheManager.getCache(cacheType)?.getDefault();
        Test.stopTest();

        System.assertEquals(true, partition instanceof CacheManager.TransactionCache, 'Did not return fallback cache: ' + partition);
    }

    @IsTest
    static void shouldInteractWithPlatformPartition() {
        // Mostly for test coverage in orgs that do not have platform cache enabled
        CacheManager.PlatformPartition partition = new CacheManager.PlatformPartition(null);
        String key = 'foo';
        Object value = 'bar';
        CacheManager_Test.interactWithCache(partition);
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
        System.debug('Partition is a ' + TypeUtils.getTypeName(partition)); 
        Map<String, Object> cacheMap = new Map<String, Object>{
            'foo' => 'bar',
            'abcd' => 1234,
            'today' => Date.today()
        };

        Test.startTest();
        // Without any prior interaction, contains()/get() methods should not return values
        CacheManager_Test.assertNotContains(partition, cacheMap);
        // Test bulk put methods
        partition?.put(cacheMap); 
        // Re-test contains()/get() methods; should return values
        CacheManager_Test.assertContains(partition, cacheMap); 
        // Test bulk remove() methods
        partition?.removeAll();
        // Re-test contains()/get() methods; should not return values
        CacheManager_Test.assertNotContains(partition, cacheMap);
        // Test single put() methods w/ttl
        for (String key : cacheMap?.keySet()) {
            Object value = cacheMap?.get(key);
            partition?.put(key, value, 60); 
            System.assertEquals(true, partition?.containsSome(cacheMap?.keySet()), 'Unexpected containsSome(Set<String>) value'); 
        }
        // Re-test contains()/get() methods; should return values
        CacheManager_Test.assertContains(partition, cacheMap); 
        // Test single remove() methods
        for (String key : cacheMap?.keySet()) {
            partition?.remove(key);
        }
        // Re-test contains()/get() methods; should not return values
        CacheManager_Test.assertNotContains(partition, cacheMap);
        // Test single put() methods
        for (String key : cacheMap?.keySet()) {
            Object value = cacheMap?.get(key);
            partition?.put(key, value); 
            System.assertEquals(true, partition?.containsSome(cacheMap?.keySet()), 'Unexpected containsSome(Set<String>) value'); 
        }
        // Re-test contains()/get() methods; should return values
        CacheManager_Test.assertContains(partition, cacheMap); 
        // Test single remove() methods
        for (String key : cacheMap?.keySet()) {
            partition?.remove(key);
        }
        // Re-test contains()/get() methods; should not return values
        CacheManager_Test.assertNotContains(partition, cacheMap);
        Test.stopTest();
    }

    static void assertNotContains(CacheManager.Partition partition, Map<String, Object> cacheMap) {
        System.assertEquals(false, partition?.containsAll(cacheMap?.keySet()), 'Unexpected containsAll(Set<String>) value');
        System.assertEquals(false, partition?.containsSome(cacheMap?.keySet()), 'Unexpected containsSome(Set<String>) value');
        for (String key : cacheMap?.keySet()) {
            System.assertEquals(false, partition?.contains(key), 'Unexpected contains(String) value');
        }
        Map<String, Boolean> containsResults = partition?.contains(cacheMap?.keySet());
        System.assertEquals(cacheMap?.keySet(), containsResults?.keySet(), 'Unexpected contains(Set<String>) keySet');
        System.assertEquals(cacheMap?.values()?.size(), containsResults?.values()?.size(), 'Unexpected # of contains(Set<String>) values');
        System.assertEquals(false, new Set<Boolean>(containsResults?.values())?.contains(true), 'contains(Set<String>) returned some true values');
        System.assertEquals(true, partition?.getAll()?.isEmpty(), 'Unexpected getAll() values');
        System.assertEquals(cacheMap?.keySet(), partition?.get(cacheMap?.keySet())?.keySet(), 'Unexpected get(Set<String>) keys');
        for (String key : cacheMap?.keySet()) {
            System.assertEquals(null, partition?.get(key), 'Unexpected get(String) value');
        }
        System.assertEquals(0, partition?.getKeys()?.size(), 'Unexpected # of getKeys() results');
    }

    static void assertContains(CacheManager.Partition partition, Map<String, Object> cacheMap) {
        System.assertEquals(true, partition?.containsAll(cacheMap?.keySet()), 'Unexpected containsAll(Set<String>) value');
        System.assertEquals(true, partition?.containsSome(cacheMap?.keySet()), 'Unexpected containsSome(Set<String>) value');
        for (String key : cacheMap?.keySet()) {
            System.assertEquals(true, partition?.contains(key), 'Unexpected contains(String) value');
        }
        Map<String, Boolean> containsResults = partition?.contains(cacheMap?.keySet());
        System.assertEquals(cacheMap?.keySet(), containsResults?.keySet(), 'Unexpected contains(Set<String>) keySet');
        System.assertEquals(cacheMap?.values()?.size(), containsResults?.values()?.size(), 'Unexpected # of contains(Set<String>) values');
        System.assertEquals(true, new Set<Boolean>(containsResults?.values())?.contains(true), 'contains(Set<String>) returned some true values');
        System.assertEquals(false, partition?.getAll()?.isEmpty(), 'Unexpected getAll() values');
        System.assertEquals(cacheMap?.keySet(), partition?.get(cacheMap?.keySet())?.keySet(), 'Unexpected get(Set<String>) keys');
        for (String key : cacheMap?.keySet()) {
            Object value = cacheMap?.get(key); 
            System.assertEquals(value, partition?.get(key), 'Unexpected get(String) value');
        }
        System.assertEquals(cacheMap?.keySet()?.size(), partition?.getKeys()?.size(), 'Unexpected # of getKeys() results');
    }

    static void testMissingPartition(CacheManager.CacheType cacheType) {
        String fakePartitionName = 'blahblahblahblah1234';

        Test.startTest();
        CacheManager.Partition partition = CacheManager.getCache(cacheType)?.getPartition(fakePartitionName);
        Test.stopTest();

        System.assertEquals(true, partition instanceof CacheManager.TransactionCache, 'Did not fallback to transaction cache');
    }

    global class MockPlatformCache extends CacheManager.PlatformCache {
        private MockPlatformCache(CacheManager.CacheType cacheType) {
            super(cacheType);
        }
    }

    global class InvalidPlatformCache extends CacheManager.PlatformCache {
        // Simulates a PlatformCache partition that has not been set up yet
        private InvalidPlatformCache(CacheManager.CacheType cacheType) {
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
