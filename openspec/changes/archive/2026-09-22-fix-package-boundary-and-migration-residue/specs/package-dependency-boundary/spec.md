## Purpose

Defines what a shared package may impose on the applications that depend on it, and how an
internal staging area must declare its own status, so that a consumer's dependency graph and a
contributor's reading of "work in progress" both stay honest.

## ADDED Requirements

### Requirement: A Tool Used Only To Develop The Package MUST NOT Reach Its Consumers

A dependency that exists to build, document or catalogue the package MUST be declared so that
it is not inherited by applications depending on it. Declaring such a tool as a runtime
dependency silently enlarges every consumer's dependency graph and its shipped surface.

#### Scenario: A catalogue or documentation tool is declared

- **GIVEN** a package used to develop, document or catalogue this package rather than to
  implement its runtime behaviour
- **WHEN** it is declared in the manifest
- **THEN** it MUST be declared in the development section
- **AND** it MUST NOT appear in the section consumers inherit

#### Scenario: A consumer resolves its dependencies

- **GIVEN** an application depending on this package
- **WHEN** its dependency graph is resolved
- **THEN** no development-only tool of this package MUST appear in it

#### Scenario: A development tool is genuinely required at runtime

- **GIVEN** a tool that must remain a runtime dependency
- **WHEN** it is retained in the consumer-inherited section
- **THEN** the reason MUST be recorded where the declaration is, so the placement is readable
  as a decision rather than an oversight

### Requirement: A Staging Area MUST Contain Work Or Not Exist

A directory designated for work in progress MUST either hold that work or be removed. An empty
staging area reads as active migration, which misleads a contributor about what remains to be
done and about where new work belongs.

#### Scenario: The staging directory holds no source

- **GIVEN** a directory reserved for in-progress components
- **WHEN** it contains no implementation
- **THEN** it MUST be removed, or its continued existence MUST be justified by a recorded,
  currently-true statement about what it is waiting for

#### Scenario: A component is genuinely mid-migration

- **GIVEN** a component that has not reached public stability
- **WHEN** it is placed in the staging area
- **THEN** it MUST NOT be exported from the package's public surface
- **AND** consumers MUST NOT import it directly

### Requirement: A Repository-Wide Reformat MUST Be A Recorded Decision, Not A Side Effect

A formatting pass that rewrites a large fraction of the package MUST be taken as its own
decision and carried out in isolation. Folded into another change, it buries the substantive
diff, and performed piecemeal it leaves the package permanently split between two styles.

#### Scenario: A contributor changes a small number of files

- **GIVEN** a change touching a few files
- **WHEN** formatting is applied
- **THEN** it MUST be applied only to the files that change
- **AND** it MUST NOT reformat unrelated files

#### Scenario: A whole-package reformat is proposed

- **GIVEN** a proposal to reformat the package
- **WHEN** it is carried out
- **THEN** it MUST be its own change containing no functional edits
- **AND** the toolchain version that produced the formatting MUST be recorded, so the result is
  reproducible rather than dependent on whichever version the author happened to run

#### Scenario: Formatting is not enforced automatically

- **GIVEN** no automated check enforces this package's formatting
- **WHEN** the divergence is observed
- **THEN** either the check MUST be added or the absence MUST be recorded, so the state is a
  decision rather than an accident
