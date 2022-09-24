public interface ICriteria {
    Set<String> getFieldNames();  
    Boolean meetsCriteria(SObject record);
    Boolean meetsCriteria(Object obj);
    String toString(); 
}
