<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
    <img src="static/logo.png" alt="Logo" width="250" height="250">

  <h3 align="center">Lightbug</h3>

  <p align="center">
    Simple and fast HTTP framework for Mojo! 🔥
    <br/>

   ![Written in Mojo][language-shield]
   [![MIT License][license-shield]][license-url]
   [![Contributors Welcome][contributors-shield]][contributors-url]
   

  </p>
</div>

## Overview

Lightbug is a simple and sweet HTTP framework for Mojo that builds on best practice from systems programming, such as the Golang [FastHTTP](https://github.com/valyala/fasthttp/) and Rust [may_minihttp](https://github.com/Xudong-Huang/may_minihttp/). 

This is not production ready yet. We're aiming to keep up with new developments in Mojo, but it might take some time to get to a point when this is safe to use in real-world applications.

Lightbug currently has the following features:
 - [x] Set up a server to listen on a given host/port
 - [x] Assign your own custom handler to a route
 - [x] Craft HTTP requests and responses with built-in primitives
 - [x] Everything is fully typed, with no `def` functions used


We're working on support for the following (contributors welcome!):
 - [ ] Pure Mojo networking (while most of the code is in Mojo, we call Python's `socket` library in several parts of the code)
 - [ ] More request body types (currently only `text/plain`)
 - [ ] Better error handling 
 - [ ] Multiple simultaneous connections, parallelization and performance optimizations/benchmarks
 - [ ] WebSockets, HTTP 2.0

The test coverage is also something we're working on.

The plan is to get to a feature set similar to Python frameworks like [Starlette](https://github.com/encode/starlette), but with better performance.


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

The only hard dependency for `lightbug_http` is Mojo. 
Learn how to set it up on the [Modular website](https://www.modular.com/max/mojo).

Once you have Mojo up and running on your local machine,

1. Clone the repo
   ```sh
   git clone https://github.com/saviorand/mojo-web
   ```
   Alternatively, start the project in Github Codespaces for quick setup:
   
   [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/saviorand/lightbug_http)
2. Add your handler in `main.mojo` by passing a struct that satisfies the following trait:
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
3. Run `mojo main.mojo`. This will start up a server listening on `localhost:8080`. Or, if you prefer to import the server into your own app:
   ```mojo
   from lightbug_http.io.bytes import Bytes
   from lightbug_http.python.server import PythonServer
   from lightbug_http.service import Printer


   fn main() raises:
      var server = PythonServer()
      let handler = Printer()
      server.listen_and_serve("0.0.0.0:8080", handler)
   ```

   Feel free to change the settings in `listen_and_serve()` to serve on a particular host and port.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

<div align="center">
    <img src="static/roadmap.png" alt="Logo" width="695" height="226">
</div>

Our vision is to develop three libraries, with `lightbug_http` (this repo) as a starting point: 
 - `lightbug_http` - HTTP infrastructure and basic API development
 - `lightbug_api` - Tools to make great APIs fast, with support for OpenAPI spec and domain driven design
 - `lightbug_web` - Full-stack web framework for Mojo, similar to NextJS or SvelteKit

The idea is to get to a point where the entire codebase of a simple modern web application can be written in Mojo. 

We don't make any promises, though -- this is just a vision, and whether we get there or not depends on many factors, including the support of the community.


See the [open issues](https://github.com/othneildrew/Best-README-Template/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**. See [CONTRIBUTING.md](./CONTRIBUTING.md) for more details on how to contribute.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

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

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

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