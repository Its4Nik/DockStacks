# [Dozzle](https://dozzle.dev/)

Dozzle is a small lightweight application with a web based interface to monitor Docker logs. It doesn’t store any log files. It is for live monitoring of your container logs only.

[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/amir20/dozzle)](https://hub.docker.com/r/amir20/dozzle/)
[![Docker Pulls](https://img.shields.io/docker/pulls/amir20/dozzle.svg)](https://hub.docker.com/r/amir20/dozzle/)
[![Docker Version](https://img.shields.io/docker/v/amir20/dozzle?sort=semver)](https://hub.docker.com/r/amir20/dozzle/)
![Test](https://github.com/amir20/dozzle/workflows/Test/badge.svg)

## Features

- Intelligent fuzzy search for container names 🤖
- Search logs using regex 🔦
- Search logs using [SQL queries](https://dozzle.dev/guide/sql-engine) 📊
- Small memory footprint 🏎
- Split screen for viewing multiple logs
- Live stats with memory and CPU usage
- Multi-user [authentication](https://dozzle.dev/guide/authentication) with support for proxy forward authorization 🚨
- [Swarm](https://dozzle.dev/guide/swarm-mode) mode support 🐳
- [Agent](https://dozzle.dev/guide/agent) mode for monitoring multiple Docker hosts 🕵️‍♂️
- Dark mode 🌙

Dozzle has been tested with hundreds of containers. However, it doesn't support offline searching. Products like [Loggly](https://www.loggly.com), [Papertrail](https://papertrailapp.com) or [Kibana](https://www.elastic.co/products/kibana) are more suited for full search capabilities.

## Support

There are many ways you can support Dozzle:

- Use it! Write about it! Star it! If you love Dozzle, drop me a line and tell me what you love.
- Blog about Dozzle to spread the word. If you are good at writing send PRs to improve the documentation at [dozzle.dev](https://dozzle.dev/)
- Sponsor my work at https://www.buymeacoffee.com/amirraminfar

<a href="https://www.buymeacoffee.com/amirraminfar" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

## Building

To build and test locally:

1. Install [NodeJs](https://nodejs.org/en/download/) and [pnpm](https://pnpm.io/installation).
2. Install [Go](https://go.dev/doc/install).
3. Install tools with `make tools`.
4. Install node modules `pnpm install`.
5. Run `make dev` to start a development server with hot reload.
