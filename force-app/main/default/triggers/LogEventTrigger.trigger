trigger LogEventTrigger on Log_Event__e(after insert) {
	new LogEventHandler().run();
}
