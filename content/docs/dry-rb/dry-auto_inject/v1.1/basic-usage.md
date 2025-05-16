---
title: Basic Usage
layout: gem-single
name: dry-auto_inject
---

### Requirements

You need only one thing before you can use dry-auto_inject: a container to hold your application’s dependencies. These are commonly known as “inversion of control” containers.

A [dry-container](https://dry-rb.org/gems/dry-container) will work well, but the only requirement is that the container responds to the #[] interface. For example, my_container["users_repository"] should return the “users_repository” object registered with the container.
