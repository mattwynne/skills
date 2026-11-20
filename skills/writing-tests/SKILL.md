---
name: writing-tests
description: Use when writing, changing, or reviewing tests to choose useful coverage and keep feedback fast through isolation.
---

Automated tests are valuable, but they also have a cost. Every automated test you add to the codebase must justify its
place on the cost/benefit curve.

# First ask what needs to exist

First, ask whether the behavior and code being tested are needed at all. Removing unnecessary behavior is better than building a test harness around it. Simplify first.

# The value of a test

Tests protect us against risk of the code changing behaviour in unexpected, unwanted ways. A given automated test's
value is a function of two factors:

* Volatility: How likey is this code to change?
* Impact: How bad would it be if it broke?

In practice this means we want to avoid testing code that never changes, or where the impact of it breaking is low.

Test code that users depend on, not everything we can execute. Tests for our own internal tooling are exceptional: add
them only when the logic is especially complex. Make tests fast by isolating decisions from external machinery using ports and adapters.

## Things you probably shouldn't test

Do not routinely test internal scripts or agent tooling; first explain why the logic is complex enough to warrant the exception.

Do not write tests that read configuration or deployment recipes and match strings, ordering or snapshots. Do not build simulated deployment suites that reimplement a tool's interpretation of its configuration. Verify Ansible recipes by using Ansible; use the owning tool for other declarative configuration too. Don't reproduce dependencies' regression suites.

A security label does not make source-text assertions useful or create an exception to this boundary. Custom authorization decisions can be tested as logic; whether an operating system actually enforces permissions requires verification in that environment. Neither is proved by finding a directive in a file.

This choice leaves some configuration mistakes to be discovered during actual use. Be honest about that limitation rather than claiming a text assertion proves deployment behavior.

## Things you absolutely must test

For code users depend on, test core domain logic: decisions, parsing, calculations, failure handling and lifecycle rules.

For behavior we need, name the observable mistake the test should catch and check whether existing coverage already catches it.

assert useful results or effects, not private implementation details, source spelling, framework behavior or arbitrary coverage quotas. A test should survive a refactor that preserves behavior.

# The cost of a test

Every test adds a carry-cost to the codebase: cost to wait for it to finish, cost to maintain it as the code changes.

The value of the test must justify this cost. Fast tests that are coupled to stable interfaces are lower cost than slow
tests that are coupled to unstable or fragile interfaces.

Cost is a function of:

* Duration
* Reliability
* Coupling (to the code under test)

Aim to lower the cost of the test by making it as fast as possible, as reliable as possible, and with highly modular coupling to the codebase.

## Listening to the tests

If a test is slow, brittle to changes in the code, hard to write, or requires complex mocking or other test setup, then examine the design of the code under test. Testing not only tests behaviour, it tests modularlity and software design. Well-designed code is easy to test, so code that is hard to test is generally badly designed. Instead of fighting the design with a complex test setup, take a step back and reconsider the design.

> First make the change easy (warning: this is hard), then make the easy change. -- Kent Beck

## Isolate decisions with ports and adapters

A **port** is a narrow, explicit collaborator through which core logic requests an external operation. An **adapter** implements that operation using a filesystem, process, service or library. Core logic receives these collaborators instead of constructing the external machinery itself; tests supply small in-memory doubles with explicit inputs and outcomes.

Use existing boundaries where possible. Don't mock private methods, duplicate production algorithms in fakes, or introduce a generic framework or production abstraction solely to fake everything. If code mixes a useful decision with expensive effects, separate that decision with the smallest coherent change.

Choose the smallest test boundary that can catch the named mistake:

- **Rule tests:** supply typed inputs and collaborators; check decisions, outputs and requested effects. No filesystem, subprocess, network or full shared-library setup unless the behavior depends on it.
- **Adapter tests:** check our delegation, arguments, mapping and error translation at one boundary. Substitute the adjacent collaborator where that proves our behavior; don't repeat every rule case through the adapter.
- **Real-boundary tests:** keep the minimum checks whose behavior genuinely depends on actual machinery, such as socket framing, kernel locks, file publication or process cleanup. State what requires that boundary and substitute unrelated dependencies. A temporary directory or mocked command executable still incurs real I/O and process costs.

For example, test a change decision with supplied old/new facts, not a build merely to manufacture those facts. Test command selection through a recording collaborator; use a real process when testing process behavior, not just to host a mock.

## Control time and measure the result

Supply clocks or schedulers for deadline rules. Synchronize concurrent work on explicit admission and completion signals, not sleeps. Don't wait out production deadlines to prove timeout handling; retain only the actual boundary needed for the claim.

Make resource limits injectable so boundary tests can use small inputs and thresholds without changing production defaults. Prove rejection, early stopping and cleanup without generating production-scale data merely to exceed a limit. Keep realistic-volume acceptance checks separate, and retain them only when scale itself matters to the claim.

# Before accepting a test change:

- Does each assertion catch a useful mistake at the smallest boundary?
- Can setup, repeated I/O or redundant cases be removed?
- Run the focused tests and the whole relevant gate; measure actual duration, including setup and builds. Don't call a runtime acceptable without questioning necessity and isolation.
- Describe coverage retained, removed or lost, and the runtime cost honestly. Don't hide flakes with retries or skips.

These are working guidelines, not a requirement for a new ADR, task or report for every test.
