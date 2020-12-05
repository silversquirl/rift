Rift Protocol
=============

A rift data stream is made up of a sequence of events.
Events are encoded as a decimal time in microseconds, an ASCII space, an event type, and finally an ASCII line feed.
If no event name is provided, the space may be omitted.

Before any event is processed, the current time is set to the value specified.

The different types of event are documented below.

BEGIN
-----

Start a new run.

RESET
-----

Stop any active run, update the displayed time and reset all splits.

SPLIT
-----

Moves to the next split. If the current split is the final split, does the same thing as an END event.
