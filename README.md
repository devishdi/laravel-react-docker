<!-- @format -->

# Laravel React Starter kit :raised_hand:

- Ready to use package for Laravel and React. Please clone this repo if you need to start development on laravel with react and vite.

- The package includes code quality tools PHP Stan, PHP CS Fixer, Pest Unit Test, Eslint, Prettier and Vitest

- The package is also added the Typescript support

- Please refer the Makefile for the ready to use commands

- Email can be send and receive by http://laravel.localdev:8025/

### Includes

- nginx 1.29
- Laravel 12.x
- MariaDB 11.4
- PHP 8.4
- Node.js 23
- React 19.x
- OpenSearch 2.9.0
- Redis 8.x
- Mailhog

### Installation

- cp .env.dist .env
- make project-start
- make app-install or (make enter-shell-front, yarn , exit, make app-install)

Domains like below should be setup by editing your /etc/hosts files:

- [http://laravel.localdev](http://laravel.localdev)
- [http://laravel.search.localdev](http://laravel.search.localdev)

> Open search Dashboard: [http://laravel.search.localdev](http://laravel.search.localdev)

Front end commands to run the application:

- make app-front-build
- make app-front-run

> [!NOTE]
> This package works well with Mac and Linux OS. We didnt test it on windows. Please do the necessary updations if you need to use on windows.
