# SleepNote

SleepNote is simple app to log sleep and wake-up activities. 

## Project Description

SleepNote covers several feature:
- **Sleep Records**: Clock-in and clock-out sleep entries
- **Social Follow System**: Follow and unfollow other users to see their sleep entries
- **Sleep Activity Timeline**: See our friends sleep activities

## Tech Stack

- **Framework**: Ruby on Rails 8.0 (API only)
- **Database**: PostgreSQL
- **Testing**: RSpec

## Setup Instructions

* Clone repository
  ```bash
  git clone git@github.com:rendy-faqot/sleep-note.git
  ```

* Install dependencies
  ```bash
  bundle install
  ```

* Database migration & seed
  ```bash
  rails db:create db:migrate db:seed
  ```

* Start server
  ```bash
  rails s
  ```

## Testing Project

```bash
bundle exec rspec
open coverage/index.html
```

## Endpoints

- `POST /users/:user_id/sleep_records/clock_in`
- `POST /users/:user_id/sleep_records/clock_out`
- `GET /users/:user_id/sleep_records`
- `POST http://localhost:3000/users/:user_id/follow`
- `DELETE http://localhost:3000/users/:user_id/unfollow`

### Example 

```bash
curl -X POST http://localhost:3000/users/1/sleep_records/clock_in

curl -X POST http://localhost:3000/users/1/sleep_records/clock_out

curl http://localhost:3000/users/1/sleep_records

curl -X POST http://localhost:3000/users/1/follow -d "followed_id=2"

curl -X DELETE http://localhost:3000/users/1/unfollow -d "followed_id=2"
```
