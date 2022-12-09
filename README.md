# SAU Portal

## Development VM
Development has been done on a Hyper-V VM built via the Quick Create Action, Ubuntu 20.04 Operating System.

## Prerequisites

- Ruby 2.7.12
- PostgreSQL
- NodeJS 12.13.x
- Yarn 1.12.x

## Setting up the app in development

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data
4. Run `bundle exec rails server` to launch the app on http://localhost:3000
5. Run `./bin/webpack-dev-server` in a separate shell for faster compilation of assets

## Frameworks used

- The development was initiated by cloning the [DFE - GOV.UK Rails Boilerplate](https://github.com/DFE-Digital/govuk-rails-boilerplate)
- [DFE - GOV.UK Design System Formbuilder](https://github.com/DFE-Digital/govuk-formbuilder)
- [DFE - GOV.UK Components](https://github.com/DFE-Digital/govuk-components)


## Running specs, linter(without auto correct) and annotate models and serializers
```
bundle exec rake
```

## Running specs
```
bundle exec rspec
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec rubocop app config db lib spec Gemfile --format clang -a

or

bundle exec scss-lint app/webpacker/styles
```
# Environment variables

The application requires the following environment variables to be configured

| Name | Purpose |
| --- | --- |
| **AZURE_API** | URL for Azure Function
| **GA_TRACKING_ID** | Google Analytics ID
| **GOVUK_NOTIFY_API_KEY** | Key to GOV.UK Notify
| **GOVUK_NOTIFY_ENV** | GOV.UK Notify template set
| **MAINTENANCE_TEXT** | controls use of Service unavailable page and provides message to that page
| **PAP_URL** | Base URL for the PAP service
| **ROLE_MAPPINGS** | Set of mapping between names used in app and Azure App roles or groups
| **STORAGE_ACCESS_KEY** | Azure storage access key
| **STORAGE_ACCOUNT_NAME** | Azure storage account name
| **STORAGE_CONTAINER** | Azure storage container name
| **TRANSPARENCY_LINK** | Url of BEIS Transparency admin portal
| **FEEDBACK_LINK** | Url of Feedback form

When running in development with no authentication configure the following additional variables are needed to represent the user
| Name | Purpose |
| --- | --- |
| **DEV_NAME** | name of user
| **DEV_EMAIL** | email address of user
| **DEV_OID** | oid for user
| **DEV_ROLE** | Roles the user has in the app of the form: '["SAU-Admin","SAU-PA-SU"]'

## Docker

### Why use Docker?
- Run the application locally without installing dependencies (postgres, system libraries...)
- Run in a Linux environment similar to production
- Simulate running in production with dependencies using docker-compose
- Package the application so it can be versioned and deployed to multiple environments

### Prerequisites
- Docker >= 19.03.12

### Build
```
make build-local-image
```

It relies heavily on caching. The first build may be slow and subsequent ones faster.

### Single docker image
The docker image doesn't contain a default command. Any command can be appended:
```
% docker run -p 3001:3000 [image name]:latest rails -vT
rails about                              # List versions of all Rails frameworks and the environment
...
```

## Licence

[MIT License](LICENCE)
