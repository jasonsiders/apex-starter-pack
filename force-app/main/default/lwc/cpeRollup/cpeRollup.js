import { api } from "lwc";
import { ComboboxOption } from "c/comboboxUtils";
import { CustomPropertyEditor, DataTypes, Error, TypeChangedEvent, ValueChangedEvent, ValueDeletedEvent } from "c/customPropertyEditor";

const ROLLUP_CMDT = {
    // Note: When imported, CMDTs have the wrong `objectApiName` value (ex., Rollup__c, instead of Rollup__mdt)
    // If this is eventually fixed, replace this object with the appropriate import
    objectApiName: "Rollup__mdt"
}

class ApexElement {
    // Represents an InvocableVariable, which can be mapped to an Input
    variableName; 
    isCollection;

    constructor(variableName, isCollection) {
        this.variableName = variableName;
        this.isCollection = isCollection || false;
    }
}

class Input {
    // An Input represents a single input field in the component
    // Maps to an instance of c-cpe-combobox
    label;
    name;
    dataType; 
    apexElements = [];
    options = [];

    constructor(label, name, dataType) {
        this.label = label;
        this.name = name;
        this.dataType = dataType;
    }

    addElements(elements) {
        this.apexElements = this.apexElements?.concat(elements);
        return this;
    }

    addOptions(options) {
        this.options = this.options?.concat(options);
        return this;
    }

    addOptionsFromFlow(resources) {
        resources?.forEach(resource => {
            const isCollection = !!resource?.isCollection; 
            const objectType = resource?.objectType; 
            const resourceType = (isCollection) ? `List<${objectType}>` : objectType;
            const value = resource?.name;
            const label = `${value} (${resourceType})`;
            this.addOptions(new ComboboxOption(label, value));
        });
        return this;
    }

    get variable() {
        return this.apexElements.find(element => element.isCollection === false)?.variableName;
    }

    get listVariable() {
        return this.apexElements.find(element => element.isCollection === true)?.variableName;
    }
}

export default class RollupConfig extends CustomPropertyEditor {
    inputs = [];

    connectedCallback() {
        this.generateInputs();
    }

    @api validate() {
        let errors = [];
        this.template.querySelectorAll("c-cpe-combobox")?.forEach(field => {
            if (!field.reportValidity()) {
                errors.push(new Error(field?.label, `${field?.label} is invalid`));
            }
        });
        return errors;
    }

    getInput(inputName) {
        return this.inputs?.find(input => (input?.name === inputName));
    }

    generateInputs() {
        const rollupInput = new Input("Rollup Metadata Record(s)", "rollups", DataTypes.REFERENCE)
            ?.addElements([new ApexElement("rollup", false), new ApexElement("rollups", true)])
            ?.addOptionsFromFlow(this.getFlowResources()?.filter(resource => (
                resource?.dataType === "SObject" &&
                resource.objectType === ROLLUP_CMDT?.objectApiName
            )));
        const recordInput = new Input("Target Record(s)", "records", DataTypes.REFERENCE)
            ?.addElements([new ApexElement("record", false), new ApexElement("records", true)])
            ?.addOptionsFromFlow(this.getFlowResources()?.filter(resource => (
                resource?.dataType === "SObject" &&
                resource.objectType !== ROLLUP_CMDT?.objectApiName
            )));
        const contextInput = new Input("Target Record Context", "context", DataTypes.STRING)
            ?.addOptions([new ComboboxOption("Child Records", "CHILD"), new ComboboxOption("Parent Records", "PARENT")])
            ?.addElements(new ApexElement("context", false));
        const timingInput = new Input("Timing", "timing", DataTypes.STRING)
            ?.addOptions([new ComboboxOption("Asynchronous", "ASYNCHRONOUS"), new ComboboxOption("Synchronous", "SYNCHRONOUS")])
            ?.addElements(new ApexElement("timing", false));
        this.inputs = [rollupInput, recordInput, contextInput, timingInput];
    }

    handleChange(event) {
        const elementName = event?.target?.name || event?.detail?.name; 
        const newValue = event?.detail?.newValue || event?.detail?.value;
        this.updateType(elementName, newValue);
        this.updateValue(elementName, newValue); 
    }

    updateType(elementName, flowResourceName) {
        // Send the SObjectType to the flow engine for generic SObject variables
        // No need to do this if the invocable action defines a specific SObjectType
        const isGenericType = !!this.getGenericTypeMapping(elementName);
        const objectType = this.getFlowResource(flowResourceName)?.objectType;
        if (isGenericType && objectType) {
            // Note: Only one of the generic record/records variables will actually be used,
            // but Flow requires that all used generics have a set type to save the action
            this.genericTypeMappings?.forEach(mapping => {
                const event = new TypeChangedEvent(mapping?.typeName, objectType)
                this.dispatchEvent(event);
            });
        }
    }

    updateValue(elementName, newValue) {
        // Route to a singular/list apex input, depending on whether the element is a collection or not
        const input = this.getInput(elementName);
        const isCollection = !!this.getFlowResource(newValue)?.isCollection;
        input.apexElements?.forEach(element => {
            if (element.isCollection === isCollection) {
                this.dispatchEvent(new ValueChangedEvent(element?.variableName, newValue, input?.dataType));
            } else {
                this.deleteValue(element?.variableName);
            }
        });
    }

    deleteValue(paramName) {
        // Only fire if the given parameter actually has a value
        if (paramName && this.getInvocableVariable(paramName)?.value) {
            this.dispatchEvent(new ValueDeletedEvent(paramName));
        }   
    }
}