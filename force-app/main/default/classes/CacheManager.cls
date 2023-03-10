global abstract class CacheManager {
    // Note: Necessary because PlatformCache doesn't allow *actual* null values
    public static final String NULL_VALUE = '<<<NULL_CACHE_VALUE>>>';
    // Note: Cache tokens default to & can persist for a maximum of 24 hours/86400 seconds:
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_platform_cache_limits.htm
    public static final Integer DEFAULT_TTL_SECS = 86400;

    @TestVisible
    static final Map<CacheType, Cache> CACHE_BY_TYPE = new Map<CacheType, Cache>{
        CacheType.ORG => new PlatformCache(CacheType.ORG),
        CacheType.SESSION => new PlatformCache(CacheType.SESSION),
        CacheType.TRANSACTIONAL => new TransactionCache()
    };

    global static Cache getOrgCache() {
        return CacheManager.getCache(CacheType.ORG);
    }

    global static Cache getSessionCache() {
        return CacheManager.getCache(CacheType.SESSION);
    }

    global static Cache getTransactionCache() {
        return CacheManager.getCache(CacheType.TRANSACTIONAL);
    }
    
    global static Cache getCache(CacheType cacheType) {
        return CACHE_BY_TYPE?.get(cacheType);
    }

    // **** INNER **** //
    global enum CacheType {
        ORG,
        SESSION,
        TRANSACTIONAL
    }

    global interface Partition {
        Boolean contains(String key);
        Map<String, Boolean> contains(Set<String> keys);
        Boolean containsAll(Set<String> keys);
        Boolean containsSome(Set<String> keys);
        Object get(String key);
        Map<String, Object> get(Set<String> keys); 
        Map<String, Object> getAll();
        Set<String> getKeys();
        Partition put(String key, Object value);
        Partition put(Map<String, Object> keyValues);
        Partition put(String key, Object value, Integer ttlSecs);
        Partition put(Map<String, Object> keyValues, Integer ttlSecs); 
        Partition remove(String key);
        Partition remove(Set<String> keys);
        Partition removeAll(); 
    }

    global abstract class Cache implements Partition {
        // Represents a "Category" of cache. Possible categories enumerated by CacheType.
        global abstract Partition getPartition(String partitionName);
        global abstract Partition getDefault();

        // Partition methods should all point to the default partition
        global virtual Boolean contains(String key) {
            return this.getDefault()?.contains(key) == true;
        }

        global virtual Map<String, Boolean> contains(Set<String> keys) {
            return this.getDefault()?.contains(keys); 
        } 

        global virtual Boolean containsAll(Set<String> keys) {
            return this.getDefault()?.containsAll(keys);
        }

        global virtual Boolean containsSome(Set<String> keys) {
            return this.getDefault()?.containsSome(keys); 
        }

        global virtual Object get(String key) {
            return this.getDefault()?.get(key);
        }

        global virtual Map<String, Object> get(Set<String> keys) {
            return this.getDefault()?.get(keys); 
        }

        global virtual Map<String, Object> getAll() {
            return this.getDefault()?.getAll(); 
        }

        global virtual Set<String> getKeys() {
            return this.getDefault()?.getKeys(); 
        }

        global virtual Partition put(String key, Object value) {
            return this.put(new Map<String, Object>{key => value});
        }

        global virtual Partition put(Map<String, Object> keyValues) {
            return this.put(keyValues, DEFAULT_TTL_SECS);
        }

        global virtual Partition put(String key, Object value, Integer ttlSecs) {
            return this.put(new Map<String, Object>{key => value}, ttlSecs); 
        }

        global virtual Partition put(Map<String, Object> keyValues, Integer ttlSecs) {
            this.getDefault()?.put(keyValues, ttlSecs); 
            return this; 
        }

        global virtual Partition remove(String key) {
            return this.remove(new Set<String>{key});
        }

        global virtual Partition remove(Set<String> keys) {
            this.getDefault()?.remove(keys); 
            return this; 
        }

        global virtual Partition removeAll() {
            this.getDefault()?.removeAll();
            return this; 
        }
    }
}
