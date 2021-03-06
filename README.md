# MrPostman

MrPostman is an approach to solve the [Homeday](https://www.homeday.de/en/) coding challenge, its goal is basically to be able to parse a string containing different levels of addresses informations, normalize this data and return it in a spplited, more sane format for future usage.

## Dependencies and setup

The app was built with the idea of being as simple and lean as possible, therefore it just requires Ruby 2.4.2 and the `bundler` gem. To run it locally just follow the steps:

```bash
$ git clone git@github.com:miguelgraz/mrpostman.git
$ cd mrpostman
$ bundle
$ rackup
```

And it should be running on http://localhost:9292 allowing you to use the parser by accessing  
http://localhost:9292/parse?address=YOURADDRESS

Alternatively it is also running as a Heroku app so the same behaviour might be seen by accessing  
https://mr-homeday-postman.herokuapp.com/parse?address=ADDRESSTOBEPARSED

## Choices

### Sinatra
I've been considering doing something with Sinatra again after some years and the challenge seemed like a great fit. It was also an effort to try to keep it as minimal as possible.

### Google's Geocoding API
Reading the requirements at first made me quite worried on how to parse and "guess" the details of each type of address, then understanding that using Google's API was a choice it just seemed like the best approach to avoid reinventing the wheel.

### Removing Xs from the parameters
Testing a couple of examples from */data/addresses.txt* I saw a few that had weird "xx" and "xxx", they seemed like placeholders for a missing information. When testing against Google's Geocoding API in general they seemed to perform way better by just removing the placeholders.

### Input and output
Considering that the system should just receive one string through one endpoint and return a key:value it was pretty clear that returning a JSON object would be the way to go here. I considered adding a database to store the normalized return but since the description doesn't ask I chose to focus on trying to curate as many addresses as possible.

### The `ELEMENTS` constant
This was one approach to check the many components and their types that might come from the Google's API. Even though it might've made the creation of the `results` variable a bit obscure it also allows us to easily add or remove attributes we might want from the Google's API response by editing `ELEMENTS`.

## Questions

* Given that `postal_code` seems to be a fairly easy and useful information to get, shouldn't it be returned with the rest of the response object?

## Possible Future Improvements

* Find a more elegant way to convert the response to json?

* Explicitly call `subject` when testing to be clearer?

* Weird, intermittent failing specs due to Google returning a `"OVER_QUERY_LIMIT"` when there's still quota :thinking:

* Warning from `rack/query_parser` due to a regex match against a non-UTF-8 string

* Have a clearer message for unexpected problems when using Google's API, like a proper handler for network problems

* Have a number of preset `API_KEY`s and when receive a "OVER_QUERY_LIMIT" error change the configuration to the next `API_KEY`, try the same request again

* Split the `spec/mrpostman_spec.rb` tests in two different files to improve readability?
