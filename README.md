# MrPostman

MrPostman is an approach to solve the [Homeday](https://www.homeday.de/de/) coding challenge, its goal is basically to be able to parse a string containing different levels of addresses informations, normalize this data and return it in a spplited, more sane format for future usage.

## Questions

* Given that `postal_code` seems to be a fairly easy and useful information to get, shouldn't it be returned with the rest of the response object?

## Choices

### Sinatra
I've been considering doing something with Sinatra again after some years and the challenge seemed like a great fit. It was also an effort to try to keep it as minimal as possible.

### Google's Geocoding API
Reading the requirements at first made me quite worried on how to parse and "guess" the details of each type of address, then understanding that using Google's API was a choice it just seemed like the best approach to avoid reinventing the wheel.

### Removing Xs from the parameters
Testing a couple of examples from */data/addresses.txt* I saw a few that had weird "xx" and "xxx", they seemed like placeholders for a missing information. When testing against Google's Geocoding API in general they seemed to perform way better by just removing the placeholders.

### Input and output
Considering that the system should just receive one string through one endpoint and return a key:value it was pretty clear that returning a JSON object would be the way to go here. I considered adding a database to store the normalized return but since the description doesn't ask I chose to focus on trying to curate as many addresses as possible.

### The "ELEMENTS" constant
This was one approach to check the many components and their types that might come from the Google's API. Even though it might've made the creation of the `results` variable a bit obscure it also allows us to easily add or remove attributes we might want from the Google's API response by editing `ELEMENTS`.

## Improvements

* Find a more elegant way to convert the response to json?

* Explicitly call `subject` when testing to be clearer?

* There's still some use cases to be tested and some work to be done on handling weird requests or "zero results" situations.
