# Spelling

Create weekly spelling word lists with a sound recording of each word, and practice them with interactive activities. 

## To run

First clone the repo and set up the dependencies:

```
git clone https://github.com/darrensiegel/spelling
mix deps.get
cd spelling/assets
npm install
cd ..
```

Then init the database. With an instance of Postgres running:

```
mix ecto.create
mix ecto.migrate
```

Finally, start the server and visit localhost:4000

```
mix phx.server
```