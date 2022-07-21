public interface Mappable {
    // Extending types can safely be used as a map key. For more, see:
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_collections_maps_keys_userdefined.htm
    Boolean equals(Object obj);
    Integer hashCode();
}
