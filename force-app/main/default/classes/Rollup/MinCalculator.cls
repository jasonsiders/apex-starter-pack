public class MinCalculator extends Rollup.Calculator {
	public MinCalculator() {
		this.label = 'MIN';
	}

	public override Date calculateDate(List<SObject> records) {
		Date minDate;
		for (SObject record : records) {
			Date newDate = (Date) record?.get(this.calcField?.toSchemaType());
			Boolean newIsLess = (minDate == null || (newDate != null && newDate < minDate));
			minDate = (newIsLess) ? newDate : minDate;
		}
		return minDate;
	}

	public override DateTime calculateDateTime(List<SObject> records) {
		DateTime minDate;
		for (SObject record : records) {
			DateTime newDate = (DateTime) record?.get(this.calcField?.toSchemaType());
			Boolean newIsLess = (minDate == null || (newDate != null && newDate < minDate));
			minDate = (newIsLess) ? newDate : minDate;
		}
		return minDate;
	}

	public override Decimal calculateNumber(List<SObject> records) {
		Decimal minNum;
		for (SObject record : records) {
			Decimal newNum = (Decimal) record?.get(this.calcField?.toSchemaType());
			Boolean newIsLess = (minNum == null || (newNum != null && newNum < minNum));
			minNum = (newIsLess) ? newNum : minNum;
		}
		return (minNum != null) ? minNum : 0;
	}
}
