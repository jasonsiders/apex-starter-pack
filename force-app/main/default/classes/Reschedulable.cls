global abstract class Reschedulable implements System.Schedulable, TypeAware {
	// An abstract type which can be used to quickly implement self-rescheduling
	// By default, Salesforce does not allow for reschedule intervals < 60 minutes
	// Callers can extend this class & implement their own interval (ex., run every 10 minutes)
	global abstract void doScheduledActions(System.SchedulableContext context);
	global abstract Integer getInterval();
	global abstract Type getType();

	global virtual void execute(System.SchedulableContext context) {
		System.debug(LoggingLevel.INFO, 'Running ' + this.getType() + ': ' + context?.getTriggerId());
		this.doScheduledActions(context);
		this.reschedule(context?.getTriggerId());
	}

	global virtual Id reschedule(Id currentJobId) {
		// Deletes any existing jobs of this type, then schedules a new one for the defined interval
		List<AsyncApexJob> pendingJobs = this.getPendingJobs();
		this.abortJobs(pendingJobs);
		return this.scheduleNewJob();
	}

	global virtual List<AsyncApexJob> getPendingJobs() {
		return AsyncUtils.getPendingJobs(this.getType(), null);
	}

	global virtual void abortJobs(List<AsyncApexJob> jobs) {
		for (AsyncApexJob job : jobs) {
			String jobName = job?.CronTrigger?.CronJobDetail?.Name;
			Id jobId = job?.CronTriggerId;
			if (jobId != null) {
				System.debug(LoggingLevel.INFO, this.getType() + ': Aborting ' + jobName + ' [' + jobId + ']');
				System.abortJob(jobId);
			}
		}
	}

	global virtual Id scheduleNewJob() {
		Type jobType = this.getType();
		String jobName = String.valueOf(jobType);
		String cronExp = Cron.hourly().minutesFromNow(this.getInterval())?.expression();
		Reschedulable newInstance = (Reschedulable) jobType?.newInstance();
		Id newJobId = System.schedule(jobName, cronExp, newInstance);
		System.debug(
			LoggingLevel.INFO,
			this.getType() +
			': Scheduled new job: ' +
			newJobId +
			'|' +
			jobName +
			'|' +
			cronExp
		);
		return newJobId;
	}
}
