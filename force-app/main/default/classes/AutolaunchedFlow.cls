global abstract class AutolaunchedFlow {
    // Abstracts away most of the complexities of calling autolaunched flows in apex
    static final String DEFAULT_ERROR_PROPERTY = 'errorMessage'; 

    @TestVisible 
    protected Map<String, Object> inputs = new Map<String, Object>();
    global Flow.Interview interview;
    
    // This method should initialize an input of the desired type
    // IMPORTANT: The input params (ie., this.input) *must* be provided in the constructor.
    // Unfortunately, the Interview class has no dedicated method to do this post-construction. 
    global abstract Flow.Interview initInterview();

    global virtual AutolaunchedFlow setInput(String key, Object value) {
        this.inputs?.put(key, value); 
        return this; 
    }
    
    global virtual AutolaunchedFlow run() {
        this.interview = this.initInterview(); 
        this.interview?.start(); 
        this.handleErrors();
        return this; 
    }

    global virtual Object getOutput(String propertyName) {
        return this.interview?.getVariableValue(propertyName); 
    }

    // IMPORTANT: By default, flows throw a generic System.FlowException: "An unhandled fault has occurred".
    // To get the "actual" error message, use a fault path to store the {!$Flow.FaultMessage} in an output property.
    // Define the name of that property in this class, using the getErrorProperty() method.
    // The class will retrieve the value of this error property after running the flow. 
    // If the error property has a value, this class will use it to generate/throw a System.FlowException. 
    global virtual String getErrorProperty() {
        return DEFAULT_ERROR_PROPERTY; 
    }

    global virtual String getError() {
        String errorProp = this.getErrorProperty();
        return String.valueOf(this.getOutput(errorProp));
    }

    global virtual void handleErrors() {
        String error = this.getError(); 
        if (String.isNotBlank(error)) {
            throw new System.FlowException(error); 
        }
    }
}