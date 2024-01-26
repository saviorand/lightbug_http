<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
    <img src="static/logo.png" alt="Logo" width="250" height="250">

  <h3 align="center">Lightbug</h3>

  <p align="center">
    🐝 A Mojo HTTP framework with wings 🔥
    <br/>

   ![Written in Mojo][language-shield]
   [![MIT License][license-shield]][license-url]
   [![Contributors Welcome][contributors-shield]][contributors-url]
   [![Join our Discord][discord-shield]][discord-url]
   
   

  </p>
</div>

## Quickstart with Docker
To set up Lightbug in one command:
1. Get [Docker](https://docs.docker.com/get-docker/) or open the project in Codespaces where Docker is already installed:
   
   [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/saviorand/lightbug_http)
2. Copy the contents of the `.mojoenv.example` file at the root of this repo into a new file called `.mojoenv`. 

   Replace `<your_modular_auth_token>` with your Modular access token (you can find it [here](https://developer.modular.com/download))
3. Run
   ```bash
   make lightbug
   ```

Lightbug will start and listen for requests on [`http://localhost:8080`](http://localhost:8080). Enjoy!

## Overview

Lightbug is a simple and sweet HTTP framework for Mojo that builds on best practice from systems programming, such as the Golang [FastHTTP](https://github.com/valyala/fasthttp/) and Rust [may_minihttp](https://github.com/Xudong-Huang/may_minihttp/). 

This is not production ready yet. We're aiming to keep up with new developments in Mojo, but it might take some time to get to a point when this is safe to use in real-world applications.

Lightbug currently has the following features:
 - [x] Pure Mojo networking! No dependencies on Python by default
 - [x] Set up a server to listen on a given host/port
 - [x] Assign your own custom handler to a route
 - [x] Craft HTTP requests and responses with built-in primitives
 - [x] Everything is fully typed, with no `def` functions used


We're working on support for the following (contributors welcome!):
 - [ ] Better error handling, improved form/multipart and JSON support
 - [ ] Multiple simultaneous connections, parallelization and performance optimizations
 - [ ] WebSockets, HTTP 2.0

The test coverage is also something we're working on.

The plan is to get to a feature set similar to Python frameworks like [Starlette](https://github.com/encode/starlette), but with better performance.


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

The only hard dependencies for `lightbug_http` are Mojo and [Git](https://docs.github.com/en/get-started/getting-started-with-git). 
Learn how to get up and running with Mojo on the [Modular website](https://www.modular.com/max/mojo).

Once you have Mojo set up locally,

1. Clone the repo
   ```sh
   git clone https://github.com/saviorand/lightbug_http.git
   ```
2. Switch to the project directory:
   ```bash
   cd lightbug_http
   ```
   then run:
   ```bash
   mojo lightbug.🔥
   ```
   
   Open `localhost:8080` in your browser. You should see a welcome screen. 
   
   Congrats 🥳 You're using Lightbug!
2. Add your handler in `lightbug.🔥` by passing a struct that satisfies the following trait:
   ```mojo
   trait HTTPService:
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        ...
   ```
   For example, to make a `Printer` service that simply prints the request to console:
   ```mojo
   @value
   struct Printer(HTTPService):
      fn func(self, req: HTTPRequest) raises -> HTTPResponse:
         let body = req.body_raw
         print(String(body))

         return OK(body)
   ```
   Routing is not in scope for this library, but you can easily set up routes yourself:
   ```mojo
   @value
   struct ExampleRouter(HTTPService):
      fn func(self, req: HTTPRequest) raises -> HTTPResponse:
         let body = req.body_raw
         let uri = req.uri()

         if uri.path() == "/":
               print("I'm on the index path!")
         if uri.path() == "/first":
               print("I'm on /first!")
         elif uri.path() == "/second":
               print("I'm on /second!")
         elif uri.path() == "/echo":
               print(String(body))

         return OK(body)
   ```
   
   We plan to add routing in a future library called `lightbug_api`, see [Roadmap](#roadmap) for more details.
3. Run `mojo lightbug.🔥`. This will start up a server listening on `localhost:8080`. Or, if you prefer to import the server into your own app:
   ```mojo
   from lightbug_http.sys.server import SysServer
   from lightbug_http.service import Printer


   fn main() raises:
      var server = SysServer()
      let handler = Printer()
      server.listen_and_serve("0.0.0.0:8080", handler)
   ```
   Feel free to change the settings in `listen_and_serve()` to serve on a particular host and port.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Switching between pure Mojo and Python implementations
By default, Lightbug uses the pure Mojo implementation for networking. To use Python's `socket` library instead, just import the `PythonServer` instead of the `SysServer` with the following line:
```mojo
from lightbug_http.python.server import PythonServer
```
You can then use all the regular server commands in the same way as with the default server.

<!-- ROADMAP -->
## Roadmap

<div align="center">
    <img src="static/roadmap.png" alt="Logo" width="695" height="226">
</div>

Our vision is to develop three libraries, with `lightbug_http` (this repo) as a starting point: 
 - `lightbug_http` - HTTP infrastructure and basic API development
 - `lightbug_api` - (coming later in 2024!) Tools to make great APIs fast, with support for OpenAPI spec and domain driven design
 - `lightbug_web` - (release date TBD) Full-stack web framework for Mojo, similar to NextJS or SvelteKit

The idea is to get to a point where the entire codebase of a simple modern web application can be written in Mojo. 

We don't make any promises, though -- this is just a vision, and whether we get there or not depends on many factors, including the support of the community.


See the [open issues](https://github.com/saviorand/lightbug_http/issues) and submit your own to help drive the development of Lightbug.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**. See [CONTRIBUTING.md](./CONTRIBUTING.md) for more details on how to contribute.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

[Valentin Erokhin](https://www.valentin.wiki/)

Project Link: [https://github.com/saviorand/mojo-web](https://github.com/saviorand/mojo-web)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

We were drawing a lot on the following projects:

* [FastHTTP](https://github.com/valyala/fasthttp/) (Golang)
* [may_minihttp](https://github.com/Xudong-Huang/may_minihttp/) (Rust)
* [FireTCP](https://github.com/Jensen-holm/FireTCP) (One of the earliest Mojo TCP implementations!)


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[language-shield]: https://img.shields.io/badge/language-mojo-orange
[license-shield]: https://img.shields.io/github/license/saviorand/lightbug_http?logo=github
[license-url]: https://github.com/saviorand/lightbug_http/blob/main/LICENSE
[contributors-shield]: https://img.shields.io/badge/contributors-welcome!-blue
[contributors-url]: https://github.com/saviorand/lightbug_http#contributing
[discord-shield]: https://img.shields.io/discord/1192127090271719495?style=flat&logo=discord&logoColor=white
[discord-url]: https://discord.gg/VFWETkTgrr
