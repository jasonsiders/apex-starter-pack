global abstract class CacheManager {
    static final String NULL_VALUE = '<<<NULL_CACHE_VALUE>>>';
    @TestVisible
    static final Map<CacheType, Division> DIVISIONS_BY_TYPE = new Map<CacheType, Division>{
        CacheType.ORG => new OrgCache(),
        CacheType.SESSION => new SessionCache(),
        CacheType.TRANSACTIONAL => new TransactionCache()
    };

    global static Division getDivision(CacheType cacheType) {
        Division division = CacheManager.DIVISIONS_BY_TYPE?.get(cacheType); 
        System.debug('CacheManager.getDivision(' + cacheType + ') -> ' + TypeUtils.getType(division));
        return division;
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
        Map<String, Boolean> contains(Set<String> keys);
        Boolean containsAll(Set<String> keys);
        Boolean containsSome(Set<String> keys);
        Object get(String key); 
        Map<String, Object> get(Set<String> keys);
        Map<String, Object> getAll();
        Set<String> getKeys();
        Partition put(String key, Object value); 
        Partition put(Map<String, Object> valueMap);
        Partition remove(String key); 
        Partition remove(Set<String> keys);
        Partition removeAll();
    }

    global interface Division extends Partition {
        // A division represents a group of Partitions of a particular CacheDivision type
        Partition getPartition(String partitionName);
        Partition getDefault();
    }

    global abstract class PlatformCache implements Division {
        global abstract Cache.Partition getUnderlyingPartition(String partitionName); 
        global abstract String getDefaultPartitionName();

        global Partition getPartition(String partitionName) {
            Partition result;
            try {
                Cache.Partition cachePartition = this.getUnderlyingPartition(partitionName);
                Decimal capacity = cachePartition?.getCapacity();
                result = (capacity > 0) ? new PlatformPartition(cachePartition) : null;
            } catch (Exception error) {
                // The partition likely doesn't exist
            }
            return (result != null) ? result : this.getFallbackCache();
        }

        global Partition getDefault() {
            try {
                String defaultPartitionName = this.getDefaultPartitionName();
                return this.getPartition(defaultPartitionName); 
            } catch (Exception error) {
                // A default partition likely doesn't exist
                return this.getFallbackCache();
            }
        }

        global Boolean contains(String key) {
            return this.getDefault()?.contains(key) == true;
        }

        global Map<String, Boolean> contains(Set<String> keys) {
            return this.getDefault()?.contains(keys); 
        }

        global Boolean containsAll(Set<String> keys) {
            return this.getDefault()?.containsAll(keys);
        }

        global Boolean containsSome(Set<String> keys) {
            return this.getDefault()?.containsSome(keys);
        }

        global Object get(String key) {
            return this.getDefault()?.get(key);
        }

        global Map<String, Object> get(Set<String> keys) {
            return this.getDefault()?.get(keys);
        }

        global Map<String, Object> getAll() {
            return this.getDefault()?.getAll();
        }

        global Set<String> getKeys() {
            return this.getDefault()?.getKeys();
        }

        global Partition put(String key, Object value) {
            return this.getDefault()?.put(key, value); 
        }

        global Partition put(Map<String, Object> valueMap) {
            for (String key : valueMap?.keySet()) {
                Object value = valueMap?.get(key);
                this.put(key, value);
            }
            return this; 
        }

        global Partition remove(String key) {
            return this.getDefault()?.remove(key); 
        }

        global Partition remove(Set<String> keys) {
            for (String key : keys) {
                this.remove(key); 
            }
            return this; 
        }

        global Partition removeAll() {
            Set<String> keys = this.getKeys();
            return this.remove(keys);
        }

        protected virtual Partition getFallbackCache() {
            return CacheManager.getPartition(CacheType.TRANSACTIONAL); 
        }
    }

    global class OrgCache extends PlatformCache {
        private OrgCache() {
            // Cannot be constructed outside of this file
        }

        global override Cache.Partition getUnderlyingPartition(String partitionName) {
            System.debug('OrgCache: ' + Cache.Org.getCapacity());
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
            System.debug('SessionCache: ' + Cache.Session.getCapacity());
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
            System.debug('PlatformCache.contains(' + key + ')');
            return this.partition?.contains(key) == true; 
        }

        global Map<String, Boolean> contains(Set<String> keys) {
            return this.partition?.contains(keys);
        }

        global Boolean containsAll(Set<String> keys) {
            Set<Boolean> results = new Set<Boolean>(this.contains(keys)?.values());
            return results?.size() == 1 && results?.contains(true);
        }

        global Boolean containsSome(Set<String> keys) {
            return new Set<Boolean>(this.contains(keys)?.values())?.contains(true) == true; 
        }

        global Object get(String key) {
            Object value = this.partition?.get(key); 
            System.debug('PlatformCache.contains(' + key + ') -> ' + value);
            return (value != NULL_VALUE) ? value : null;
        }

        global Map<String, Object> get(Set<String> keys) {
            return this.partition?.get(keys);
        }

        global Map<String, Object> getAll() {
            Set<String> keys = this.getKeys();
            return this.get(keys);
        }

        global Set<String> getKeys() {
            return this.partition?.getKeys();
        }

        global PlatformPartition put(String key, Object value) {
            System.debug('PlatformCache.put(' + key + ', ' + value + ')');
            // PlatformCache cannot accept null values
            value = (value != null) ? value : NULL_VALUE; 
            this.partition?.put(key, value); 
            return this; 
        }

        global PlatformPartition put(Map<String, Object> valueMap) {
            for (String key : valueMap?.keySet()) {
                Object value = valueMap?.get(key);
                this.put(key, value);
            }
            return this; 
        }

        global PlatformPartition remove(String key) {
            System.debug('PlatformCache.remove(' + key + ')');
            this.partition?.remove(key); 
            return this; 
        }

        global PlatformPartition remove(Set<String> keys) {
            for (String key : keys) {
                this.remove(key);
            }
            return this; 
        }

        global PlatformPartition removeAll() {
            Set<String> keys = this.getKeys(); 
            return this.remove(keys); 
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
            System.debug('TransactionCache.contains(' + key + ')');
            return this.cacheMap?.containsKey(key); 
        }

        global Map<String, Boolean> contains(Set<String> keys) {
            Map<String, Boolean> results = new Map<String, Boolean>();
            for (String key : keys) {
                Boolean containsKey = this.cacheMap?.containsKey(key) == true; 
                results?.put(key, containsKey);
            }
            return results; 
        }

        global Boolean containsAll(Set<String> keys) {
            Set<Boolean> results = new Set<Boolean>(this.contains(keys)?.values());
            return results?.size() == 1 && results?.contains(true); 
        }

        global Boolean containsSome(Set<String> keys) {
            return new Set<Boolean>(this.contains(keys)?.values())?.contains(true) == true; 
        }

        global Object get(String key) {
            Object value = this.cacheMap?.get(key); 
            System.debug('TransactionCache.get(' + key + ') -> ' + value);
            return value;
        }

        global Map<String, Object> get(Set<String> keys) {
            Map<String, Object> results = new Map<String, Object>();
            for (String key : keys) {
                Object value = this.cacheMap?.get(key);
                results.put(key, value);
            }
            return results; 
        }

        global Map<String, Object> getAll() {
            Set<String> keys = this.getKeys();
            return this.get(keys);
        }

        global Set<String> getKeys() {
            return this.cacheMap?.keySet();
        }

        global Partition put(String key, Object value) {
            System.debug('TransactionCache.put(' + key + ', ' + value + ')');
            this.cacheMap?.put(key, value); 
            return this; 
        }

        global Partition put(Map<String, Object> valueMap) {
            for (String key : valueMap?.keySet()) {
                Object value = valueMap?.get(key);
                this.put(key, value);
            }
            return this; 
        }

        global Partition remove(String key) {
            System.debug('TransactionCache.remove(' + key + ')');
            this.cacheMap?.remove(key);
            return this; 
        }

        global Partition remove(Set<String> keys) {
            for (String key : keys) {
                this.remove(key); 
            }
            return this; 
        }

        global Partition removeAll() {
            Set<String> keys = this.getKeys();
            return this.remove(keys); 
        }
    }
}