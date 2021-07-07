# Rails API Template

[![Gem](https://img.shields.io/gem/v/rails?label=rails)](https://rubygems.org/gems/rails)
[![Badge](https://img.shields.io/badge/ruby-v2.7.1-blue)](https://www.ruby-lang.org/en/news/2020/03/31/ruby-2-7-1-released/)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)

This template is built to start a barebones rails API.
The following gems are already integrated into the project.
* [PostgreSQL](https://www.postgresql.org/) is used for the database
* [RSpec](https://github.com/rspec/rspec-rails) is used for the testing framework
* [Rspec API Documentation](https://github.com/zipmark/rspec_api_documentation) is included to generate tests based on the rspec tests in the acceptance folder
* [Brakeman](https://github.com/presidentbeef/brakeman) is used to scan the application for vulnerabilities, can be included in the build process before deployment
* [Active Admin](https://github.com/activeadmin/activeadmin) can be used to view and manage the data within the API.

## Project Setup
### Install Ruby
Version 2.7.1 is the inital version required for this project. It can be downloaded [here](https://www.ruby-lang.org/en/news/2020/03/31/ruby-2-7-1-released/) or use a Ruby version manager to install several versions such as [rbenv](https://github.com/rbenv/rbenv).
### Install Postgresql
[Postgresql](https://www.postgresql.org/download/) must be installed locally to create and manage the database that will be used in this project.
### Terminal Setup
```
# Change your local git hooks path
git config --local core.hooksPath .githooks/
# Install all of the dependencies
bundle install
# Create the development and test databases
rails db:create
# Run any migrations that have been created
rails db:migrate
# Seed the db with data such as the initial admin user
rails db:seed
# Start the rails server
rails s
```

## Active Admin
Regular users can have admin privileges that will allow them to access the admin panel. Users with admin privileges can easily view and modify data in the database.

### Generate New Admin Page
To generate an admin page for a resource use the following command replacing ```User``` with the model you are creating the page for.
```
rails g active_admin:resource User
```
This will create a file at the following path, ```app/admin/users.rb```.
More info on generating resources and defining functionality for an admin page can be found in the [Active Admin Documentation](https://activeadmin.info/2-resource-customization.html#rename-the-resource).

### Customize Styles
You can modify the styles of the current active admin theme in the ```app/assets/stylesheets/active_admin.scss``` file. An example for this repo has been added to the file to change the colors of the current theme.

## RuboCop
[RuboCop](https://docs.rubocop.org/rubocop/1.2/index.html) is provided to keep the ruby section of the codebase clean.

The configuration of RuboCop can be changed in the ```.rubocop.yml``` file. It is currently setup to use the rails and rspec rubocop gems and to ignore certain folders and files that do not need to be linted.

## SimpleCov
[SimpleCov](https://github.com/simplecov-ruby/simplecov) is included to help provide insight on the amount of code is covered by the test suite.

The configuration of SimpleCov can be changed in the ```spec/spec_helper.rb``` file.

Coverage results can be viewed locally after running ```bundle exec rspec``` in the ```coverage/index.html``` file.

Builds in CircleCI generate the results automatically in the artifacts section to provide record of the code coverage throughout builds.