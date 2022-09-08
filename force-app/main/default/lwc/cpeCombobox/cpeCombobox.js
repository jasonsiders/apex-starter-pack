import { api, LightningElement } from 'lwc';

export default class CpeCombobox extends LightningElement {
    // Wraps a stripped-down version of lightning-combobox, 
    // and allows it access to parent CPE context to automatically render values
    // Note: Ideally, we'd just extend the LightningCombobox class and call it a day
    // but unfortunately, SFDC doesn't allow extending the `Lightning` namespace
    // ...except they actually do sometimes? See lightning-datatable, for example...
    @api inputVariables = []; 
    @api invocableVariable;
    @api invocableListVariable;

    // Provide the same access to properties/methods as the base component
    // https://developer.salesforce.com/docs/component-library/bundle/lightning-combobox/specification
    @api disabled = false;
    @api dropdownAlignment = "left";
    @api fieldLevelHelp;
    @api label = this.name; 
    @api messageWhenValueMissing = "Complete this field";
    @api name;
    @api options = []; 
    @api placeholder = "Select an Option";
    @api readOnly = false;
    @api required = false;
    @api spinnerActive = false;
    @api variant = "standard";

    @api get validity() {
        // This property does not have a setter in the base component
        return this._baseComponent?.checkValidity();
    }

    @api get value() {
        // The primary departure from the base component...
        // value is derived from the InvocableVariables associated with the component
        return this._getValue(this.invocableVariable) || this._getValue(this.invocableListVariable);
    }

    @api blur() {
        this._baseComponent?.blur(); 
    }

    @api checkValidity() {
        return this._baseComponent?.checkValidity();
    }

    @api focus() {
        this._baseComponent?.focus();
    }

    @api reportValidity() {
        return this._baseComponent?.reportValidity();
    }

    @api setCustomValidity(message) {
        this._baseComponent?.setCustomValidity(message);
    }

    @api showHelpMessageIfInvalid() {
        this._baseComponent?.showHelpMessageIfInvalid();
    }

    get _baseComponent() {
        return this.template.querySelector("lightning-combobox");
    }

    _getValue(variableName) {
        return this.inputVariables?.find(variable => variable.name === variableName)?.value;
    }
}