# TranslationsChecker


This Gem provides checks for translation placeholders. It checks for:

* Locale strings that have been added to `en`, but not to other locales
* Locale strings that have been removed from `en`, but not from other locales
* Locale strings that have been added to all locales, but do not have the correct placeholder label in non-`en` locales (eg. `[ja]`)

This is related to the ["Crowdin" work](https://locomote.atlassian.net/browse/LM-3557) and is [used in TMP](https://github.com/locomote/travel_management_platform/pull/3720) via a git pre-push hook.

## Installation

Added to Gemfile:
```
gem "translations_checker", git: "git@github.com:locomote/translations_checker.git", branch: "master", require: false
```

## Usage

```
bundle exec translations_checker
```
