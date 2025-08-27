# SETUP
requires rails 8, ruby 3.3, sqlite3

rails db:migrate
rails db:setup

START
```bin/dev


# Notes
  It was a lovely test, thank you very much. Plase let me know what you think.

  I believe all of the requirements have been convered.

  Some choices that I made outside of the scope:

  For assing and unassingn it's using turbo streams to do it without page reloads.

  I used rspec for tests

  Questionable choices:

  - I used also this "active_interactions" gem which I like because it makes the service object conventional. Opinionated way of doing service object as I seen people do it in many different ways
