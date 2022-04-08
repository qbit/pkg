PKG(8) - System Manager's Manual

# NAME

**pkg** - a wraper for OpenBSD's pkg\* tools

# SYNOPSIS

**pkg**
\[*delete*&nbsp;*package*]
\[*info*&nbsp;*package*]
\[*install*&nbsp;*package*]
\[*pkginfo*&nbsp;*package*]
\[*search*&nbsp;*string*]

# DESCRIPTION

**pkg**
is a
perl(1)
script that allows easier package management and more extensive searching.

**pkg**
uses
sqlports(5) for quicker, full text searching of COMMENT and DESCR fields.

The options are as follows:

*delete package*

> Deletes
> **package**.
> This is a wrapper for
> pkg\_delete(1)
> It is also aliased to
> **del**,
> and
> **rm**.

*info package*

> Fetches
> **package**
> information.
> This is a wrapper for
> pkg\_info(1)
> It is aliased to
> **inf**.

*install package*

> A wrapper for
> pkg\_add(1).
> Aliased to
> **i**.

*pkginfo FULLPKGNAME*

> Intended for use with tools like
> fzf(1).
> This lets one quickly look up
> **COMMENT**
> and
> **DESCRIPTION**
> for a given
> **FULLPKGNAME**.
> Aliased to
> **pi**.

*search string*

> Search a packages
> **COMMENT**
> and
> **DESCR**
> for an arbitrary string.
> Returns
> **FULLPKGNAME**.

# HISTORY

**pkg**
was written in 2001, removed from base in 2012, revived and enhanced in 2018
and 2022.

# AUTHORS

**pkg**
was originally written by
Marc Espie &lt;[espie@openbsd.org](mailto:espie@openbsd.org)&gt;.
Rewrite by
Aaron Bieber &lt;[abieber@openbsd.org](mailto:abieber@openbsd.org)&gt;.

OpenBSD 7.1 - April 7, 2022
