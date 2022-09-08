import { api, LightningElement } from 'lwc';

class CustomPropertyEditor extends LightningElement {
    @api builderContext;
    @api genericTypeMappings;
    @api inputVariables;

    @api validate() {
        // This method runs after the admin clicks the action modal's "Done" button
        let errors = [];
        return errors;
    }

    getFlowResources() {
        return this.builderContext?.variables;
    }

    getFlowResource(name) {
        return this.getFlowResources()?.find(variable => (variable.name === name));
    }

    getGenericTypeMapping(name) {
        const typeName = `T__${name}`;
        return this.genericTypeMappings.find(mapping => mapping.typeName === typeName);
    }
    
    getInvocableVariable(name) {
        return this.inputVariables.find(variable => (variable.name === name));
    }
}

const DataTypes = {
    STRING: "String",
    NUMBER: "Number",
    DATE_TIME: "DateTime",
    BOOLEAN: "Boolean",
    REFERENCE: "reference"
};

const EventNames = {
    TYPE_CHANGED: "configuration_editor_generic_type_mapping_changed",
    VALUE_CHANGED: "configuration_editor_input_value_changed",
    VALUE_DELETED: "configuration_editor_input_value_deleted"
};

class Error {
    key;
    errorString;

    constructor(key, errorString) {
        this.key = key;
        this.errorString = errorString; 
    }
}

class _CpeEvent extends CustomEvent {
    constructor(eventName, detail) {
        super(eventName, {
            bubbles: true,
            cancelable: false,
            composed: true,
            detail
        });
    }
}

class TypeChangedEvent extends _CpeEvent {
    constructor(typeName, typeValue) {
        super(EventNames.TYPE_CHANGED, { typeName, typeValue });
    }
}

class ValueChangedEvent extends _CpeEvent {
    constructor(name, newValue, newValueDataType) {
        super(EventNames.VALUE_CHANGED, { name, newValue, newValueDataType });
    }
}

class ValueDeletedEvent extends _CpeEvent {
    constructor(name) {
        super(EventNames.VALUE_DELETED, { name });
    }
}

export { CustomPropertyEditor, DataTypes, Error, TypeChangedEvent, ValueChangedEvent, ValueDeletedEvent };