@IsTest 
private class Caches_Test {
    @IsTest 
    static void shouldInteractWithOrgCache() {
        String cacheKey = 'My ID';
        Object cacheValue = UserInfo.getUserId(); 
        Caches.Partition myCache = Caches.getPartition(Caches.CacheType.ORG, 'MyPartition');

        System.assertEquals(false, myCache?.contains(cacheKey), 'Cache was already set?'); 
        myCache?.put(cacheKey, cacheValue); 
        System.assertEquals(true, myCache?.contains(cacheKey), 'Cache was not set'); 
        System.assertEquals(cacheValue, myCache?.get(cacheKey), 'Wrong cache value');
        myCache?.remove(cacheKey); 
        System.assertEquals(false, myCache?.contains(cacheKey), 'Cache key was not removed');
    }

    @IsTest 
    static void shouldInteractWithSessionCache() {
        String cacheKey = 'My ID';
        Object cacheValue = UserInfo.getUserId(); 
        Caches.Partition myCache = Caches.getPartition(Caches.CacheType.SESSION, 'MyPartition');

        System.assertEquals(false, myCache?.contains(cacheKey), 'Cache was already set?'); 
        myCache?.put(cacheKey, cacheValue); 
        System.assertEquals(true, myCache?.contains(cacheKey), 'Cache was not set'); 
        System.assertEquals(cacheValue, myCache?.get(cacheKey), 'Wrong cache value');
        myCache?.remove(cacheKey); 
        System.assertEquals(false, myCache?.contains(cacheKey), 'Cache key was not removed');
    }

    @IsTest 
    static void shouldInteractWithTransactionalCache() {
        String cacheKey = 'My ID';
        Object cacheValue = UserInfo.getUserId(); 
        Caches.Partition myCache = Caches.getPartition(Caches.CacheType.TRANSACTIONAL, 'MyPartition'); 

        System.assertEquals(false, myCache?.contains(cacheKey), 'Cache was already set?'); 
        myCache?.put(cacheKey, cacheValue); 
        System.assertEquals(true, myCache?.contains(cacheKey), 'Cache was not set'); 
        System.assertEquals(cacheValue, myCache?.get(cacheKey), 'Wrong cache value');
        myCache?.remove(cacheKey); 
        System.assertEquals(false, myCache?.contains(cacheKey), 'Cache key was not removed');
    }
}