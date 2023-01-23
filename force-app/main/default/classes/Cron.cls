public class Cron {
	public String seconds;
	public String minutes;
	public String hours;
	public String dayOfMonth;
	public String month;
	public String dayOfWeek;

	public Cron(String cronString) {
		// Expecting a string like: "0 0 0 * ? /"
		List<String> parts = cronString?.split(' ');
		this.seconds = (String) CollectionUtils.getIndexOf(parts, 0);
		this.minutes = (String) CollectionUtils.getIndexOf(parts, 1);
		this.hours = (String) CollectionUtils.getIndexOf(parts, 2);
		this.dayOfMonth = (String) CollectionUtils.getIndexOf(parts, 3);
		this.month = (String) CollectionUtils.getIndexOf(parts, 4);
		this.dayOfWeek = (String) CollectionUtils.getIndexOf(parts, 5);
	}

	public String expression() {
		List<String> parts = new List<String>{
			this.seconds,
			this.minutes,
			this.hours,
			this.dayOfMonth,
			this.month,
			this.dayOfWeek
		};
		return String.join(parts, ' ');
	}

	public Cron minutesFromNow(Integer minsInFuture) {
		// Alter the minutes value to be X minutes from now
		Integer newMins = DateTime.now().addMinutes(minsInFuture).minute();
		this.minutes = String.valueOf(newMins);
		return this;
	}

	public static Cron hourly() {
		// Utility method to generate an hourly cron job
		// This is the most commonly used cron expression in apex
		return new Cron('0 0 * * * ?');
	}
}
