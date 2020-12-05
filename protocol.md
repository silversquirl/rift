Rift Protocol
=============

A rift data stream is made up of a sequence of events.
Events are encoded as a decimal time in microseconds, an ASCII space, an event type, and finally an ASCII line feed.

The different types of event are documented below.

BEGIN
-----

Starts a new run, setting the epoch to the event time.

END
---

Ends the current run.

SPLIT
-----

Moves to the next split. If the current split is the final split, does the same thing as an END event.

TIME
----

Signals the current time. Should be sent at least once per centisecond (100th of a second).
