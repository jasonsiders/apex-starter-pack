public class MaxCalculator extends Rollup.Calculator {
	public override Date calculateDate(List<SObject> records) {
		Date maxDate;
		for (SObject record : records) {
			Date newDate = (Date) record?.get(this.calcField?.toSchemaType());
			Boolean newIsGreater = (maxDate == null || (newDate != null && newDate > maxDate));
			maxDate = (newIsGreater) ? newDate : maxDate;
		}
		return maxDate;
	}

	public override DateTime calculateDateTime(List<SObject> records) {
		DateTime maxDate;
		for (SObject record : records) {
			DateTime newDate = (DateTime) record?.get(this.calcField?.toSchemaType());
			Boolean newIsGreater = (maxDate == null || (newDate != null && newDate > maxDate));
			maxDate = (newIsGreater) ? newDate : maxDate;
		}
		return maxDate;
	}

	public override Decimal calculateNumber(List<SObject> records) {
		Decimal maxNum;
		for (SObject record : records) {
			Decimal newNum = (Decimal) record?.get(this.calcField?.toSchemaType());
			Boolean newIsGreater = (maxNum == null || (newNum != null && newNum > maxNum));
			maxNum = (newIsGreater) ? newNum : maxNum;
		}
		return (maxNum != null) ? maxNum : 0;
	}
}
