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
        Object get(String key);
        Partition put(String key, Object value);
        Partition put(String key, Object value, Integer ttlSecs);
        Partition remove(String key);
    }

    global abstract class CacheDivision implements Partition {
        // A cache division represents a "Category" of cache. Possible categories enumerated by CacheType.
        global abstract Partition getPartition(String partitionName);
        global abstract Partition getDefault();

        // Partition methods should all point to the default partition
        global virtual Boolean contains(String key) {
            return this.getDefault()?.contains(key) == true;
        }

        global virtual Object get(String key) {
            return this.getDefault()?.get(key);
        }

        global virtual Partition put(String key, Object value) {
            this.getDefault()?.put(key, value);
            return this;
        }

        global virtual Partition put(String key, Object value, Integer ttlSecs) {
            this.getDefault()?.put(key, value, ttlSecs);
            return this;
        }

        global virtual Partition remove(String key) {
            this.getDefault()?.remove(key);
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

        global override Object get(String key) {
            return this.cacheMap?.get(key);
        }

        global override Partition put(String key, Object value) {
            return this.put(key, value, DEFAULT_TTL_SECS);
        }

        global override Partition put(String key, Object value, Integer ttlSecs) {
            // The concept of "ttlSecs" does not exist in TransactionCache,
            // values are only persisted for the length of the current transaction
            this.cacheMap?.put(key, value);
            return this;
        }

        global override Partition remove(String key) {
            this.cacheMap?.remove(key);
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

        global Object get(String key) {
            Object value = this.partition?.get(key);
            return (value != NULL_VALUE) ? value : null;
        }

        global Partition put(String key, Object value) {
            return this.put(key, value, DEFAULT_TTL_SECS);
        }

        global Partition put(String key, Object value, Integer ttlSecs) {
            Object cacheValue = (value != null) ? value : NULL_VALUE;
            this.partition?.put(key, cacheValue, ttlSecs);
            return this;
        }

        global Partition remove(String key) {
            this.partition?.remove(key);
            return this;
        }
    }
}
