global virtual class TransactionCache extends CacheManager.Cache {
	// Transaction cache isn't platform cache at all - a static Map that persists throughout a single transaction
	// It can be used as a "fallback" in the event that platform cache isn't enabled for an org
	Map<String, Object> cacheMap = new Map<String, Object>();

	public TransactionCache() {
		// Not available for construction outside of this package.
		// Conventionally, should only be constructed from the CacheManager file
	}

	// Only ever one CacheManager.Partition in TransactionCache, and it's always available
	global override CacheManager.Partition getPartition(String partitionName) {
		return this;
	}

	global override CacheManager.Partition getDefault() {
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

	global override CacheManager.Partition put(String key, Object value) {
		return this.put(new Map<String, Object>{ key => value });
	}

	global override CacheManager.Partition put(Map<String, Object> keyValues) {
		return this.put(keyValues, null);
	}

	global override CacheManager.Partition put(String key, Object value, Integer ttlSecs) {
		return this.put(new Map<String, Object>{ key => value }, ttlSecs);
	}

	global override CacheManager.Partition put(Map<String, Object> keyValues, Integer ttlSecs) {
		// The concept of "ttlSecs" does not exist in TransactionCache,
		// values are only persisted for the length of the current transaction
		this.cacheMap?.putAll(keyValues);
		return this;
	}

	global override CacheManager.Partition remove(String key) {
		this.cacheMap?.remove(key);
		return this;
	}

	global override CacheManager.Partition remove(Set<String> keys) {
		this.cacheMap?.keySet()?.removeAll(keys);
		return this;
	}

	global override CacheManager.Partition removeAll() {
		this.cacheMap?.clear();
		return this;
	}
}
