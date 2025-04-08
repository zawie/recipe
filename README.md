# A Simple Recipe Site

An extraordinaly simple website hosting recipes I like.

## How do I contribute a recipe?

To contribute a recipe, simply add a file to the `markdown` directory.

To set a title, add the a title comment to the markdown file, e.g

```
<!--title:🌯 Burrito Bowl-->
```

## How does this website work?

The website is entirely statically generated, meaning at build time we use `pandoc` and some other bash shenanigans to convert the markdown files into html that is statically hosted on GitHub pages.

The `build.sh` script is the entry point for building the website. For simple styling, we use [simplecss](https://simplecss.org).

## Set-up git hooks

To set up git hooks, run the following command:

```
cp .githooks/pre-commit .git/hooks/pre-commit
```
