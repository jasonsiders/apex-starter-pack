global virtual class PlatformCache extends CacheManager.Cache {
	protected CacheManager.CacheType cacheType;

	public PlatformCache(CacheManager.CacheType cacheType) {
		// Not available for construction outside of this package.
		// Conventionally, should only be constructed from the CacheManager file
		this.cacheType = cacheType;
	}

	global virtual override CacheManager.Partition getPartition(String partitionName) {
		CacheManager.Partition partition;
		try {
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
			partition = (capacity > 0) ? new Partition(cachePartition) : null;
		} catch (Exception error) {
			// Platform Cache is not configured for this org - use fallback partition
		}
		return (partition != null) ? partition : this.getFallback();
	}

	global virtual override CacheManager.Partition getDefault() {
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

	protected virtual CacheManager.Partition getFallback() {
		return CacheManager.getTransactionCache();
	}

	global virtual class Partition implements CacheManager.Partition {
		Cache.Partition cachePartition;

		@TestVisible
		protected Partition(Cache.Partition cachePartition) {
			this.cachePartition = cachePartition;
		}

		global Boolean contains(String key) {
			return this.cachePartition?.contains(key) == true;
		}

		global Map<String, Boolean> contains(Set<String> keys) {
			return this.cachePartition?.contains(keys);
		}

		global Boolean containsAll(Set<String> keys) {
			Set<Object> resultSet = CollectionUtils.toSet(this.contains(keys)?.values());
			return resultSet?.size() == 1 && resultSet?.contains(true);
		}

		global Boolean containsSome(Set<String> keys) {
			return CollectionUtils.toSet(this.contains(keys)?.values())?.contains(true) == true;
		}

		global Object get(String key) {
			Object value = this.cachePartition?.get(key);
			return (value != CacheManager.NULL_VALUE) ? value : null;
		}

		global Map<String, Object> get(Set<String> keys) {
			return this.cachePartition?.get(keys);
		}

		global Map<String, Object> getAll() {
			Set<String> allKeys = this.getKeys();
			return this.get(allKeys);
		}

		global Set<String> getKeys() {
			return this.cachePartition?.getKeys();
		}

		global CacheManager.Partition put(String key, Object value) {
			return this.put(new Map<String, Object>{ key => value });
		}

		global CacheManager.Partition put(Map<String, Object> keyValues) {
			return this.put(keyValues, CacheManager.DEFAULT_TTL_SECS);
		}

		global CacheManager.Partition put(String key, Object value, Integer ttlSecs) {
			Object cacheValue = (value != null) ? value : CacheManager.NULL_VALUE;
			this.cachePartition?.put(key, cacheValue, ttlSecs);
			return this;
		}

		global CacheManager.Partition put(Map<String, Object> keyValues, Integer ttlSecs) {
			for (String key : keyValues?.keySet()) {
				Object value = keyValues?.get(key);
				this.put(key, value, ttlSecs);
			}
			return this;
		}

		global CacheManager.Partition remove(String key) {
			return this.remove(new Set<String>{ key });
		}

		global CacheManager.Partition remove(Set<String> keys) {
			keys = (keys != null) ? keys : new Set<String>();
			for (String key : keys) {
				this.cachePartition?.remove(key);
			}
			return this;
		}

		global CacheManager.Partition removeAll() {
			Set<String> allKeys = this.getKeys();
			return this.remove(allKeys);
		}
	}
}
