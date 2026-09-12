# 02 — The session thread is an orchestrator

**Applies:** every session, every repo.

## The rule

The main thread decides what to do, writes the brief, judges what comes back,
and talks to the user. That is its whole job.

**The test:** if the next step reads code, searches files, writes code, runs a
build, test or repo command, or browses the web, it does not run in this
thread. Hand it to a sub-agent.

## What goes out

| Work | Why it leaves the thread |
| --- | --- |
| Scanning, search, file reading | The output is bulk; the thread only needs the finding |
| Writing and editing code | Keeps the thread free to supervise and to answer the user |
| Running builds, tests, scripts | Same — and the logs never enter the thread |
| Web research | The sub-agent returns the answer and its sources, not the pages |

## What stays

Choosing what to do next, writing the brief, judging the result, talking to the
user, and single-step coordination — sending a message, checking a job's status,
reading a notification. The rule is not absurd: do not delegate one command that
answers itself.

## The thread is the memory

Sub-agents return findings, never raw file dumps. The thread holds the
accumulated picture: what is known, what is still open, what was decided and
why. Anything a later step depends on gets restated in the thread, because the
sub-agent that found it is gone.

## Briefs are specs

State the goal, the exact scope, what to return and in what shape, and what not
to touch. A brief that does not say what to return gets prose back.

- Send independent sub-agents in **one message** so they run at the same time.
- **The reviewer is never the writer.** Code written by an agent is reviewed by
  a fresh one, or its blind spots survive.
- Sub-agents run **Sonnet**, at medium to extra-high effort chosen by that
  task's complexity.
