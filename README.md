# SpotifyExampleApp

This Code is an Example using [Clean Architecture](https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html)

## Description

This is an Spotify Example app, which fetches the Artists and Albums using the [Spotify API](https://developer.spotify.com/console).
The UseCases are represented by protocols, this allow to have the implementations away from the interfaces so the chossed implementation can be injected applying the [Dependency Inversion Principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle).
There is a Controller per UseCase that use it to get the data and handle the states to be presented in the UI.

Using this approach each layer can be tested with out dependencies to each other and incite the [Single responsibility principle](https://en.wikipedia.org/wiki/Single_responsibility_principle).
Use Cases can be mocked and Controllers states can be tested using this mocks.

# Attribution
This product uses the [Spotify Web API](https://developer.spotify.com/).

# License
MIT License
