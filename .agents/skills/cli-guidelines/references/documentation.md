# Documentation

The purpose of help text is to give a brief, immediate sense of what your tool is, what options are available, and how to perform the most common tasks. Documentation, on the other hand, is where you go into full detail. It's where people go to understand what your tool is for, what it _isn't_ for, how it works and how to do everything they might need to do.

## Web-based Documentation

**Provide web-based documentation.** People need to be able to search online for your tool's documentation, and to link other people to specific parts. The web is the most inclusive documentation format available.

Benefits:

- Searchable via Google/search engines
- Linkable to specific sections
- Accessible from any device
- Can include rich media, interactive examples

## Terminal-based Documentation

**Provide terminal-based documentation.** Documentation in the terminal has several nice properties:

- **Fast to access**: No need to open a browser
- **Stays in sync**: Matches the specific installed version of the tool
- **Works offline**: No internet connection required

## Man Pages

**Consider providing man pages.** Man pages, Unix's original system of documentation, are still in use today, and many users will reflexively check `man mycmd` as a first step when trying to learn about your tool.

To make them easier to generate, you can use a tool like [ronn](http://rtomayko.github.io/ronn/ronn.1.html) (which can also generate your web docs).

However, not everyone knows about `man`, and it doesn't run on all platforms, so you should also make sure your terminal docs are accessible via your tool itself.

**Example: Making man pages accessible via the tool**

`git` and `npm` make their man pages accessible via the `help` subcommand, so `npm help ls` is equivalent to `man npm-ls`:

```
NPM-LS(1)                                                            NPM-LS(1)

NAME
       npm-ls - List installed packages

SYNOPSIS
         npm ls [[<@scope>/]<pkg> ...]

         aliases: list, la, ll

DESCRIPTION
       This command will print to stdout all the versions of packages that are
       installed, as well as their dependencies, in a tree-structure.

       ...
```

## Documentation Best Practices

### Structure

1. **Quick start / Getting started**: First thing users see
2. **Installation**: Clear, copy-pasteable commands
3. **Basic usage**: Common use cases with examples
4. **Reference**: Complete API/flag documentation
5. **Troubleshooting**: Common errors and solutions
6. **FAQ**: Frequently asked questions

### Content Guidelines

- **Lead with examples**: Show, don't just tell
- **Keep it current**: Outdated docs are worse than no docs
- **Version your docs**: Match docs to software versions
- **Include "why"**: Not just "how" but "why" you'd use something
- **Cross-reference**: Link between related sections

### Making Docs Discoverable

- Link to web docs from `--help` output
- Include doc URLs in error messages where relevant
- Provide a `docs` or `help` subcommand that opens docs
- Include the docs URL in your README

## Tools for Generating Documentation

- **ronn**: Generate man pages and HTML from Markdown
- **mdBook**: Rust-based book from Markdown (like gitbook)
- **MkDocs**: Python-based documentation generator
- **Docusaurus**: React-based documentation framework
- **Sphinx**: Python documentation generator
- **Hugo/Jekyll**: Static site generators

## Help vs Documentation

| Aspect   | Help (`--help`)  | Documentation          |
| -------- | ---------------- | ---------------------- |
| Length   | Brief, scannable | Comprehensive          |
| Purpose  | Quick reference  | Full understanding     |
| Examples | 1-3 common cases | Exhaustive coverage    |
| Access   | Built into CLI   | Web/man pages          |
| Detail   | Flags and usage  | Concepts and tutorials |
