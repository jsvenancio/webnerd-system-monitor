# Publication review — experimental 0.4.1

Prepared on 2026-11-22 for the existing `jsvenancio/webnerd-system-monitor` repository.

## Completed

- Download/upload charts with independent local sampling and interface selection.
- Compact full-content layout without a scroll bar, confirmed on the maintainer’s Nobara Linux 44 / KDE Plasma 6 desktop.
- Background-opacity preview, Apply persistence and discard restoration confirmed by the maintainer.
- Automatic Ctrl+Alt+M assignment reported successful by the local setup helper; editable native shortcut settings retained.
- Native author portfolio and labelled project links; existing contact help retained pending a future form.
- Six collector/network tests passed; shell syntax and Python compilation checks passed.
- Standalone HTTP endpoint returned a valid network extension in the isolated workspace, whose network exposes no non-loopback interface; numerical rate calculations covered by deterministic tests and actual interface readings confirmed on the maintainer’s ASUS.
- Private service configuration, credentials, network identifiers and personal screenshots excluded from the public source.

## Limits

Experimental source update. Other distributions/hardware, IPv6-only automatic selection, live shortcut-conflict/multiple-widget behavior and the complete standalone desktop-service install/removal flow remain unverified. Small widget sizes reduce text size. Network rates include local traffic and are not speed-test results.

## Scope

Update the existing Linux repository only. No Windows repository, new infrastructure service, tag or GitHub release is included. The local ASUS adapter is separate from the public source; its existing collector, sender and Mission Control integration remain independent.

## Publication

The initial public repository was authorized and published on 2026-11-11. The owner explicitly authorized the 0.4.1 commit and push on 2026-11-22. No separate tag or GitHub release was requested.
