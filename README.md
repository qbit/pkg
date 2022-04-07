PKG(8) - System Manager's Manual

# NAME

**pkg** - a wraper for OpenBSD's pkg\* tools

# SYNOPSIS

**pkg**
\[*delete*&nbsp;*package*]
\[*install*&nbsp;*package*]
\[*info*&nbsp;*package*]
\[*pathinfo*&nbsp;*pkgpath*]
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
> **package**

*install package*

*info package*

*pathinfo package*

*search string*

> Search a packages COMMENT and DESCR for an arbitrary string.
> **pkg**

# AUTHORS

**pkg**

OpenBSD 7.1 - April 7, 2022
