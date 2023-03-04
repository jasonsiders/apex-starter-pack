global abstract class Caches {
    static final TransactionCache TRANSACTION_CACHE = new TransactionCache();

    static final Map<CacheType, Partitionable> PARTITIONS_BY_TYPE = new Map<CacheType, Partitionable>{
        CacheType.ORG => new OrgCache(), 
        CacheType.SESSION => new SessionCache(),
        CacheType.TRANSACTIONAL => new TransactionCache()
    };

    global static Partition getPartition(CacheType cacheType, String partitionName) {
        // Return a cache partition of a specific name
        Partition partition = Caches.PARTITIONS_BY_TYPE?.get(cacheType)?.getPartition(partitionName); 
        System.debug('Requested Caches.CacheType.' + cacheType + ' -> ' + apxsp.TypeUtils.getTypeName(partition)); 
        return partition; 
    }

    global static Partition getPartition(CacheType cacheType) {
        // Return the default cache partition for a specific cache type
        Partition partition = Caches.PARTITIONS_BY_TYPE?.get(cacheType)?.getDefault();   
        System.debug('Requested Caches.CacheType.' + cacheType + ' -> ' + apxsp.TypeUtils.getTypeName(partition)); 
        return partition; 
    }

    global static Partition getTransactionCache() {
        return TRANSACTION_CACHE; 
    }

    // **** INNER **** // 
    global enum CacheType {
        ORG,
        SESSION,
        TRANSACTIONAL
    }

    global interface Partition {
        // Assign to classes that represent a single cache partition
        Boolean contains(String key); 
        Object get(String key);
        Partition put(String key, Object value); 
        Partition remove(String key); 
    }

    global interface Partitionable {
        // Assign to classes which contain multiple partitions
        Partition getPartition(String partitionName); 
        Partition getDefault();
    }

    global abstract class PlatformCache implements Partitionable {
        protected Map<String, Partition> partitions = new Map<String, Partition>();
        protected Partition defaultPartition; 

        global Partition getPartition(String partitionName) {
            Partition partition = this.partitions?.get(partitionName); 
            if (partition == null) {
                try {
                    Cache.Partition cachePartition = this.retrieve(partitionName); 
                    partition = new PlatformPartition(cachePartition); 
                    this.partitions?.put(partitionName, partition); 
                } catch (Exception error) {
                    // The cache partition does not exist.
                    System.debug('getPartition(' + partitionName + ') error: ' + error);
                }
            }
            return (partition != null) ? partition : Caches.getTransactionCache(); 
        }

        global Partition getDefault() {
            if (this.defaultPartition == null) {
                try {
                    String defaultName = this.getDefaultPartitionName();
                    this.defaultPartition = this.getPartition(defaultName); 
                } catch (Exception error) {
                    // A default partition does not exist.
                    System.debug('getDefault() error: ' + error);
                }
            }
            return (this.defaultPartition != null) ? this.defaultPartition : Caches.getTransactionCache(); 
        }

        global abstract Cache.Partition retrieve(String partitionName); 
        global abstract String getDefaultPartitionName();
    }

    global class OrgCache extends PlatformCache {
        global override Cache.Partition retrieve(String partitionName) {
            return Cache.Org.getPartition(partitionName); 
        }

        global override String getDefaultPartitionName() {
            return Cache.Org.getName();
        }
    }

    global class SessionCache extends PlatformCache {
        global override Cache.Partition retrieve(String partitionName) {
            return Cache.Session.getPartition(partitionName); 
        }

        global override String getDefaultPartitionName() {
            return Cache.Session.getName();
        }
    }

    global class PlatformPartition implements Partition {
        // Wraps the Cache.Partition 
        Cache.Partition partition; 

        global PlatformPartition(Cache.Partition partition) {
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

    global class TransactionCache implements Partition, Partitionable {
        Map<String, Object> cachedValues = new Map<String, Object>(); 

        private TransactionCache() {
            // Not avaialable for construction outside of this file
        }

        global Boolean contains(String key) {
            return this.cachedValues?.containsKey(key) == true; 
        }

        global Object get(String key) {
            return this.cachedValues?.get(key); 
        }

        global TransactionCache put(String key, Object value) {
            this.cachedValues?.put(key, value); 
            return this; 
        }

        global TransactionCache remove(String key) {
            this.cachedValues?.remove(key); 
            return this; 
        }

        global TransactionCache getPartition(String doesntMatter) {
            // Always return the TransactionCache instance
            return this.getDefault();  
        }

        global TransactionCache getDefault() {
            return this; 
        }
    }   
}