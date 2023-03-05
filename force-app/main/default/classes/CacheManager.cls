global abstract class CacheManager {
    static final String NULL_VALUE = '<<<NULL_CACHE_VALUE>>>';
    @TestVisible
    static final Map<CacheType, Division> DIVISIONS_BY_TYPE = new Map<CacheType, Division>{
        CacheType.ORG => new OrgCache(),
        CacheType.SESSION => new SessionCache(),
        CacheType.TRANSACTIONAL => new TransactionCache()
    };

    global static Division getDivision(CacheType cacheType) {
        return CacheManager.DIVISIONS_BY_TYPE?.get(cacheType); 
    }

    global static Partition getPartition(CacheType cacheType, String partitionName) {
        return CacheManager.getDivision(cacheType)?.getPartition(partitionName); 
    }

    global static Partition getPartition(CacheType cacheType) {
        // Returns the default partition for this CacheType
        return CacheManager.getDivision(cacheType)?.getDefault(); 
    }
    
    // **** INNER **** //
    global enum CacheType {
        ORG,
        SESSION, 
        TRANSACTIONAL
    }

    global interface Partition {
        // A partition abstracts the mechanism used to store & retrieve cache data
        Boolean contains(String key); 
        Object get(String key); 
        Partition put(String key, Object value); 
        Partition remove(String key); 
    }

    global interface Division extends Partition {
        // A division represents a group of partitions of the same CacheType
        // Divisions also contain Partition methods as shorthand; 
        // when these are called, it refers to its default partition
        Partition getPartition(String partitionName);
        Partition getDefault();
    }

    global abstract class PlatformCache implements Division {
        global abstract Cache.Partition getUnderlyingPartition(String partitionName); 
        global abstract String getDefaultPartitionName();

        global Partition getPartition(String partitionName) {
            try {
                Cache.Partition partition = this.getUnderlyingPartition(partitionName); 
                return new PlatformPartition(partition); 
            } catch (Exception error) {
                // The partition likely doesn't exist; fallback to TransactionCache
                return this.getTransactionCache();
            }
        }

        global Partition getDefault() {
            try {
                String partitionName = this.getDefaultPartitionName(); 
                return this.getPartition(partitionName); 
            } catch (Exception error) {
                // A default partition likely doesn't exist; fallback to TransactionCache
                return this.getTransactionCache();
            }
        }

        global Boolean contains(String key) {
            return this.getDefault()?.contains(key) == true; 
        }

        global Object get(String key) {
            return this.getDefault()?.get(key);
        }

        global Partition put(String key, Object value) {
            return this.getDefault()?.put(key, value); 
        }

        global Partition remove(String key) {
            return this.getDefault()?.remove(key); 
        }

        protected Partition getTransactionCache() {
            return CacheManager.getPartition(CacheType.TRANSACTIONAL); 
        }
    }

    global class OrgCache extends PlatformCache {
        private OrgCache() {
            // Cannot be constructed outside of this file
        }

        global override Cache.Partition getUnderlyingPartition(String partitionName) {
            return Cache.Org.getPartition(partitionName); 
        }

        global override String getDefaultPartitionName() {
            return Cache.Org.getName();
        }
    }

    global class SessionCache extends PlatformCache {
        private SessionCache() {
            // Cannot be constructed outside of this file
        }

        global override Cache.Partition getUnderlyingPartition(String partitionName) {
            return Cache.Session.getPartition(partitionName); 
        }

        global override String getDefaultPartitionName() {
            return Cache.Session.getName();  
        }
    }

    global class PlatformPartition implements Partition {
        Cache.Partition partition; 

        @TestVisible
        private PlatformPartition(Cache.Partition partition) {
            this.partition = partition; 
        }

        global Boolean contains(String key) {
            return this.partition?.contains(key) == true; 
        }

        global Object get(String key) {
            return this.partition?.get(key); 
        }

        global PlatformPartition put(String key, Object value) {
            this.partition?.put(key, value); 
            return this; 
        }

        global PlatformPartition remove(String key) {
            this.partition?.remove(key); 
            return this; 
        }
    }

    global class TransactionCache implements Division, Partition {
        // Transaction-based caching is not tied to Platform cache
        // When platform cache misses or other errors occur, the system uses Transaction cache as a fallback
        final Map<String, Object> cacheMap = new Map<String, Object>();

        private TransactionCache() {
            // Cannot be constructed outside of this file
        }

        global Partition getPartition(String doesntMatter) {
            // There is only one "Partition" of Transaction cache; the static map above
            return this.getDefault(); 
        }

        global Partition getDefault() {
            // Since there is only one "partition" of platform cache, the division is also the partition
            return this; 
        }

        global Boolean contains(String key) {
            return this.cacheMap?.containsKey(key); 
        }

        global Object get(String key) {
            return this.cacheMap?.get(key); 
        }

        global TransactionCache put(String key, Object value) {
            this.cacheMap?.put(key, value); 
            return this; 
        }

        global TransactionCache remove(String key) {
            this.cacheMap?.remove(key);
            return this; 
        }
    }
}