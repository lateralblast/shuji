# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.6] - 2026-10-04

### Added

- `-s` imports an SSH config file (default `~/.ssh/config`, or the file given with `-i`) instead of a hosts file. Each `Host` alias becomes a menu entry running `ssh <alias>`, grouped by the domain of its `HostName`. Wildcard and negated patterns, and `Match` blocks, are ignored.

## [0.1.5] - 2026-10-04

### Changed

- Split the conversion into `parse_host_line`, `host_entry`, `resolve_terminal`, `parse_options` and `main`, and run `main` only when the script is executed directly.
- Replaced the loose top-level variables with constants and removed the parameters that only passed them around.
- Missing-file and invalid-terminal errors now go through `abort`, so they print to stderr and exit non-zero.

## [0.1.4] - 2026-10-04

### Changed

- Style clean-up: `# frozen_string_literal: true`, string interpolation instead of concatenation, `match?` for boolean checks, `File.foreach`/`File.write`, and the version header is read from `__FILE__` instead of `$0`.

## [0.1.3] - 2026-10-04

### Added

- Missing Ruby modules (`getopt`, `json`) are installed with `gem install --user-install` at startup, then loaded.

## [0.1.2] - 2026-10-04

### Fixed

- Emit one object per domain in `hosts` (as Shuttle's config format shows) instead of a single object holding every domain.

## [0.1.1] - 2026-10-04

### Fixed

- Corrected the `# URL:` header, which pointed at `faust`.

## [0.1.0] - 2026-10-04

### Fixed

- Replaced the `[A-z]` character class (which also matches `[ \ ] ^ _` and backtick) with `[A-Za-z]`.
- `-o` file names without letters (e.g. `-o 123`) were treated as stdout; stdout is now selected only by `-t`.

## [0.0.9] - 2026-10-04

### Fixed

- A multi-word trailing comment no longer collapses into one word (`# my user` gave `myuser`); the first word is used as the SSH user.

## [0.0.8] - 2026-10-04

### Fixed

- `-l` was missing from the option string and always printed usage; it now takes a value (`-l no` disables launch at login).

## [0.0.7] - 2026-10-04

### Fixed

- `-T` always failed because the `.app` suffix check was inverted; `-T iTerm` and `-T iTerm.app` now both work.

## [0.0.6] - 2026-10-04

### Fixed

- Host lines with leading whitespace were parsed with the IP address as the host name.

## [0.0.5] - 2026-10-04

### Fixed

- Lines containing only an IP address no longer crash the script; they are skipped.

## [0.0.4] - 2026-10-04

### Fixed

- A host line ending in an empty `#` comment no longer crashes the script.

## [0.0.3] - 2026-10-04

### Fixed

- The output file is only written after the JSON is fully built, so a parse error can no longer leave `~/.shuttle.json` truncated.

## [0.0.2] - 2026-10-04

### Fixed

- Running with no flags, or with only `-i`, no longer overwrites `~/.shuttle.json`. One of `-t`, `-j` or `-o` is now required (`-o` implies `-j`).

## [0.0.1] - 2014-08-25

### Added

- Initial version.
