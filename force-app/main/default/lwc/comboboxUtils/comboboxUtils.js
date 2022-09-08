import { LightningElement } from 'lwc';

class ComboboxOption {
    label;
    value;

    constructor(label, value) {
        this.label = label;
        this.value = value; 
    }
}

export { ComboboxOption };