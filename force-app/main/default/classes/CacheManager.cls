global abstract class CacheManager {
    @TestVisible
    static final Map<CacheType, CacheDivision> DIVISIONS_BY_TYPE = new Map<CacheType, CacheDivision>{
        CacheType.ORG => new PlatformCache(CacheType.ORG),
        CacheType.SESSION => new PlatformCache(CacheType.SESSION),
        CacheType.TRANSACTIONAL => new TransactionCache()
    };
    // Note: Necessary because PlatformCache doesn't allow *actual* null values
    static final String NULL_VALUE = '<<<NULL_CACHE_VALUE>>>';
    // Note: Cache tokens default to & can persist for a maximum of 24 hours/86400 seconds:
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_platform_cache_limits.htm
    static final Integer DEFAULT_TTL_SECS = 86400;

    global static CacheDivision getOrgCache() {
        return CacheManager.getCache(CacheType.ORG);
    }

    global static CacheDivision getSessionCache() {
        return CacheManager.getCache(CacheType.SESSION);
    }

    global static CacheDivision getTransactionCache() {
        return CacheManager.getCache(CacheType.TRANSACTIONAL);
    }
    
    global static CacheDivision getCache(CacheType cacheType) {
        return DIVISIONS_BY_TYPE?.get(cacheType);
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

    global abstract class CacheDivision implements Partition {
        // A cache division represents a "Category" of cache. Possible categories enumerated by CacheType.
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

    global virtual class TransactionCache extends CacheDivision {
        // Transaction cache isn't platform cache at all - a static Map that persists throughout a single transaction
        // It can be used as a "fallback" in the event that platform cache isn't enabled for an org
        Map<String, Object> cacheMap = new Map<String, Object>();

        protected TransactionCache() {
            // Can't be constructed outside this file
        }

        // Only ever one partition in TransactionCache, and it's always available
        global override Partition getPartition(String partitionName) {
            return this;
        }

        global override Partition getDefault() {
            return this;
        }

        global override Boolean contains(String key) {
            return this.cacheMap?.containsKey(key) == true;
        }

        global override Map<String, Boolean> contains(Set<String> keys) {
            Map<String, Boolean> results = new Map<String, Boolean>(); 
            for (String key : keys) {
                Boolean contains = this.contains(key); 
                results.put(key, contains); 
            }
            return results; 
        }

        global override Boolean containsAll(Set<String> keys) {
            Set<Object> resultSet = CollectionUtils.toSet(this.contains(keys)?.values());
            return resultSet?.size() == 1 && resultSet?.contains(true);
        }

        global override Boolean containsSome(Set<String> keys) {
            return CollectionUtils.toSet(this.contains(keys)?.values())?.contains(true) == true;
        }

        global override Object get(String key) {
            return this.cacheMap?.get(key);
        }

        global override Map<String, Object> get(Set<String> keys) {
            Map<String, Object> results = new Map<String, Object>();
            for (String key : keys) {
                Object value = this.cacheMap?.get(key);
                results.put(key, value); 
            }
            return results; 
        }

        global override Map<String, Object> getAll() {
            Set<String> allKeys = this.getKeys();
            return this.get(allKeys); 
        }

        global override Set<String> getKeys() {
            return this.cacheMap?.keySet(); 
        }

        global override Partition put(String key, Object value) {
            return this.put(new Map<String, Object>{key => value});
        }

        global override Partition put(Map<String, Object> keyValues) {
            return this.put(keyValues, DEFAULT_TTL_SECS);
        }

        global override Partition put(String key, Object value, Integer ttlSecs) {
            return this.put(new Map<String, Object>{key => value}, ttlSecs); 
        }

        global override Partition put(Map<String, Object> keyValues, Integer ttlSecs) {
            // The concept of "ttlSecs" does not exist in TransactionCache,
            // values are only persisted for the length of the current transaction
            this.cacheMap?.putAll(keyValues);
            return this; 
        }

        global override Partition remove(String key) {
            this.cacheMap?.remove(key);
            return this;
        }

        global override Partition remove(Set<String> keys) {
            this.cacheMap?.keySet()?.removeAll(keys);
            return this; 
        }

        global override Partition removeAll() {
            this.cacheMap?.clear();
            return this; 
        }
    }

    global virtual class PlatformCache extends CacheDivision {
        protected CacheManager.CacheType cacheType;

        protected PlatformCache(CacheManager.CacheType cacheType) {
            this.cacheType = cacheType;
        }

        global virtual override Partition getPartition(String partitionName) {
            Partition partition;
            try {
                // For some reason, not allowed to reference these in ternaries w/out casting back to super class
                Cache.Partition cachePartition;
                switch on this.cacheType {
                    when ORG {
                        cachePartition = Cache.Org.getPartition(partitionName);
                    }
                    when SESSION {
                        cachePartition = Cache.Session.getPartition(partitionName);
                    }
                }
                Decimal capacity = (cachePartition != null) ? cachePartition?.getCapacity() : 0;
                partition = (capacity > 0) ? new PlatformPartition(cachePartition) : null; 
            } catch (Exception error) {
                // PlatformCache not set up - use fallback partition
            }
            return (partition != null) ? partition : this.getFallback();
        }

        global virtual override Partition getDefault() {
            try {
                switch on this.cacheType {
                    when ORG {
                        return this.getPartition(Cache.Org.getName());
                    }
                    when SESSION {
                        return this.getPartition(Cache.Session.getName());
                    }
                }
            } catch (Exception error) {
                // Default partition likely doesn't exist, or cache isn't enabled
            }
            return this.getFallback();
        }

        protected virtual Partition getFallback() {
            return CacheManager.getTransactionCache();
        }
    }

    global virtual class PlatformPartition implements Partition {
        // A platform partition is tightly coupled with a Cache.Partition
        Cache.Partition partition;

        @TestVisible
        protected PlatformPartition(Cache.Partition partition) {
            this.partition = partition;
        }

        global Boolean contains(String key) {
            return this.partition?.contains(key) == true;
        }

        global Map<String, Boolean> contains(Set<String> keys) {
            return this.partition?.contains(keys); 
        }

        global Boolean containsAll(Set<String> keys) {
            Set<Object> resultSet = CollectionUtils.toSet(this.contains(keys)?.values());
            return resultSet?.size() == 1 && resultSet?.contains(true); 
        }

        global Boolean containsSome(Set<String> keys) {
            return CollectionUtils.toSet(this.contains(keys)?.values())?.contains(true) == true;
        }

        global Object get(String key) {
            Object value = this.partition?.get(key);
            return (value != NULL_VALUE) ? value : null;
        }

        global Map<String, Object> get(Set<String> keys) {
            return this.partition?.get(keys); 
        }

        global Map<String, Object> getAll() {
            Set<String> allKeys = this.getKeys();
            return this.get(allKeys);
        }

        global Set<String> getKeys() {
            return this.partition?.getKeys();
        }

        global Partition put(String key, Object value) {
            return this.put(new Map<String, Object>{key => value}); 
        }

        global Partition put(Map<String, Object> keyValues) {
            return this.put(keyValues, DEFAULT_TTL_SECS);
        }

        global Partition put(String key, Object value, Integer ttlSecs) {
            Object cacheValue = (value != null) ? value : NULL_VALUE;
            this.partition?.put(key, cacheValue, ttlSecs);
            return this;
        }

        global Partition put(Map<String, Object> keyValues, Integer ttlSecs) {
            for (String key : keyValues?.keySet()) {
                Object value = keyValues?.get(key); 
                this.put(key, value, ttlSecs); 
            }
            return this; 
        }

        global Partition remove(String key) {
            return this.remove(new Set<String>{key});
        }

        global Partition remove(Set<String> keys) {
            keys = (keys != null) ? keys : new Set<String>();
            for (String key : keys) {
                this.partition?.remove(key); 
            }
            return this; 
        }

        global Partition removeAll() {
            Set<String> allKeys = this.getKeys();
            return this.remove(allKeys);
        }
    }
}
