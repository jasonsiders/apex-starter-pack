import { api } from 'lwc';
import { CustomPropertyEditor, DataTypes, Error, TypeChangedEvent, ValueChangedEvent, ValueDeletedEvent } from "c/customPropertyEditor";
import { ComboboxOption } from "c/comboboxUtils";

const LEVEL_VAR_NAME = "logLevelName";
const MSG_VAR_NAME = "logMessage";
const MSG_TOOLTIP = `Can support flow variables using merge field syntax\nFor example: "{!myVar}"`;
// This is the absolute max for all long-text area fields in SFDC
const MAX_LENGTH = 131072; 

const LEVEL_OPTIONS = [
    new ComboboxOption("FINEST"),
    new ComboboxOption("FINER"),
    new ComboboxOption("FINE"),
    new ComboboxOption("DEBUG"),
    new ComboboxOption("INFO"),
    new ComboboxOption("WARN"),
    new ComboboxOption("ERROR") 
];

export default class CpeLogger extends CustomPropertyEditor {
    levelOptions = LEVEL_OPTIONS; 
    levelVariable = LEVEL_VAR_NAME;
    messageVariable = MSG_VAR_NAME;
    messageTooltip = MSG_TOOLTIP;
    maxLength = MAX_LENGTH;

    @api validate() {
        let errors = [];
        const innerComponents = ["c-cpe-combobox", "lightning-textarea"];
        innerComponents?.forEach(componentName => {
            const component = this.template.querySelector(componentName);
            if (!component.reportValidity()) {
                errors.push(new Error(component?.label, `${component?.label} is invalid`));
            }
        });
        return errors;
    }
    
    get messageValue() {
        return this.getInvocableVariable(MSG_VAR_NAME)?.value;
    }

    handleChange(event) {
        const elementName = event?.target?.name || event?.detail?.name; 
        const newValue = event?.detail?.newValue || event?.detail?.value;
        const valueChangedEvent = new ValueChangedEvent(elementName, newValue, DataTypes.STRING);
        this.dispatchEvent(valueChangedEvent);
    }
}